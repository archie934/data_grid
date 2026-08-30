import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/custom_layout/layout_grid_cell.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';
import 'package:flutter_data_grid/widgets/custom_layout/row_metrics.dart';

/// Renders the pinned (frozen) columns quadrant of the custom layout grid.
///
/// Only listens to [vOffset]; horizontal scrolling never affects this quadrant.
/// Widget rebuilds are restricted to frames where the visible *row* range
/// changes (a row enters or leaves the viewport). Repositioning within the
/// same row range is handled entirely by [GridLayoutDelegate.relayout].
/// Carry-over cells are served from [_cellCache] (identical widget instances)
/// so Flutter skips their [build] call even during set-change rebuilds.
class GridPinnedQuadrant<T extends DataGridRow> extends StatefulWidget {
  final List<DataGridColumn<T>> columns;
  final List<int> pinnedIndices;
  final double viewportHeight;
  final List<GridDisplayRow<T>> rows;
  final Map<double, T> rowsById;
  final int rowCount;
  final RowMetrics rowMetrics;
  final double cacheExtent;
  final Color backgroundColor;
  final ValueNotifier<double> vOffset;
  final RowHeightMeasurement? measurement;

  const GridPinnedQuadrant({
    super.key,
    required this.columns,
    required this.pinnedIndices,
    required this.viewportHeight,
    required this.rows,
    required this.rowsById,
    required this.rowCount,
    required this.rowMetrics,
    required this.cacheExtent,
    required this.backgroundColor,
    required this.vOffset,
    this.measurement,
  });

  @override
  State<GridPinnedQuadrant<T>> createState() => _GridPinnedQuadrantState<T>();
}

class _GridPinnedQuadrantState<T extends DataGridRow>
    extends State<GridPinnedQuadrant<T>> {
  int _firstRow = 0;
  int _lastRow = 0;

  /// Caches [LayoutId] widget instances by cell identity.
  ///
  /// Carry-over cells reuse the identical instance so Flutter detects
  /// `child.widget == newWidget` and skips their [build] call entirely.
  final Map<CellLayoutId, Widget> _cellCache = {};

  // Pre-computed state consumed by build(). Updated by _rebuildCellList().
  List<Widget> _children = const [];
  Map<CellLayoutId, Rect> _contentRects = const {};

  @override
  void initState() {
    super.initState();
    _computeRowRange();
    _rebuildCellList();
    widget.vOffset.addListener(_onVOffsetChanged);
  }

  @override
  void didUpdateWidget(GridPinnedQuadrant<T> old) {
    super.didUpdateWidget(old);

    if (!identical(old.vOffset, widget.vOffset)) {
      old.vOffset.removeListener(_onVOffsetChanged);
      widget.vOffset.addListener(_onVOffsetChanged);
    }

    // Clear cache when content-affecting parameters change.
    if (!identical(old.rowsById, widget.rowsById) ||
        !identical(old.rows, widget.rows) ||
        !identical(old.columns, widget.columns) ||
        !identical(old.pinnedIndices, widget.pinnedIndices)) {
      _cellCache.clear();
    }

    // Recompute row range when structural parameters change.
    if (old.viewportHeight != widget.viewportHeight ||
        old.rowMetrics != widget.rowMetrics ||
        old.rowCount != widget.rowCount ||
        old.cacheExtent != widget.cacheExtent) {
      _computeRowRange();
    }

    // Always rebuild the cell list — build() reads _children / _contentRects
    // directly, so they must be current before the framework calls build().
    _rebuildCellList();
  }

  @override
  void dispose() {
    widget.vOffset.removeListener(_onVOffsetChanged);
    super.dispose();
  }

  // ---------------------------------------------------------------------------

  void _computeRowRange() {
    final vScroll = widget.vOffset.value;
    final rowRange = widget.rowMetrics.visibleRowRange(
      scrollOffset: vScroll,
      viewportExtent: widget.viewportHeight,
      cacheExtent: widget.cacheExtent,
      rowCount: widget.rowCount,
    );

    _firstRow = rowRange.firstRow;
    _lastRow = rowRange.lastRow;
  }

  /// Computes [_children] and [_contentRects] for the current row range.
  ///
  /// Carry-over cells are reused from [_cellCache]; new cells are created and
  /// added to the cache. Cells that are no longer visible are evicted.
  void _rebuildCellList() {
    final contentRects = <CellLayoutId, Rect>{};
    final nextCache = <CellLayoutId, Widget>{};
    final children = <Widget>[];

    double xOffset = 0;
    for (final colIndex in widget.pinnedIndices) {
      if (colIndex < 0 || colIndex >= widget.columns.length) continue;

      final colWidth = widget.columns[colIndex].width;
      final column = widget.columns[colIndex];

      for (int row = _firstRow; row < _lastRow; row++) {
        if (row < 0 || row >= widget.rows.length) continue;

        final entry = widget.rows[row];
        if (entry is! GridDataRow<T>) continue; // group header band

        final rowId = entry.rowId;
        final rowData = widget.rowsById[rowId];
        if (rowData == null) continue;

        final cellId = CellLayoutId(row, colIndex);

        contentRects[cellId] = Rect.fromLTWH(
          xOffset,
          widget.rowMetrics.offsetOf(row),
          colWidth,
          widget.rowMetrics.heightOf(row),
        );

        // Reuse the cached LayoutId for carry-over cells. Flutter detects the
        // identical instance and skips build() for that element entirely.
        final cell =
            _cellCache[cellId] ??
            LayoutId(
              key: ValueKey(cellId),
              id: cellId,
              child: LayoutGridCell<T>(
                key: ValueKey('cell_${rowId}_${column.id}'),
                row: rowData,
                rowId: rowId,
                column: column,
                rowIndex: row,
              ),
            );

        nextCache[cellId] = cell;
        children.add(cell);
      }

      xOffset += colWidth;
    }

    _cellCache
      ..clear()
      ..addAll(nextCache);

    _contentRects = contentRects;
    _children = children;
  }

  void _onVOffsetChanged() {
    final prevFirst = _firstRow;
    final prevLast = _lastRow;
    _computeRowRange();
    if (_firstRow != prevFirst || _lastRow != prevLast) {
      setState(_rebuildCellList);
    }
    // else: same rows, different position — GridLayoutDelegate.relayout
    // fires markNeedsLayout without touching the widget tree.
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) return const SizedBox.expand();

    return ClipRect(
      child: ColoredBox(
        color: widget.backgroundColor,
        child: CustomMultiChildLayout(
          delegate: GridLayoutDelegate(
            contentRects: _contentRects,
            vOffset: widget.vOffset,
            // hOffset intentionally omitted: pinned columns don't scroll horizontally.
            measurement: widget.measurement,
          ),
          children: _children,
        ),
      ),
    );
  }
}
