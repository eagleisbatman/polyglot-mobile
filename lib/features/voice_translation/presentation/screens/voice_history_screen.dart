import 'package:flutter/material.dart';
import '../../../../core/constants/test_tags.dart';

class VoiceHistoryScreen extends StatelessWidget {
  const VoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key(TestTags.voiceHistoryScreen),
      appBar: AppBar(
        title: const Text('Voice History'),
      ),
      body: const Center(
        child: Text('Voice History - Coming Soon'),
      ),
    );
  }
}

