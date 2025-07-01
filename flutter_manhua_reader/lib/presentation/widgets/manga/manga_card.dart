import 'dart:io';
import 'package:flutter/material.dart';

class MangaCard extends StatelessWidget {
  final String title;
  final String? coverPath;
  final String? subtitle;
  final double? progress;
  final int totalPages;
  final int? currentPage;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MangaCard({
    super.key,
    required this.title,
    required this.totalPages,
    this.currentPage,
    this.coverPath,
    this.subtitle,
    this.progress,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                child: Stack(
                  children: [
                    _buildCoverImage(),
                    if (progress != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: progress!,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return coverPath != null && coverPath!.isNotEmpty
        ? Image.file(
            File(coverPath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image));
            },
          )
        : Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
  }
}
