import 'package:flutter/material.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// Horizontal scrollbar driven by a [ScrollController].
class HorizontalDataGridScrollbar extends StatefulWidget {
  final ScrollController controller;

  const HorizontalDataGridScrollbar({super.key, required this.controller});

  @override
  State<HorizontalDataGridScrollbar> createState() =>
      _HorizontalDataGridScrollbarState();
}

class _HorizontalDataGridScrollbarState
    extends State<HorizontalDataGridScrollbar> {
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
    final trackSize = theme.dimensions.scrollbarHeight;
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
            final trackLength = constraints.maxWidth;
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
                final target = (d.localPosition.dx - thumbLength / 2).clamp(
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
              onHorizontalDragStart: (d) =>
                  _onDragStart(d.localPosition.dx, thumbOffset),
              onHorizontalDragUpdate: (d) =>
                  _onDragUpdate(d.localPosition.dx, scrollableTrack, maxScroll),
              onHorizontalDragEnd: (_) => _onDragEnd(),
              child: Container(
                height: trackSize,
                decoration: BoxDecoration(
                  color: trackColor,
                  border: Border(top: theme.borders.scrollbarBorder.top),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      top: thumbInset,
                      left: thumbOffset,
                      bottom: thumbInset,
                      child: Container(
                        width: thumbLength,
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
