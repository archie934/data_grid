import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
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
  final List<double> displayOrder;
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
    required this.displayOrder,
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
  List<Widget> _children = const [];
  Map<CellLayoutId, Rect> _contentRects = const {};

  @override
  void initState() {
    super.initState();
    _visibleRange = _computeRange();
    _rebuildCellList();
    widget.hOffset.addListener(_onOffsetChanged);
    widget.vOffset.addListener(_onOffsetChanged);
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

    // Clear cache when content-affecting parameters change.
    if (!identical(old.rowsById, widget.rowsById) ||
        !identical(old.displayOrder, widget.displayOrder) ||
        !identical(old.columns, widget.columns) ||
        !identical(old.unpinnedIndices, widget.unpinnedIndices)) {
      _cellCache.clear();
    }

    // Recompute visible range when structural parameters change.
    if (old.viewportWidth != widget.viewportWidth ||
        old.viewportHeight != widget.viewportHeight ||
        old.pinnedWidth != widget.pinnedWidth ||
        old.rowHeight != widget.rowHeight ||
        old.rowCount != widget.rowCount ||
        old.cacheExtent != widget.cacheExtent ||
        !identical(old.columns, widget.columns) ||
        !identical(old.unpinnedIndices, widget.unpinnedIndices)) {
      _visibleRange = _computeRange();
    }

    // Always rebuild the cell list — build() reads _children / _contentRects
    // directly, so they must be current before the framework calls build().
    _rebuildCellList();
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

    // Row range
    final firstVisibleRow = (vScroll / widget.rowHeight).floor().clamp(
      0,
      widget.rowCount,
    );
    final visibleRowCount =
        (widget.viewportHeight / widget.rowHeight).ceil() + 1;
    final lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(
      0,
      widget.rowCount,
    );
    final bufferRows = (effectiveCacheExtent / widget.rowHeight).ceil();
    final firstRow = (firstVisibleRow - bufferRows).clamp(0, widget.rowCount);
    final lastRow = (lastVisibleRow + bufferRows).clamp(0, widget.rowCount);

    // Column range
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

    return _VisibleRange(firstRow, lastRow, firstColIdx, lastColIdx);
  }

  /// Computes [_children] and [_contentRects] for the current visible range.
  ///
  /// Carry-over cells are reused from [_cellCache]; new cells are created and
  /// added to the cache. Cells that are no longer visible are evicted.
  void _rebuildCellList() {
    final r = _visibleRange;
    final contentRects = <CellLayoutId, Rect>{};
    final nextCache = <CellLayoutId, Widget>{};
    final children = <Widget>[];

    double accX = 0;
    for (int i = 0; i < widget.unpinnedIndices.length; i++) {
      final colIndex = widget.unpinnedIndices[i];
      final colWidth = widget.columns[colIndex].width;

      if (i >= r.firstColIdx && i < r.lastColIdx) {
        final contentX = accX;
        final column = widget.columns[colIndex];

        for (int row = r.firstRow; row < r.lastRow; row++) {
          if (row < 0 || row >= widget.displayOrder.length) continue;

          final rowId = widget.displayOrder[row];
          final rowData = widget.rowsById[rowId];
          if (rowData == null) continue;

          final cellId = CellLayoutId(row, colIndex);

          // Content-space rect: left = column x from unpinned origin,
          // top = row y from content top. The delegate converts to viewport
          // space by subtracting the current scroll offsets.
          contentRects[cellId] = Rect.fromLTWH(
            contentX,
            row * widget.rowHeight,
            colWidth,
            widget.rowHeight,
          );

          // Reuse the cached LayoutId for carry-over cells. Flutter detects the
          // identical instance and skips build() for that element entirely.
          // The ValueKey on LayoutId enables key-based reconciliation so
          // carry-over cells are matched correctly after range shifts.
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
      }

      accX += colWidth;
      if (i >= r.lastColIdx) break;
    }

    _cellCache
      ..clear()
      ..addAll(nextCache);

    _contentRects = contentRects;
    _children = children;
  }

  void _onOffsetChanged() {
    final newRange = _computeRange();
    if (newRange != _visibleRange) {
      // Visible cell set changed: rebuild widget tree to add / remove cells.
      setState(() {
        _visibleRange = newRange;
        _rebuildCellList();
      });
    }
    // else: same cells, different position — GridLayoutDelegate.relayout
    // fires markNeedsLayout on the render object (no widget rebuild).
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) return const SizedBox.expand();

    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: GridLayoutDelegate(
          contentRects: _contentRects,
          hOffset: widget.hOffset,
          vOffset: widget.vOffset,
          pinnedWidth: widget.pinnedWidth,
        ),
        children: _children,
      ),
    );
  }
}
