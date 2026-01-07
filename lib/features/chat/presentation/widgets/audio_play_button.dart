import 'package:flutter/material.dart';

/// A tappable audio play button with playing animation
class AudioPlayButton extends StatelessWidget {
  final String label;
  final bool isPlaying;
  final VoidCallback onPressed;
  final Color? color;
  final IconData playIcon;
  final IconData stopIcon;

  const AudioPlayButton({
    super.key,
    required this.label,
    required this.isPlaying,
    required this.onPressed,
    this.color,
    this.playIcon = Icons.play_arrow_rounded,
    this.stopIcon = Icons.stop_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPlaying 
                ? buttonColor.withOpacity(0.2)
                : buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPlaying ? buttonColor : buttonColor.withOpacity(0.3),
              width: isPlaying ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon with pulse effect when playing
              _AnimatedPlayIcon(
                isPlaying: isPlaying,
                playIcon: playIcon,
                stopIcon: stopIcon,
                color: buttonColor,
              ),
              const SizedBox(width: 8),
              Text(
                isPlaying ? 'Stop' : label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: buttonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Playing indicator animation
              if (isPlaying) ...[
                const SizedBox(width: 8),
                _PlayingIndicator(color: buttonColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedPlayIcon extends StatelessWidget {
  final bool isPlaying;
  final IconData playIcon;
  final IconData stopIcon;
  final Color color;

  const _AnimatedPlayIcon({
    required this.isPlaying,
    required this.playIcon,
    required this.stopIcon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Icon(
        isPlaying ? stopIcon : playIcon,
        key: ValueKey(isPlaying),
        size: 24,
        color: color,
      ),
    );
  }
}

/// Animated bars that pulse when audio is playing
class _PlayingIndicator extends StatefulWidget {
  final Color color;

  const _PlayingIndicator({required this.color});

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = (_controller.value + delay) % 1.0;
            final height = 4 + (value * 8);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}

