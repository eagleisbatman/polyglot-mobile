import 'package:flutter/material.dart';
import '../../../../core/constants/test_tags.dart';

class MicButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const MicButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      key: Key(isRecording ? TestTags.voiceMicButtonStop : TestTags.voiceMicButtonStart),
      onPressed: onPressed,
      backgroundColor: isRecording
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
        size: 32,
      ),
    );
  }
}

