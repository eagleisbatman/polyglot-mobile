import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final String id;
  final String title;
  final String? subtitle;
  final String? preview;
  final VoidCallback? onTap;
  final Widget? trailing;

  const HistoryItem({
    super.key,
    required this.id,
    required this.title,
    this.subtitle,
    this.preview,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (preview != null) ...[
              const SizedBox(height: 4),
              Text(
                preview!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

