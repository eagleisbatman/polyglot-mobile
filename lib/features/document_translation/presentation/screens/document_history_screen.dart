import 'package:flutter/material.dart';
import '../../../../core/constants/test_tags.dart';

class DocumentHistoryScreen extends StatelessWidget {
  const DocumentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key(TestTags.docsHistoryScreen),
      appBar: AppBar(
        title: const Text('Document History'),
      ),
      body: const Center(
        child: Text('Document History - Coming Soon'),
      ),
    );
  }
}

