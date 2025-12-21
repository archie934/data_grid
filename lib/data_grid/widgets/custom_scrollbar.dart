import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.hasClients) {
      return Container(width: widget.width, color: Colors.grey.withOpacity(0.1));
    }

    try {
      final position = widget.controller.position;
      final viewportSize = position.viewportDimension;
      final scrollOffset = position.pixels;
      final maxScrollExtent = position.maxScrollExtent;

      if (viewportSize == 0 || maxScrollExtent <= 0) {
        return Container(width: widget.width, color: Colors.grey.withOpacity(0.1));
      }

      final contentSize = maxScrollExtent + viewportSize;
      if (contentSize <= viewportSize) {
        return Container(width: widget.width, color: Colors.grey.withOpacity(0.1));
      }

      final thumbHeight = (viewportSize / contentSize) * viewportSize;
      final thumbOffset = (scrollOffset / contentSize) * viewportSize;

      return GestureDetector(
        onVerticalDragStart: (details) {
          _dragStartOffset = details.localPosition.dy;
          _dragStartThumbOffset = thumbOffset;
        },
        onVerticalDragUpdate: (details) {
          final startOffset = _dragStartOffset;
          final startThumbOffset = _dragStartThumbOffset;
          if (startOffset == null || startThumbOffset == null) return;

          final delta = details.localPosition.dy - startOffset;
          final newThumbOffset = startThumbOffset + delta;
          final newScrollOffset = (newThumbOffset / viewportSize) * contentSize;

          widget.controller.jumpTo(newScrollOffset.clamp(0.0, maxScrollExtent));
        },
        onVerticalDragEnd: (_) {
          _dragStartOffset = null;
          _dragStartThumbOffset = null;
        },
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            border: const Border(left: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: thumbOffset,
                left: 2,
                right: 2,
                child: Container(
                  height: thumbHeight.clamp(30.0, double.infinity),
                  decoration: BoxDecoration(
                    color: const Color(0xFF757575).withOpacity(0.7),
                    borderRadius: BorderRadius.circular((widget.width - 4) / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      // Return a subtle error indicator if scrollbar fails to build
      return Container(width: widget.width, color: Colors.grey.withOpacity(0.1));
    }
  }
}

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
      return Container(height: widget.height, color: Colors.grey.withOpacity(0.1));
    }

    try {
      final position = widget.controller.position;
      final viewportSize = position.viewportDimension;
      final scrollOffset = position.pixels;
      final maxScrollExtent = position.maxScrollExtent;

      if (viewportSize == 0 || maxScrollExtent <= 0) {
        return Container(height: widget.height, color: Colors.grey.withOpacity(0.1));
      }

      final contentSize = maxScrollExtent + viewportSize;
      if (contentSize <= viewportSize) {
        return Container(height: widget.height, color: Colors.grey.withOpacity(0.1));
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
            color: Colors.grey.withOpacity(0.1),
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
                    color: const Color(0xFF757575).withOpacity(0.7),
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
      return Container(height: widget.height, color: Colors.grey.withOpacity(0.1));
    }
  }
}
