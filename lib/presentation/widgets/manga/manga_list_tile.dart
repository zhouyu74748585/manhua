import 'package:flutter/material.dart';

class MangaListTile extends StatelessWidget {
  final String title;
  final String? coverPath;
  final String? subtitle;
  final double? progress;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MangaListTile({
    super.key,
    required this.title,
    this.coverPath,
    this.subtitle,
    this.progress,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildCoverImage(),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (progress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(
                          value: progress!,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4.0),
        image: coverPath != null && coverPath!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(coverPath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: coverPath == null || coverPath!.isEmpty
          ? const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            )
          : null,
    );
  }
}
