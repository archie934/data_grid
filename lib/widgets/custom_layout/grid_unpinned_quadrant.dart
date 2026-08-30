import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/custom_layout/layout_grid_cell.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';

/// Tracks which row and column index ranges are currently inside the viewport
/// (including cache extent buffer). Used to detect when the visible cell set
/// changes so a widget rebuild can be triggered.
class _VisibleRange {
  final int firstRow;
  final int lastRow;
  final int firstColIdx;
  final int lastColIdx;

  const _VisibleRange(
    this.firstRow,
    this.lastRow,
    this.firstColIdx,
    this.lastColIdx,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _VisibleRange &&
          firstRow == other.firstRow &&
          lastRow == other.lastRow &&
          firstColIdx == other.firstColIdx &&
          lastColIdx == other.lastColIdx;

  @override
  int get hashCode => Object.hash(firstRow, lastRow, firstColIdx, lastColIdx);
}

/// Renders the scrollable (unpinned) quadrant of the custom layout grid.
///
/// Scroll-driven updates are handled in two separate layers to avoid
/// unnecessary widget rebuilds:
///
/// * **Widget layer** ([setState]): called only when the *set* of visible
///   cells changes (a row or column enters / leaves the viewport). Carry-over
///   cells are reused from [_cellCache] — Flutter detects the identical widget
///   instance and skips their [build] call entirely.
///
/// * **RenderObject layer** ([GridLayoutDelegate.relayout]): fires on every
///   [hOffset] / [vOffset] change and calls [markNeedsLayout] on the render
///   object directly, so [performLayout] repositions children without touching
///   the widget tree at all.
///
/// Result: most scroll frames produce **zero** hot widget rebuilds, and even
/// boundary-crossing frames (cells entering / leaving) produce zero carry-over
/// rebuilds.
class GridUnpinnedQuadrant<T extends DataGridRow> extends StatefulWidget {
  final List<DataGridColumn<T>> columns;
  final List<int> unpinnedIndices;
  final double pinnedWidth;
  final double viewportWidth;
  final double viewportHeight;
  final List<GridDisplayRow<T>> rows;
  final Map<double, T> rowsById;
  final int rowCount;
  final double rowHeight;
  final double cacheExtent;
  final ValueNotifier<double> hOffset;
  final ValueNotifier<double> vOffset;

  const GridUnpinnedQuadrant({
    super.key,
    required this.columns,
    required this.unpinnedIndices,
    required this.pinnedWidth,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.rows,
    required this.rowsById,
    required this.rowCount,
    required this.rowHeight,
    required this.cacheExtent,
    required this.hOffset,
    required this.vOffset,
  });

