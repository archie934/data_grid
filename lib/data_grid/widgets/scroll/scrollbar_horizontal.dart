import 'package:flutter/material.dart';

/// A custom horizontal scrollbar widget with drag support.
///
/// Provides a draggable thumb that allows direct manipulation of scroll position.
/// Automatically calculates thumb size based on viewport/content ratio.
class CustomHorizontalScrollbar extends StatefulWidget {
  final ScrollController controller;
  final double height;

  const CustomHorizontalScrollbar({super.key, required this.controller, this.height = 12});

  @override
  State<CustomHorizontalScrollbar> createState() => _CustomHorizontalScrollbarState();
}

class _CustomHorizontalScrollbarState extends State<CustomHorizontalScrollbar> {
  double? _dragStartOffset;
  double? _dragStartThumbOffset;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;

            if (!widget.controller.hasClients || trackWidth == 0) {
              return Container(height: widget.height, color: Colors.grey.withValues(alpha: 0.1));
            }

            final position = widget.controller.position;
            final viewportSize = position.viewportDimension;
            final scrollOffset = position.pixels.clamp(0.0, position.maxScrollExtent);
            final maxScrollExtent = position.maxScrollExtent;

            if (viewportSize == 0 || maxScrollExtent <= 0) {
              return Container(height: widget.height, color: Colors.grey.withValues(alpha: 0.1));
            }

            final contentSize = maxScrollExtent + viewportSize;
            if (contentSize <= viewportSize) {
              return Container(height: widget.height, color: Colors.grey.withValues(alpha: 0.1));
            }

            final thumbWidth = ((viewportSize / contentSize) * trackWidth).clamp(30.0, trackWidth);
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
                height: widget.height,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  border: const Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      left: thumbOffset,
                      top: 2,
                      bottom: 2,
                      child: Container(
                        width: thumbWidth,
                        decoration: BoxDecoration(
                          color: const Color(0xFF757575).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular((widget.height - 4) / 2),
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
