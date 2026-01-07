import 'package:flutter/material.dart';

/// A simple circular play button - matches the mic button style
class AudioPlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const AudioPlayButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
    this.color,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPlaying ? buttonColor : buttonColor.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: buttonColor,
            width: 2,
          ),
        ),
        child: Icon(
          isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: isPlaying ? Colors.white : buttonColor,
          size: size * 0.55,
        ),
      ),
    );
  }
}
