import 'package:flutter/material.dart';
import '../../../../core/constants/test_tags.dart';

class TranscriptionBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final int index;

  const TranscriptionBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(isUser
          ? TestTags.voiceTranscriptionUser(index)
          : TestTags.voiceTranscriptionModel(index)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isUser
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

