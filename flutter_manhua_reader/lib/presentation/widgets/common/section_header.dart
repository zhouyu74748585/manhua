import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showMore;
  final VoidCallback? onMoreTap;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showMore = false,
    this.onMoreTap,
    this.trailing,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showMore)
            TextButton(
              onPressed: onMoreTap,
              child: const Text('查看更多'),
            ),
        ],
      ),
    );
  }
}