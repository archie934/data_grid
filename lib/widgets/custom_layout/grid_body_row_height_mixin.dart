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
///
/// Notifying quadrants after a patch is dispatched via [_rowHeightVersion],
/// a targeted [ValueNotifier] each quadrant listens to directly and reacts
/// to with its own local `setState` — never via a `setState` on
/// [CustomLayoutGridBody] itself. That keeps this path consistent with the
/// two-layer scroll trick (see AGENTS.md): most frames still touch no widget
/// tree at all, and even a frame that does needs a patch only rebuilds the
/// quadrants that are actually listening, not the whole grid body.
mixin _GridBodyRowHeightMixin<T extends DataGridRow>
    on State<CustomLayoutGridBody<T>>, _GridBodyScrollMixin<T> {
  final Map<int, double> _pendingRowMeasurements = {};
  bool _rowMeasurementScheduled = false;

  /// Bumped once per applied measurement batch (auto mode only). Quadrants
  /// listen directly and do their own local setState + cell/band-list
  /// rebuild — this never triggers [CustomLayoutGridBody]'s `build()`.
  final ValueNotifier<int> _rowHeightVersion = ValueNotifier(0);

  void _rowHeightMixinDispose() => _rowHeightVersion.dispose();

  /// Exposed to quadrants only when auto mode is active — mirrors
  /// [_buildRowHeightMeasurement]'s null-when-disabled pattern.
  ValueNotifier<int>? get _rowHeightVersionOrNull =>
      widget.autoRowHeight != null ? _rowHeightVersion : null;

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

    // Refresh _maxVScroll/scrollbar dimensions from the freshly-patched
    // delegate without re-running CustomLayoutGridBody's LayoutBuilder.
    final wasVScrollable = _maxVScroll > 0;
    _resyncScrollExtent(delegate.totalExtent);

    if ((_maxVScroll > 0) != wasVScrollable) {
      // The vertical scrollbar's presence in the widget tree is gated on
      // `_maxVScroll > 0` inside CustomLayoutGridBody.build() (a conditional
      // Positioned child, not something a relayout listener can toggle) — so
      // this is the one case that still needs a full body rebuild. It only
      // fires when total content height crosses the viewport-height
      // threshold, not on every corrective frame, so it isn't a fling-jank
      // contributor.
      setState(() {});
      return;
    }

    // Notify quadrants directly. Each has its own listener that does a local
    // setState + _rebuildCellList()/_rebuildBandList() — this never reaches
    // CustomLayoutGridBody's build().
    _rowHeightVersion.value++;
  }
}
