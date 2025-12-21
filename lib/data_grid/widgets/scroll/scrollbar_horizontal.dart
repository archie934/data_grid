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

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.hasClients) {
      return Container(height: widget.height, color: Colors.grey.withValues(alpha: 0.1));
    }

    try {
      final position = widget.controller.position;
      final viewportSize = position.viewportDimension;
      final scrollOffset = position.pixels;
      final maxScrollExtent = position.maxScrollExtent;

      if (viewportSize == 0 || maxScrollExtent <= 0) {
        return Container(height: widget.height, color: Colors.grey.withValues(alpha: 0.1));
      }

      final contentSize = maxScrollExtent + viewportSize;
      if (contentSize <= viewportSize) {
        return Container(height: widget.height, color: Colors.grey.withValues(alpha: 0.1));
      }

      final thumbWidth = (viewportSize / contentSize) * viewportSize;
      final thumbOffset = (scrollOffset / contentSize) * viewportSize;

      return GestureDetector(
        onHorizontalDragStart: (details) {
          _dragStartOffset = details.localPosition.dx;
          _dragStartThumbOffset = thumbOffset;
        },
        onHorizontalDragUpdate: (details) {
          final startOffset = _dragStartOffset;
          final startThumbOffset = _dragStartThumbOffset;
          if (startOffset == null || startThumbOffset == null) return;

          final delta = details.localPosition.dx - startOffset;
          final newThumbOffset = startThumbOffset + delta;
          final newScrollOffset = (newThumbOffset / viewportSize) * contentSize;

          widget.controller.jumpTo(newScrollOffset.clamp(0.0, maxScrollExtent));
        },
        onHorizontalDragEnd: (_) {
          _dragStartOffset = null;
          _dragStartThumbOffset = null;
        },
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            border: const Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: thumbOffset,
                top: 2,
                bottom: 2,
                child: Container(
                  width: thumbWidth.clamp(30.0, double.infinity),
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
    } catch (e) {
      // Return a subtle error indicator if scrollbar fails to build
      return Container(height: widget.height, color: Colors.grey.withValues(alpha: 0.1));
    }
  }
}

