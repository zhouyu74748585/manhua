import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/library.dart';

/// 封面展示模式选择器组件
class CoverDisplayModeSelector extends ConsumerWidget {
  final CoverDisplayMode currentMode;
  final ValueChanged<CoverDisplayMode> onModeChanged;
  final bool enabled;

  const CoverDisplayModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '封面展示模式',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '选择漫画封面的显示方式，适用于不同的封面扫描格式',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 16),

        // 模式选择卡片
        ...CoverDisplayMode.values.map((mode) => _buildModeCard(
              context,
              mode,
              isSelected: currentMode == mode,
              onTap: enabled ? () => onModeChanged(mode) : null,
            )),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    CoverDisplayMode mode, {
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 模式图标和预览
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: _buildModePreview(context, mode),
                ),
                const SizedBox(width: 16),

                // 模式信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mode.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // 选择指示器
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.5),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModePreview(BuildContext context, CoverDisplayMode mode) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (mode) {
      case CoverDisplayMode.defaultMode:
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.image,
            color: colorScheme.primary,
            size: 24,
          ),
        );

      case CoverDisplayMode.leftHalf:
        return Container(
          margin: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.crop_free,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case CoverDisplayMode.rightHalf:
        return Container(
          margin: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.crop_free,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

/// 简化版的封面展示模式选择器（用于设置页面等）
class CompactCoverDisplayModeSelector extends ConsumerWidget {
  final CoverDisplayMode currentMode;
  final ValueChanged<CoverDisplayMode> onModeChanged;
  final bool enabled;

  const CompactCoverDisplayModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<CoverDisplayMode>(
      segments: CoverDisplayMode.values.map((mode) {
        return ButtonSegment<CoverDisplayMode>(
          value: mode,
          label: Text(mode.displayName),
          icon: _getModeIcon(mode),
        );
      }).toList(),
      selected: {currentMode},
      onSelectionChanged: enabled
          ? (Set<CoverDisplayMode> selection) {
              if (selection.isNotEmpty) {
                onModeChanged(selection.first);
              }
            }
          : null,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
        selectedForegroundColor:
            Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Icon _getModeIcon(CoverDisplayMode mode) {
    switch (mode) {
      case CoverDisplayMode.defaultMode:
        return const Icon(Icons.image, size: 16);
      case CoverDisplayMode.leftHalf:
        return const Icon(Icons.border_left, size: 16);
      case CoverDisplayMode.rightHalf:
        return const Icon(Icons.border_right, size: 16);
    }
  }
}
