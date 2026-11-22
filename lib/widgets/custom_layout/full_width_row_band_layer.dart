import 'package:material_ui/material_ui.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';
import 'package:flutter_data_grid/widgets/custom_layout/row_metrics.dart';

/// Builds the full-width band widget for [entry] at [rowIndex], or `null` if
/// this row should render as ordinary cells instead (no band overlay).
typedef RowBandBuilder<T extends DataGridRow> =
    Widget? Function(GridDisplayRow<T> entry, int rowIndex);

/// Renders full-width band widgets as an overlay spanning both the pinned
/// and unpinned quadrants, virtualized the same way those quadrants are
/// (scroll repositioning via [GridLayoutDelegate] alone, widget rebuilds only
/// when the visible row range changes).
///
/// Row grouping is the first consumer ([bandBuilder] returning a group header
/// band for [GridGroupHeaderRow] slots), but this layer doesn't know that —
/// any future row kind that needs full-width, non-cell content (e.g. a
/// collapsible section header) can reuse it by supplying a different
/// [bandBuilder].
class FullWidthRowBandLayer<T extends DataGridRow> extends StatefulWidget {
  final List<GridDisplayRow<T>> rows;
  final double viewportWidth;
  final double viewportHeight;
  final RowMetrics rowMetrics;
  final double cacheExtent;
  final ValueNotifier<double> vOffset;
  final RowBandBuilder<T> bandBuilder;

  /// Bumped whenever a batch of row-height measurements has been applied.
  /// Non-null only when auto row height is enabled. Bands are fixed-height
  /// themselves, but their *position* shifts when rows above them change
  /// height, so this layer needs to react too, not just the cell quadrants.
  final ValueNotifier<int>? rowHeightVersion;

  const FullWidthRowBandLayer({
    super.key,
    required this.rows,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.rowMetrics,
    required this.cacheExtent,
    required this.vOffset,
    required this.bandBuilder,
    this.rowHeightVersion,
  });

  @override
  State<FullWidthRowBandLayer<T>> createState() =>
      _FullWidthRowBandLayerState<T>();
}

class _FullWidthRowBandLayerState<T extends DataGridRow>
    extends State<FullWidthRowBandLayer<T>> {
  int _firstRow = 0;
  int _lastRow = 0;

  /// Caches band widget instances by row, so a range shift reuses the identical
  /// instance for carry-over bands and Flutter skips their [build] entirely —
  /// the same trick the cell quadrants use for [LayoutGridCell].
  final Map<CellLayoutId, Widget> _bandCache = {};

  List<Widget> _children = const [];
  List<CellLayoutId> _cellIds = const [];
  Map<int, ColumnSpan> _columnSpans = const {};

  /// See the equivalent field in GridUnpinnedQuadrant.
  late Listenable _relayout;

  @override
  void initState() {
    super.initState();
    _computeRowRange();
    _rebuildBandList();
    widget.vOffset.addListener(_onVOffsetChanged);
    widget.rowHeightVersion?.addListener(_onRowHeightVersionChanged);
    _relayout = GridLayoutDelegate.buildRelayout(vOffset: widget.vOffset);
  }

  @override
  void didUpdateWidget(FullWidthRowBandLayer<T> old) {
    super.didUpdateWidget(old);

    if (!identical(old.vOffset, widget.vOffset)) {
      old.vOffset.removeListener(_onVOffsetChanged);
      widget.vOffset.addListener(_onVOffsetChanged);
    }
    if (!identical(old.rowHeightVersion, widget.rowHeightVersion)) {
      old.rowHeightVersion?.removeListener(_onRowHeightVersionChanged);
      widget.rowHeightVersion?.addListener(_onRowHeightVersionChanged);
    }
    if (!identical(old.vOffset, widget.vOffset)) {
      _relayout = GridLayoutDelegate.buildRelayout(vOffset: widget.vOffset);
    }

    final contentChanged =
        !identical(old.rows, widget.rows) ||
        !identical(old.bandBuilder, widget.bandBuilder);
    if (contentChanged) {
      _bandCache.clear();
    }

    final geometryChanged =
        old.viewportHeight != widget.viewportHeight ||
        old.viewportWidth != widget.viewportWidth ||
        old.rowMetrics != widget.rowMetrics ||
        old.cacheExtent != widget.cacheExtent;
    if (geometryChanged || contentChanged) {
      _computeRowRange();
      _rebuildBandList();
    }
  }

  @override
  void dispose() {
    widget.vOffset.removeListener(_onVOffsetChanged);
    widget.rowHeightVersion?.removeListener(_onRowHeightVersionChanged);
    super.dispose();
  }

  void _computeRowRange() {
    final vScroll = widget.vOffset.value;
    final rowCount = widget.rows.length;

    final rowRange = widget.rowMetrics.visibleRowRange(
      scrollOffset: vScroll,
      viewportExtent: widget.viewportHeight,
      cacheExtent: widget.cacheExtent,
      rowCount: rowCount,
    );

    _firstRow = rowRange.firstRow;
    _lastRow = rowRange.lastRow;
  }

  void _rebuildBandList() {
    final cellIds = <CellLayoutId>[];
    final nextCache = <CellLayoutId, Widget>{};
    final children = <Widget>[];

    for (int row = _firstRow; row < _lastRow; row++) {
      if (row < 0 || row >= widget.rows.length) continue;

      final cellId = CellLayoutId(row, 0);

      // Reuse the cached instance for carry-over bands; only rows newly
      // entering the window are handed to bandBuilder.
      var entry = _bandCache[cellId];
      if (entry == null) {
        final band = widget.bandBuilder(widget.rows[row], row);
        if (band == null) continue;
        entry = LayoutId(key: ValueKey(cellId), id: cellId, child: band);
      }

      nextCache[cellId] = entry;
      cellIds.add(cellId);
      children.add(entry);
    }

    _bandCache
      ..clear()
      ..addAll(nextCache);

    // Bands span the full viewport width and don't scroll horizontally, so a
    // single span covers every one of them.
    _columnSpans = {0: ColumnSpan(0, widget.viewportWidth)};
    _cellIds = cellIds;
    _children = children;
  }

  /// Called on every scroll frame; only rebuilds when the window actually moved.
  void _onVOffsetChanged() {
    final newFirst = _firstRow;
    final newLast = _lastRow;
    _computeRowRange();
    if (_firstRow != newFirst || _lastRow != newLast) {
      setState(_rebuildBandList);
    }
  }

  void _onRowHeightVersionChanged() {
    // Band positions are resolved at layout time; the bumped
    // rowMetricsVersion forces the relayout. Rebuild only if the window moved.
    final prevFirst = _firstRow;
    final prevLast = _lastRow;
    _computeRowRange();
    setState(() {
      if (_firstRow != prevFirst || _lastRow != prevLast) _rebuildBandList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) return const SizedBox.shrink();

    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: GridLayoutDelegate(
          cellIds: _cellIds,
          columnSpans: _columnSpans,
          rowMetrics: widget.rowMetrics,
          rowMetricsVersion: widget.rowHeightVersion?.value ?? 0,
          vOffset: widget.vOffset,
          relayout: _relayout,
        ),
        children: _children,
      ),
    );
  }
}
