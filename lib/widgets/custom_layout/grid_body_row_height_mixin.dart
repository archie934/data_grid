part of 'custom_layout_grid_body.dart';

/// Auto-row-height measurement batching and scroll-anchor correction.
///
/// Individual cells report measured heights (via [GridLayoutDelegate]'s
/// [RowHeightMeasurement] hook) as they're laid out; this mixin batches every
/// report from a single frame and applies them together in one post-frame
/// callback — so a fling that reveals 20 new rows produces one patch to the
/// [RowHeightDelegate] and one scroll-offset correction, not 20.
///
/// The correction itself is the standard fix for the "dynamic-extent
/// virtualized list" jump problem: rows whose content-space offset was above
/// the current viewport top get their height delta summed and applied as a
/// single [_vOffset] adjustment, so on-screen content doesn't visibly jump.
/// Rows at or below the viewport are left to reflow (expected — the same way
/// a web page reflows when an image loads).
mixin _GridBodyRowHeightMixin<T extends DataGridRow>
    on State<CustomLayoutGridBody<T>>, _GridBodyScrollMixin<T> {
  final Map<int, double> _pendingRowMeasurements = {};
  bool _rowMeasurementScheduled = false;

  /// Builds the [RowHeightMeasurement] hook for this frame's quadrants, or
  /// `null` when auto row-height isn't enabled.
  RowHeightMeasurement? _buildRowHeightMeasurement(RowMetrics rowMetrics) {
    final autoRowHeight = widget.autoRowHeight;
    if (autoRowHeight == null || rowMetrics is! AutoRowMetrics) return null;

    return RowHeightMeasurement(
      delegate: rowMetrics.delegate,
      maxHeightClamp: autoRowHeight.maxHeight,
      onMeasured: _onRowMeasured,
    );
  }

  void _onRowMeasured(int row, double measuredHeight) {
    final current = _pendingRowMeasurements[row];
    if (current == null || measuredHeight > current) {
      _pendingRowMeasurements[row] = measuredHeight;
    }
    if (!_rowMeasurementScheduled) {
      _rowMeasurementScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => _applyPendingRowMeasurements(),
      );
    }
  }

  void _applyPendingRowMeasurements() {
    _rowMeasurementScheduled = false;
    if (_pendingRowMeasurements.isEmpty) return;

    final entries = _pendingRowMeasurements.entries.toList();
    _pendingRowMeasurements.clear();

    if (!mounted) return;
    final autoRowHeight = widget.autoRowHeight;
    final rowMetrics = widget.rowMetrics;
    if (autoRowHeight == null || rowMetrics is! AutoRowMetrics) return;

    final delegate = rowMetrics.delegate;
    final vScroll = _vOffset.value;
    double deltaAboveViewport = 0;
    bool anyChanged = false;

    for (final entry in entries) {
      final row = entry.key;
      final clamped = entry.value.clamp(
        autoRowHeight.minHeight,
        autoRowHeight.maxHeight,
      );
      final preOffset = delegate.offsetOf(row);
      final preHeight = delegate.heightOf(row);
      if (!delegate.reportMeasured(row, clamped)) continue;

      anyChanged = true;
      if (preOffset < vScroll) {
        deltaAboveViewport += clamped - preHeight;
      }
    }

    if (!anyChanged) return;

    if (deltaAboveViewport != 0) {
      _vOffset.value = (_vOffset.value + deltaAboveViewport).clamp(
        0.0,
        double.infinity,
      );
    }

    // Re-run build(): recomputes totalHeight/_maxVScroll from the just-patched
    // delegate and forces every quadrant's didUpdateWidget (which always
    // rebuilds _contentRects) to pick up the new offsets/heights.
    setState(() {});
  }
}