  @override
  State<GridUnpinnedQuadrant<T>> createState() =>
      _GridUnpinnedQuadrantState<T>();
}

class _GridUnpinnedQuadrantState<T extends DataGridRow>
    extends State<GridUnpinnedQuadrant<T>> {
  late _VisibleRange _visibleRange;

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

  /// Long-lived so the render object doesn't rebind markNeedsLayout to both
  /// offset notifiers on every build.
  late Listenable _relayout;

  // -- Discontinuous-frame ("jump") tracking ---------------------------------
  // The vertical offset the last window was computed for, and whether the move
  // since then skipped past the whole viewport. Dragging the scrollbar thumb on
  // a large grid is the pathological case: with a ~500px track over 100k rows,
  // 2px of thumb travel is ~390 rows, so *every* drag frame lands on a row
  // window that shares nothing with the previous one. See _rebuildCellList.
  double _lastRangeVScroll = 0;
  bool _jumped = false;

  // Memo for the column half of _computeRange — see the comment there.
  int _colRangeFirst = 0;
  int _colRangeLast = 0;
  double _colRangeHScroll = double.nan;
  double _colRangeViewportWidth = double.nan;
  double _colRangePinnedWidth = double.nan;
  double _colRangeCacheExtent = double.nan;
  List<DataGridColumn<T>>? _colRangeColumnsRef;
  List<int>? _colRangeIndicesRef;

  @override
  void initState() {
    super.initState();
    _visibleRange = _computeRange();
    _rebuildCellList();
    widget.hOffset.addListener(_onOffsetChanged);
    widget.vOffset.addListener(_onOffsetChanged);
    _relayout = GridLayoutDelegate.buildRelayout(
      hOffset: widget.hOffset,
      vOffset: widget.vOffset,
    );
  }

  @override
  void didUpdateWidget(GridUnpinnedQuadrant<T> old) {
    super.didUpdateWidget(old);

    if (!identical(old.hOffset, widget.hOffset)) {
      old.hOffset.removeListener(_onOffsetChanged);
      widget.hOffset.addListener(_onOffsetChanged);
    }
    if (!identical(old.vOffset, widget.vOffset)) {
      old.vOffset.removeListener(_onOffsetChanged);
      widget.vOffset.addListener(_onOffsetChanged);
    }
    if (!identical(old.hOffset, widget.hOffset) ||
        !identical(old.vOffset, widget.vOffset)) {
      _relayout = GridLayoutDelegate.buildRelayout(
        hOffset: widget.hOffset,
        vOffset: widget.vOffset,
      );
    }

    // Clear cache when content-affecting parameters change.
    final contentChanged =
        !identical(old.rowsById, widget.rowsById) ||
        !identical(old.rows, widget.rows) ||
        !identical(old.columns, widget.columns) ||
        !identical(old.unpinnedIndices, widget.unpinnedIndices);
    if (contentChanged) {
      _cellCache.clear();
    }

    // Recompute visible range when structural parameters change.
    final geometryChanged =
        old.viewportWidth != widget.viewportWidth ||
        old.viewportHeight != widget.viewportHeight ||
        old.pinnedWidth != widget.pinnedWidth ||
        old.rowHeight != widget.rowHeight ||
        old.rowCount != widget.rowCount ||
        old.cacheExtent != widget.cacheExtent;
    if (geometryChanged || contentChanged) {
      _visibleRange = _computeRange();
    }

    // Only when something it derives from moved. _rebuildCellList allocates a
    // new _cellIds/_columnSpans, and GridLayoutDelegate.shouldRelayout compares
    // those by identity — so rebuilding unconditionally forced a full relayout
    // of the quadrant on every single build.
    if (geometryChanged || contentChanged) {
      _rebuildCellList();
    }
  }

  @override
  void dispose() {
    widget.hOffset.removeListener(_onOffsetChanged);
    widget.vOffset.removeListener(_onOffsetChanged);
    super.dispose();
  }

  // ---------------------------------------------------------------------------

  _VisibleRange _computeRange() {
    final hScroll = widget.hOffset.value;
    final vScroll = widget.vOffset.value;
    final effectiveCacheExtent = kDebugMode
        ? widget.cacheExtent.clamp(0.0, 500.0)
        : widget.cacheExtent;

    // A move larger than the viewport can't share a single row with the
    // previous window.
    final jumped =
        (vScroll - _lastRangeVScroll).abs() >= widget.viewportHeight &&
        widget.viewportHeight > 0;
    _lastRangeVScroll = vScroll;
    _jumped = jumped;

    // Row range. The cache-extent buffer exists to pre-build rows a *continuous*
    // scroll is about to reach; on a jump frame none of it survives to the next
    // frame, so it's pure waste — and it's the majority of the window (31 rows
    // buffered vs 13 visible at the default extent).
    final rowRange = visibleRowRange(
      scrollOffset: vScroll,
      viewportExtent: widget.viewportHeight,
      cacheExtent: jumped ? 0.0 : widget.cacheExtent,
      rowHeight: widget.rowHeight,
      rowCount: widget.rowCount,
    );

    // Column range. Vertical scrolling can't move it, and that's the common
    // case — so reuse the last result unless a horizontal input actually
    // changed, rather than re-scanning every column on every scroll frame.
    if (_colRangeHScroll != hScroll ||
        _colRangeViewportWidth != widget.viewportWidth ||
        _colRangePinnedWidth != widget.pinnedWidth ||
        _colRangeCacheExtent != effectiveCacheExtent ||
        !identical(_colRangeColumnsRef, widget.columns) ||
        !identical(_colRangeIndicesRef, widget.unpinnedIndices)) {
      _colRangeHScroll = hScroll;
      _colRangeViewportWidth = widget.viewportWidth;
      _colRangePinnedWidth = widget.pinnedWidth;
      _colRangeCacheExtent = effectiveCacheExtent;
      _colRangeColumnsRef = widget.columns;
      _colRangeIndicesRef = widget.unpinnedIndices;

      final scrollableViewportWidth = widget.viewportWidth - widget.pinnedWidth;
      final bufferedScrollStart = (hScroll - effectiveCacheExtent).clamp(
        0.0,
        double.infinity,
      );
      final bufferedScrollEnd =
          hScroll + scrollableViewportWidth + effectiveCacheExtent;

      int firstColIdx = 0;
      int lastColIdx = widget.unpinnedIndices.length;
      bool foundFirst = false;
      double accWidth = 0;

      for (int i = 0; i < widget.unpinnedIndices.length; i++) {
        final colWidth = widget.columns[widget.unpinnedIndices[i]].width;
        if (!foundFirst && accWidth + colWidth > bufferedScrollStart) {
          firstColIdx = i;
          foundFirst = true;
        }
        accWidth += colWidth;
        if (accWidth >= bufferedScrollEnd) {
          lastColIdx = (i + 1).clamp(0, widget.unpinnedIndices.length);
          break;
        }
      }

      _colRangeFirst = firstColIdx;
      _colRangeLast = lastColIdx;
    }

    return _VisibleRange(
      rowRange.firstRow,
      rowRange.lastRow,
      _colRangeFirst,
      _colRangeLast,
    );
  }

  /// Computes [_children], [_cellIds] and [_columnSpans] for the current
  /// visible range.
  ///
  /// Carry-over cells are reused from [_cellCache]; new cells are created and
  /// added to the cache. Cells that are no longer visible are evicted.
  ///
  /// Vertical geometry is deliberately *not* computed here — [GridLayoutDelegate]
  /// derives each row's y from its index during layout, so this only has to run
  /// when the set of built cells changes.
  void _rebuildCellList() {
    final r = _visibleRange;
    final jumped = _jumped;
    final columnSpans = <int, ColumnSpan>{};
    final cellIds = <CellLayoutId>[];
    final nextCache = <CellLayoutId, Widget>{};
    final children = <Widget>[];

    double accX = 0;
    for (int i = 0; i < widget.unpinnedIndices.length; i++) {
      final colIndex = widget.unpinnedIndices[i];
      final colWidth = widget.columns[colIndex].width;

      if (i >= r.firstColIdx && i < r.lastColIdx) {
        final column = widget.columns[colIndex];

        // Content-space x from the unpinned origin. The delegate converts to
        // viewport space by subtracting the horizontal scroll offset.
        columnSpans[colIndex] = ColumnSpan(accX, colWidth);

        for (int row = r.firstRow; row < r.lastRow; row++) {
          if (row < 0 || row >= widget.rows.length) continue;

          final entry = widget.rows[row];
          if (entry is! GridDataRow<T>) continue; // group header band

          final rowId = entry.rowId;
          final rowData = widget.rowsById[rowId];
          if (rowData == null) continue;

          final cellId = CellLayoutId(row, colIndex);

          // Reuse the cached LayoutId for carry-over cells. Flutter detects the
          // identical instance and skips build() for that element entirely.
          // The ValueKey on LayoutId enables key-based reconciliation so
          // carry-over cells are matched correctly after range shifts.
          final cell =
              (jumped ? null : _cellCache[cellId]) ??
              _buildCell(
                cellId: cellId,
                slot: row - r.firstRow,
                column: column,
                rowData: rowData,
                rowId: rowId,
                row: row,
                jumped: jumped,
              );

          if (!jumped) nextCache[cellId] = cell;
          cellIds.add(cellId);
          children.add(cell);
        }
      }

      accX += colWidth;
      if (i >= r.lastColIdx) break;
    }

    _cellCache
      ..clear()
      ..addAll(nextCache);

    _columnSpans = columnSpans;
    _cellIds = cellIds;
    _children = children;
  }

  /// Builds one cell.
  ///
  /// **The reconciliation key is not the layout id.** [cellId] identifies the
  /// cell to `GridLayoutDelegate` (it's what resolves x/y at layout time) and is
  /// always absolute. The *key* decides which existing element Flutter matches
  /// this widget to, and the right choice differs by frame:
  ///
  /// * Continuous scroll — key by absolute cell identity. A cell that carries
  ///   over into the new window keeps the very same element, and because the
  ///   cached widget instance is reused too, Flutter skips its `build()`
  ///   entirely. Only rows genuinely entering the window cost anything.
  /// * Jump ([jumped]) — nothing carries over, so absolute keys match nothing:
  ///   every element in the viewport is deactivated and a fresh one inflated,
  ///   which means new `State` objects, new `RenderObject`s and new gesture
  ///   recognizers for every cell, on every frame of a scrollbar-thumb drag.
  ///   Keying by *slot* instead reuses the previous frame's elements and merely
  ///   updates them: `DataGridCell.didUpdateWidget` re-points the cell at its
  ///   new row, and each column's `cellWidget` subtree is updated in place
  ///   rather than rebuilt from scratch (a `const` leaf under it is skipped
  ///   outright).
  Widget _buildCell({
    required CellLayoutId cellId,
    required int slot,
    required DataGridColumn<T> column,
    required T rowData,
    required double rowId,
    required int row,
    required bool jumped,
  }) {
    if (jumped) {
      final slotKey = ValueKey(CellLayoutId(slot, cellId.column));
      return LayoutId(
        key: slotKey,
        id: cellId,
        child: LayoutGridCell<T>(
          key: slotKey,
          row: rowData,
          rowId: rowId,
          column: column,
          rowIndex: row,
        ),
      );
    }
    return LayoutId(
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
  }

  /// Called on every scroll frame; only rebuilds when the window actually moved.
  void _onOffsetChanged() {
    final newRange = _computeRange();
    if (newRange != _visibleRange) {
      // Visible cell set changed: rebuild widget tree to add / remove cells.
      setState(() {
        _visibleRange = newRange;
        _rebuildCellList();
      });
    }
    // else: same cells, different position/height — GridLayoutDelegate.relayout
    // fires markNeedsLayout on the render object (no widget rebuild).
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) return const SizedBox.expand();

    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: GridLayoutDelegate(
          cellIds: _cellIds,
          columnSpans: _columnSpans,
          rowHeight: widget.rowHeight,
          hOffset: widget.hOffset,
          vOffset: widget.vOffset,
          relayout: _relayout,
          pinnedWidth: widget.pinnedWidth,
        ),
        children: _children,
      ),
    );
  }
}
