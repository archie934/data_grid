import 'package:flutter/material.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// Vertical scrollbar driven by a [ScrollController].
class VerticalDataGridScrollbar extends StatefulWidget {
  final ScrollController controller;

  const VerticalDataGridScrollbar({super.key, required this.controller});

  @override
  State<VerticalDataGridScrollbar> createState() =>
      _VerticalDataGridScrollbarState();
}

class _VerticalDataGridScrollbarState extends State<VerticalDataGridScrollbar> {
  double? _dragStart;
  double? _dragStartThumb;
  bool _isDragging = false;

  void _onDragStart(double position, double thumbOffset) {
    _isDragging = true;
    _dragStart = position;
    _dragStartThumb = thumbOffset;
  }

  void _onDragUpdate(
    double position,
    double scrollableTrack,
    double maxScroll,
  ) {
    final start = _dragStart;
    final startThumb = _dragStartThumb;
    if (start == null || startThumb == null) return;
    final newThumb = (startThumb + position - start).clamp(
      0.0,
      scrollableTrack,
    );
    widget.controller.jumpTo(
      scrollableTrack > 0 ? (newThumb / scrollableTrack) * maxScroll : 0.0,
    );
  }

  void _onDragEnd() {
    _dragStart = null;
    _dragStartThumb = null;
    if (mounted) _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final trackSize = theme.dimensions.scrollbarWidth;
    final thumbMinSize = theme.dimensions.scrollbarThumbMinSize;
    final thumbInset = theme.padding.scrollbarThumbInset;
    final trackColor = theme.colors.scrollbarTrackColor;
    final thumbColor = theme.colors.scrollbarThumbColor;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!widget.controller.hasClients) return const SizedBox.shrink();

        final pos = widget.controller.position;
        final maxScroll = pos.maxScrollExtent;
        final viewport = pos.viewportDimension;

        if (viewport == 0 || maxScroll <= 0) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final trackLength = constraints.maxHeight;
            if (trackLength == 0) return const SizedBox.shrink();

            final scrollOffset = pos.pixels.clamp(0.0, maxScroll);
            final thumbLength =
                ((viewport / (viewport + maxScroll)) * trackLength).clamp(
                  thumbMinSize,
                  trackLength,
                );
            final scrollableTrack = trackLength - thumbLength;
            final thumbOffset = maxScroll > 0
                ? (scrollOffset / maxScroll) * scrollableTrack
                : 0.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                if (_isDragging) return;
                final target = (d.localPosition.dy - thumbLength / 2).clamp(
                  0.0,
                  scrollableTrack,
                );
                widget.controller.animateTo(
                  scrollableTrack > 0
                      ? (target / scrollableTrack) * maxScroll
                      : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              },
              onVerticalDragStart: (d) =>
                  _onDragStart(d.localPosition.dy, thumbOffset),
              onVerticalDragUpdate: (d) =>
                  _onDragUpdate(d.localPosition.dy, scrollableTrack, maxScroll),
              onVerticalDragEnd: (_) => _onDragEnd(),
              child: Container(
                width: trackSize,
                decoration: BoxDecoration(
                  color: trackColor,
                  border: Border(left: theme.borders.scrollbarBorder.left),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      top: thumbOffset,
                      left: thumbInset,
                      right: thumbInset,
                      child: Container(
                        height: thumbLength,
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
