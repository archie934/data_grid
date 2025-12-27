import 'package:flutter/material.dart';

/// A custom vertical scrollbar widget with drag support.
///
/// Provides a draggable thumb that allows direct manipulation of scroll position.
/// Automatically calculates thumb size based on viewport/content ratio.
class CustomVerticalScrollbar extends StatefulWidget {
  final ScrollController controller;
  final double width;

  const CustomVerticalScrollbar({super.key, required this.controller, this.width = 12});

  @override
  State<CustomVerticalScrollbar> createState() => _CustomVerticalScrollbarState();
}

class _CustomVerticalScrollbarState extends State<CustomVerticalScrollbar> {
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
            final trackHeight = constraints.maxHeight;

            if (!widget.controller.hasClients || trackHeight == 0) {
              return Container(width: widget.width, color: Colors.grey.withValues(alpha: 0.1));
            }

            final position = widget.controller.position;
            final viewportSize = position.viewportDimension;
            final scrollOffset = position.pixels.clamp(0.0, position.maxScrollExtent);
            final maxScrollExtent = position.maxScrollExtent;

            if (viewportSize == 0 || maxScrollExtent <= 0) {
              return Container(width: widget.width, color: Colors.grey.withValues(alpha: 0.1));
            }

            final contentSize = maxScrollExtent + viewportSize;
            if (contentSize <= viewportSize) {
              return Container(width: widget.width, color: Colors.grey.withValues(alpha: 0.1));
            }

            final thumbHeight = ((viewportSize / contentSize) * trackHeight).clamp(30.0, trackHeight);
            final thumbOffset = (scrollOffset / contentSize) * trackHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (_isDragging) return;

                final tapPosition = details.localPosition.dy;

                // Calculate target scroll position based on tap location
                final targetThumbOffset = tapPosition - thumbHeight / 2;
                final targetScrollOffset = (targetThumbOffset / trackHeight) * contentSize;
                final clampedScrollOffset = targetScrollOffset.clamp(0.0, maxScrollExtent);

                // Animate to target position
                widget.controller.animateTo(
                  clampedScrollOffset,
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
                final newThumbOffset = startThumbOffset + delta;
                final newScrollOffset = (newThumbOffset / trackHeight) * contentSize;
                final clampedOffset = newScrollOffset.clamp(0.0, maxScrollExtent);

                // Use animateTo with minimal duration for smooth dragging
                widget.controller.animateTo(
                  clampedOffset,
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.linear,
                );
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
                width: widget.width,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  border: const Border(left: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      top: thumbOffset,
                      left: 2,
                      right: 2,
                      child: Container(
                        height: thumbHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF757575).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular((widget.width - 4) / 2),
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
