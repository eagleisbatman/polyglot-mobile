import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Real-time audio waveform that responds to actual audio input levels
class AudioWaveform extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double height;
  final int barCount;
  /// Stream of amplitude values (0.0 to 1.0) for real visualization
  final Stream<double>? amplitudeStream;

  const AudioWaveform({
    super.key,
    required this.isActive,
    this.color = Colors.white,
    this.height = 40,
    this.barCount = 7,
    this.amplitudeStream,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;
  late List<double> _barHeights;
  StreamSubscription<double>? _amplitudeSubscription;
  final _random = Random();
  double _currentAmplitude = 0.0;
  
  @override
  void initState() {
    super.initState();
    _barHeights = List.filled(widget.barCount, 0.2);
    
    // Idle animation controller for when no amplitude stream
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..addListener(_updateIdleBars);
    
    if (widget.isActive) {
      _startListening();
    }
  }

  void _startListening() {
    if (widget.amplitudeStream != null) {
      _amplitudeSubscription = widget.amplitudeStream!.listen((amplitude) {
        _currentAmplitude = amplitude.clamp(0.0, 1.0);
        _updateBarsFromAmplitude();
      });
    } else {
      // No amplitude stream - use idle animation
      _idleController.repeat();
    }
  }

  void _stopListening() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _idleController.stop();
    setState(() {
      _barHeights = List.filled(widget.barCount, 0.2);
    });
  }

  void _updateBarsFromAmplitude() {
    if (!mounted) return;
    
    setState(() {
      // Shift bars left
      for (int i = 0; i < _barHeights.length - 1; i++) {
        _barHeights[i] = _barHeights[i + 1];
      }
      
      // Add new amplitude to the rightmost bar with some variation
      final variation = _random.nextDouble() * 0.2 - 0.1;
      _barHeights[_barHeights.length - 1] = 
          (_currentAmplitude + variation).clamp(0.15, 1.0);
    });
  }

  void _updateIdleBars() {
    if (!mounted || !widget.isActive) return;
    
    setState(() {
      for (int i = 0; i < _barHeights.length; i++) {
        // Random subtle movement for idle state
        _barHeights[i] = 0.2 + _random.nextDouble() * 0.3;
      }
    });
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _startListening();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopListening();
    }
    
    // Handle amplitude stream changes
    if (widget.amplitudeStream != oldWidget.amplitudeStream) {
      _amplitudeSubscription?.cancel();
      if (widget.isActive && widget.amplitudeStream != null) {
        _amplitudeSubscription = widget.amplitudeStream!.listen((amplitude) {
          _currentAmplitude = amplitude.clamp(0.0, 1.0);
          _updateBarsFromAmplitude();
        });
        _idleController.stop();
      } else if (widget.isActive) {
        _idleController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: max(4, widget.height * _barHeights[index]),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
