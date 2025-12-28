import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/theme/data_grid_theme.dart';

/// A custom horizontal scrollbar widget with drag support.
///
/// Provides a draggable thumb that allows direct manipulation of scroll position.
/// Automatically calculates thumb size based on viewport/content ratio.
class CustomHorizontalScrollbar extends StatefulWidget {
  final ScrollController controller;

  const CustomHorizontalScrollbar({super.key, required this.controller});

  @override
  State<CustomHorizontalScrollbar> createState() => _CustomHorizontalScrollbarState();
}

class _CustomHorizontalScrollbarState extends State<CustomHorizontalScrollbar> {
  double? _dragStartOffset;
  double? _dragStartThumbOffset;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final height = theme.dimensions.scrollbarHeight;
    final thumbMinSize = theme.dimensions.scrollbarThumbMinSize;
    final thumbInset = theme.padding.scrollbarThumbInset;
    final trackColor = theme.colors.scrollbarTrackColor;
    final thumbColor = theme.colors.scrollbarThumbColor;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;

            if (!widget.controller.hasClients || trackWidth == 0) {
              return Container(height: height, color: trackColor);
            }

            final position = widget.controller.position;
            final viewportSize = position.viewportDimension;
            final scrollOffset = position.pixels.clamp(0.0, position.maxScrollExtent);
            final maxScrollExtent = position.maxScrollExtent;

            if (viewportSize == 0 || maxScrollExtent <= 0) {
              return Container(height: height, color: trackColor);
            }

            final contentSize = maxScrollExtent + viewportSize;
            if (contentSize <= viewportSize) {
              return Container(height: height, color: trackColor);
            }

            final thumbWidth = ((viewportSize / contentSize) * trackWidth).clamp(thumbMinSize, trackWidth);
            final thumbOffset = (scrollOffset / contentSize) * trackWidth;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (_isDragging) return;

                final tapPosition = details.localPosition.dx;

                // Calculate target scroll position based on tap location
                final targetThumbOffset = tapPosition - thumbWidth / 2;
                final targetScrollOffset = (targetThumbOffset / trackWidth) * contentSize;
                final clampedScrollOffset = targetScrollOffset.clamp(0.0, maxScrollExtent);

                // Animate to target position
                widget.controller.animateTo(
                  clampedScrollOffset,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              },
              onHorizontalDragStart: (details) {
                _isDragging = true;
                _dragStartOffset = details.localPosition.dx;
                _dragStartThumbOffset = thumbOffset;
              },
              onHorizontalDragUpdate: (details) {
                final startOffset = _dragStartOffset;
                final startThumbOffset = _dragStartThumbOffset;
                if (startOffset == null || startThumbOffset == null) return;

                final delta = details.localPosition.dx - startOffset;
                final newThumbOffset = startThumbOffset + delta;
                final newScrollOffset = (newThumbOffset / trackWidth) * contentSize;
                final clampedOffset = newScrollOffset.clamp(0.0, maxScrollExtent);

                // Use animateTo with minimal duration for smooth dragging
                widget.controller.animateTo(
                  clampedOffset,
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.linear,
                );
              },
              onHorizontalDragEnd: (_) {
                _dragStartOffset = null;
                _dragStartThumbOffset = null;
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    _isDragging = false;
                  }
                });
              },
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: trackColor,
                  border: Border(top: theme.borders.scrollbarBorder.top),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      left: thumbOffset,
                      top: thumbInset,
                      bottom: thumbInset,
                      child: Container(
                        width: thumbWidth,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          borderRadius: BorderRadius.circular((height - thumbInset * 2) / 2),
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
