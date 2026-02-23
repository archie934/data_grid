import 'package:flutter/material.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// Lightweight scrollbar driven by a [ValueNotifier] offset.
class OffsetScrollbar extends StatefulWidget {
  final ValueNotifier<double> offset;
  final double maxScroll;
  final Axis axis;
  final double viewportExtent;
  final double contentExtent;

  const OffsetScrollbar({
    super.key,
    required this.offset,
    required this.maxScroll,
    required this.axis,
    required this.viewportExtent,
    required this.contentExtent,
  });

  @override
  State<OffsetScrollbar> createState() => _OffsetScrollbarState();
}

class _OffsetScrollbarState extends State<OffsetScrollbar> {
  double? _dragStartPosition;
  double? _dragStartThumbOffset;
  bool _isDragging = false;

  bool get _isVertical => widget.axis == Axis.vertical;

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartPosition = _isVertical
        ? details.localPosition.dy
        : details.localPosition.dx;

    final theme = DataGridTheme.of(context);
    final thumbMinSize = theme.dimensions.scrollbarThumbMinSize;

    final trackLength = _isVertical
        ? (context.size?.height ?? 0)
        : (context.size?.width ?? 0);
    final ratio = widget.viewportExtent / widget.contentExtent;
    final thumbLength = (ratio * trackLength).clamp(thumbMinSize, trackLength);
    final scrollableTrack = trackLength - thumbLength;
    _dragStartThumbOffset = widget.maxScroll > 0
        ? (widget.offset.value / widget.maxScroll) * scrollableTrack
        : 0.0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final startPos = _dragStartPosition;
    final startThumb = _dragStartThumbOffset;
    if (startPos == null || startThumb == null) return;

    final currentPos = _isVertical
        ? details.localPosition.dy
        : details.localPosition.dx;
    final delta = currentPos - startPos;

    final theme = DataGridTheme.of(context);
    final thumbMinSize = theme.dimensions.scrollbarThumbMinSize;

    final trackLength = _isVertical
        ? (context.size?.height ?? 0)
        : (context.size?.width ?? 0);
    final ratio = widget.viewportExtent / widget.contentExtent;
    final thumbLength = (ratio * trackLength).clamp(thumbMinSize, trackLength);
    final scrollableTrack = trackLength - thumbLength;

    final newThumb = (startThumb + delta).clamp(0.0, scrollableTrack);
    widget.offset.value = scrollableTrack > 0
        ? (newThumb / scrollableTrack) * widget.maxScroll
        : 0.0;
  }

  void _onDragEnd(DragEndDetails details) {
    _dragStartPosition = null;
    _dragStartThumbOffset = null;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isDragging = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final trackSize = _isVertical
        ? theme.dimensions.scrollbarWidth
        : theme.dimensions.scrollbarHeight;
    final thumbMinSize = theme.dimensions.scrollbarThumbMinSize;
    final thumbInset = theme.padding.scrollbarThumbInset;
    final trackColor = theme.colors.scrollbarTrackColor;
    final thumbColor = theme.colors.scrollbarThumbColor;

    return ListenableBuilder(
      listenable: widget.offset,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackLength = _isVertical
                ? constraints.maxHeight
                : constraints.maxWidth;

            if (trackLength == 0 || widget.maxScroll <= 0) {
              return _isVertical
                  ? Container(width: trackSize, color: trackColor)
                  : Container(height: trackSize, color: trackColor);
            }

            final ratio = widget.viewportExtent / widget.contentExtent;
            final thumbLength = (ratio * trackLength).clamp(
              thumbMinSize,
              trackLength,
            );
            final scrollableTrack = trackLength - thumbLength;
            final thumbOffset = widget.maxScroll > 0
                ? (widget.offset.value / widget.maxScroll) * scrollableTrack
                : 0.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (_isDragging) return;
                final tapPos = _isVertical
                    ? details.localPosition.dy
                    : details.localPosition.dx;
                final targetThumb = (tapPos - thumbLength / 2).clamp(
                  0.0,
                  scrollableTrack,
                );
                widget.offset.value = scrollableTrack > 0
                    ? (targetThumb / scrollableTrack) * widget.maxScroll
                    : 0.0;
              },
              onVerticalDragStart: _isVertical ? _onDragStart : null,
              onVerticalDragUpdate: _isVertical ? _onDragUpdate : null,
              onVerticalDragEnd: _isVertical ? _onDragEnd : null,
              onHorizontalDragStart: !_isVertical ? _onDragStart : null,
              onHorizontalDragUpdate: !_isVertical ? _onDragUpdate : null,
              onHorizontalDragEnd: !_isVertical ? _onDragEnd : null,
              child: Container(
                width: _isVertical ? trackSize : null,
                height: !_isVertical ? trackSize : null,
                decoration: BoxDecoration(
                  color: trackColor,
                  border: _isVertical
                      ? Border(left: theme.borders.scrollbarBorder.left)
                      : Border(top: theme.borders.scrollbarBorder.top),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      top: _isVertical ? thumbOffset : thumbInset,
                      left: _isVertical ? thumbInset : thumbOffset,
                      right: _isVertical ? thumbInset : null,
                      bottom: !_isVertical ? thumbInset : null,
                      child: Container(
                        width: _isVertical ? null : thumbLength,
                        height: _isVertical ? thumbLength : null,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          borderRadius: BorderRadius.circular(
                            (trackSize - thumbInset * 2) / 2,
                          ),
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
