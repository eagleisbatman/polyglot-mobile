import 'package:flutter/material.dart';
import '../../../../core/constants/test_tags.dart';

class VisionHistoryScreen extends StatelessWidget {
  const VisionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key(TestTags.visionHistoryScreen),
      appBar: AppBar(
        title: const Text('Vision History'),
      ),
      body: const Center(
        child: Text('Vision History - Coming Soon'),
      ),
    );
  }
}

