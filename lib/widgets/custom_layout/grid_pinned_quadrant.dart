import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/custom_layout/layout_grid_cell.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';

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
  final double rowHeight;
  final double cacheExtent;
  final Color backgroundColor;
  final ValueNotifier<double> vOffset;

  const GridPinnedQuadrant({
    super.key,
    required this.columns,
    required this.pinnedIndices,
    required this.viewportHeight,
    required this.rows,
    required this.rowsById,
    required this.rowCount,
    required this.rowHeight,
    required this.cacheExtent,
    required this.backgroundColor,
    required this.vOffset,
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
  //
  // Note there is no per-cell rect here: a cell's x/width comes from its
  // column's [ColumnSpan] and its y/height from [rowHeight], both resolved at
  // layout time, so scrolling costs zero widget work.
  List<Widget> _children = const [];
  List<CellLayoutId> _cellIds = const [];
  Map<int, ColumnSpan> _columnSpans = const {};

  /// See the equivalent field in GridUnpinnedQuadrant.
  late Listenable _relayout;

  /// See the equivalent fields in GridUnpinnedQuadrant.
  double _lastRangeVScroll = 0;
  bool _jumped = false;

  @override
  void initState() {
    super.initState();
    _computeRowRange();
    _rebuildCellList();
    widget.vOffset.addListener(_onVOffsetChanged);
    _relayout = GridLayoutDelegate.buildRelayout(vOffset: widget.vOffset);
  }

  @override
  void didUpdateWidget(GridPinnedQuadrant<T> old) {
    super.didUpdateWidget(old);

    if (!identical(old.vOffset, widget.vOffset)) {
      old.vOffset.removeListener(_onVOffsetChanged);
      widget.vOffset.addListener(_onVOffsetChanged);
    }
    if (!identical(old.vOffset, widget.vOffset)) {
      _relayout = GridLayoutDelegate.buildRelayout(vOffset: widget.vOffset);
    }

    // Clear cache when content-affecting parameters change.
    final contentChanged =
        !identical(old.rowsById, widget.rowsById) ||
        !identical(old.rows, widget.rows) ||
        !identical(old.columns, widget.columns) ||
        !identical(old.pinnedIndices, widget.pinnedIndices);
    if (contentChanged) {
      _cellCache.clear();
    }

    // Recompute row range when structural parameters change.
    final geometryChanged =
        old.viewportHeight != widget.viewportHeight ||
        old.rowHeight != widget.rowHeight ||
        old.rowCount != widget.rowCount ||
        old.cacheExtent != widget.cacheExtent;
    if (geometryChanged || contentChanged) {
      _computeRowRange();
    }

    // Only when something it derives from moved — see the equivalent comment
    // in GridUnpinnedQuadrant: an unconditional rebuild forces a relayout via
    // GridLayoutDelegate.shouldRelayout's identity check.
    if (geometryChanged || contentChanged) {
      _rebuildCellList();
    }
  }

  @override
  void dispose() {
    widget.vOffset.removeListener(_onVOffsetChanged);
    super.dispose();
  }

  // ---------------------------------------------------------------------------

  void _computeRowRange() {
    final vScroll = widget.vOffset.value;
    // See GridUnpinnedQuadrant._computeRange: on a discontinuous frame the
    // cache-extent buffer can't prefetch anything, so it's skipped.
    final jumped =
        (vScroll - _lastRangeVScroll).abs() >= widget.viewportHeight &&
        widget.viewportHeight > 0;
    _lastRangeVScroll = vScroll;
    _jumped = jumped;

    final rowRange = visibleRowRange(
      scrollOffset: vScroll,
      viewportExtent: widget.viewportHeight,
      cacheExtent: jumped ? 0.0 : widget.cacheExtent,
      rowHeight: widget.rowHeight,
      rowCount: widget.rowCount,
    );

    _firstRow = rowRange.firstRow;
    _lastRow = rowRange.lastRow;
  }

  /// Computes [_children], [_cellIds] and [_columnSpans] for the current row
  /// range.
  ///
  /// Carry-over cells are reused from [_cellCache]; new cells are created and
  /// added to the cache. Cells that are no longer visible are evicted.
  ///
  /// Vertical geometry is deliberately *not* computed here — [GridLayoutDelegate]
  /// derives each row's y from its index during layout, so this only has to run
  /// when the set of built cells changes.
  void _rebuildCellList() {
    final jumped = _jumped;
    final columnSpans = <int, ColumnSpan>{};
    final cellIds = <CellLayoutId>[];
    final nextCache = <CellLayoutId, Widget>{};
    final children = <Widget>[];

    double xOffset = 0;
    for (final colIndex in widget.pinnedIndices) {
      if (colIndex < 0 || colIndex >= widget.columns.length) continue;

      final colWidth = widget.columns[colIndex].width;
      final column = widget.columns[colIndex];

      columnSpans[colIndex] = ColumnSpan(xOffset, colWidth);

      for (int row = _firstRow; row < _lastRow; row++) {
        if (row < 0 || row >= widget.rows.length) continue;

        final entry = widget.rows[row];
        if (entry is! GridDataRow<T>) continue; // group header band

        final rowId = entry.rowId;
        final rowData = widget.rowsById[rowId];
        if (rowData == null) continue;

        final cellId = CellLayoutId(row, colIndex);

        // Reuse the cached LayoutId for carry-over cells. Flutter detects the
        // identical instance and skips build() for that element entirely.
        // On a jump frame nothing carries over, so cells are keyed by slot
        // instead — see GridUnpinnedQuadrant._buildCell for the full rationale.
        final Widget cell;
        final cached = jumped ? null : _cellCache[cellId];
        if (cached != null) {
          cell = cached;
        } else {
          final key = jumped
              ? ValueKey(CellLayoutId(row - _firstRow, colIndex))
              : ValueKey(cellId);
          cell = LayoutId(
            key: key,
            id: cellId,
            child: LayoutGridCell<T>(
              key: jumped ? key : ValueKey('cell_${rowId}_${column.id}'),
              row: rowData,
              rowId: rowId,
              column: column,
              rowIndex: row,
            ),
          );
        }

        if (!jumped) nextCache[cellId] = cell;
        cellIds.add(cellId);
        children.add(cell);
      }

      xOffset += colWidth;
    }

    _cellCache
      ..clear()
      ..addAll(nextCache);

    _columnSpans = columnSpans;
    _cellIds = cellIds;
    _children = children;
  }

  /// Called on every scroll frame; only rebuilds when the window actually moved.
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
            cellIds: _cellIds,
            columnSpans: _columnSpans,
            rowHeight: widget.rowHeight,
            vOffset: widget.vOffset,
            relayout: _relayout,
            // hOffset intentionally omitted: pinned columns don't scroll horizontally.
          ),
          children: _children,
        ),
      ),
    );
  }
}
