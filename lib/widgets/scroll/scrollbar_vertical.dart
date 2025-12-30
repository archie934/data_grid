import 'package:flutter/material.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// A custom vertical scrollbar widget with drag support.
///
/// Provides a draggable thumb that allows direct manipulation of scroll position.
/// Automatically calculates thumb size based on viewport/content ratio.
class CustomVerticalScrollbar extends StatefulWidget {
  final ScrollController controller;

  const CustomVerticalScrollbar({super.key, required this.controller});

  @override
  State<CustomVerticalScrollbar> createState() => _CustomVerticalScrollbarState();
}

class _CustomVerticalScrollbarState extends State<CustomVerticalScrollbar> {
  double? _dragStartOffset;
  double? _dragStartThumbOffset;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final width = theme.dimensions.scrollbarWidth;
    final thumbMinSize = theme.dimensions.scrollbarThumbMinSize;
    final thumbInset = theme.padding.scrollbarThumbInset;
    final trackColor = theme.colors.scrollbarTrackColor;
    final thumbColor = theme.colors.scrollbarThumbColor;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackHeight = constraints.maxHeight;

            if (!widget.controller.hasClients || trackHeight == 0) {
              return Container(width: width, color: trackColor);
            }

            final position = widget.controller.position;
            final viewportSize = position.viewportDimension;
            final scrollOffset = position.pixels.clamp(0.0, position.maxScrollExtent);
            final maxScrollExtent = position.maxScrollExtent;

            if (viewportSize == 0 || maxScrollExtent <= 0) {
              return Container(width: width, color: trackColor);
            }

            final contentSize = maxScrollExtent + viewportSize;
            if (contentSize <= viewportSize) {
              return Container(width: width, color: trackColor);
            }

            final thumbHeight = ((viewportSize / contentSize) * trackHeight).clamp(thumbMinSize, trackHeight);
            final scrollableTrackHeight = trackHeight - thumbHeight;
            final thumbOffset = maxScrollExtent > 0 ? (scrollOffset / maxScrollExtent) * scrollableTrackHeight : 0.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (_isDragging) return;

                final tapPosition = details.localPosition.dy;

                // Calculate target scroll position based on tap location
                final targetThumbOffset = (tapPosition - thumbHeight / 2).clamp(0.0, scrollableTrackHeight);
                final targetScrollOffset = scrollableTrackHeight > 0
                    ? (targetThumbOffset / scrollableTrackHeight) * maxScrollExtent
                    : 0.0;

                // Animate to target position
                widget.controller.animateTo(
                  targetScrollOffset,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              },
              onVerticalDragStart: (details) {
                _isDragging = true;
                _dragStartOffset = details.localPosition.dy;
                _dragStartThumbOffset = thumbOffset;
              },
              onVerticalDragUpdate: (details) {
                final startOffset = _dragStartOffset;
                final startThumbOffset = _dragStartThumbOffset;
                if (startOffset == null || startThumbOffset == null) return;

                final delta = details.localPosition.dy - startOffset;
                final newThumbOffset = (startThumbOffset + delta).clamp(0.0, scrollableTrackHeight);
                final newScrollOffset = scrollableTrackHeight > 0
                    ? (newThumbOffset / scrollableTrackHeight) * maxScrollExtent
                    : 0.0;

                // Use jumpTo for instant updates during drag (no animation = no stutter)
                widget.controller.jumpTo(newScrollOffset);
              },
              onVerticalDragEnd: (_) {
                _dragStartOffset = null;
                _dragStartThumbOffset = null;
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    _isDragging = false;
                  }
                });
              },
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: trackColor,
                  border: Border(left: theme.borders.scrollbarBorder.left),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      top: thumbOffset,
                      left: thumbInset,
                      right: thumbInset,
                      child: Container(
                        height: thumbHeight,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          borderRadius: BorderRadius.circular((width - thumbInset * 2) / 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
