import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/custom_layout/layout_grid_cell.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';

/// Renders the scrollable (unpinned) quadrant of the custom layout grid.
///
/// Listens to both [hOffset] and [vOffset] via a merged [Listenable] and
/// virtualizes rows and columns so only visible cells (plus [cacheExtent]
/// buffer) are built.
class GridUnpinnedQuadrant<T extends DataGridRow> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([hOffset, vOffset]),
      builder: (context, _) => _buildContent(),
    );
  }

  Widget _buildContent() {
    final hScroll = hOffset.value;
    final vScroll = vOffset.value;
    final effectiveCacheExtent = kDebugMode
        ? cacheExtent.clamp(0.0, 500.0)
        : cacheExtent;

    final firstVisibleRow = (vScroll / rowHeight).floor().clamp(0, rowCount);
    final visibleRowCount = (viewportHeight / rowHeight).ceil() + 1;
    final lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(
      0,
      rowCount,
    );

    final bufferRows = (effectiveCacheExtent / rowHeight).ceil();
    final firstRow = (firstVisibleRow - bufferRows).clamp(0, rowCount);
    final lastRow = (lastVisibleRow + bufferRows).clamp(0, rowCount);

    final scrollableViewportWidth = viewportWidth - pinnedWidth;
    final bufferedScrollStart = (hScroll - effectiveCacheExtent).clamp(
      0.0,
      double.infinity,
    );
    final bufferedScrollEnd =
        hScroll + scrollableViewportWidth + effectiveCacheExtent;

    int firstUnpinnedIdx = -1;
    int lastUnpinnedIdx = unpinnedIndices.length;
    double firstUnpinnedOffset = 0;
    double accWidth = 0;

    for (int i = 0; i < unpinnedIndices.length; i++) {
      final colWidth = columns[unpinnedIndices[i]].width;
      if (accWidth + colWidth > bufferedScrollStart && firstUnpinnedIdx == -1) {
        firstUnpinnedIdx = i;
        firstUnpinnedOffset = accWidth - hScroll;
      }
      accWidth += colWidth;
      if (accWidth >= bufferedScrollEnd) {
        lastUnpinnedIdx = (i + 1).clamp(0, unpinnedIndices.length);
        break;
      }
    }

    if (firstUnpinnedIdx == -1) {
      firstUnpinnedIdx = 0;
      firstUnpinnedOffset = 0;
    }

    final cellRects = <CellLayoutId, Rect>{};
    final children = <Widget>[];
    final startingY = (firstRow * rowHeight) - vScroll;

    double yOffset = startingY;
    for (int row = firstRow; row < lastRow; row++) {
      if (row < 0 || row >= displayOrder.length) {
        yOffset += rowHeight;
        continue;
      }

      double xOffset = pinnedWidth + firstUnpinnedOffset;
      for (int i = firstUnpinnedIdx; i < lastUnpinnedIdx; i++) {
        final colIndex = unpinnedIndices[i];
        if (colIndex < 0 || colIndex >= columns.length) continue;

        final colWidth = columns[colIndex].width;

        if (xOffset + colWidth <= pinnedWidth) {
          xOffset += colWidth;
          continue;
        }

        final cellId = CellLayoutId(row, colIndex);
        cellRects[cellId] = Rect.fromLTWH(
          xOffset,
          yOffset,
          colWidth,
          rowHeight,
        );

        final rowId = displayOrder[row];
        final rowData = rowsById[rowId];
        if (rowData == null) {
          xOffset += colWidth;
          continue;
        }
        final column = columns[colIndex];

        children.add(
          LayoutId(
            id: cellId,
            child: LayoutGridCell<T>(
              key: ValueKey('cell_${rowId}_${column.id}'),
              row: rowData,
              rowId: rowId,
              column: column,
              rowIndex: row,
            ),
          ),
        );
        xOffset += colWidth;
      }
      yOffset += rowHeight;
    }

    if (children.isEmpty) return const SizedBox.expand();

    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: GridLayoutDelegate(cellRects: cellRects),
        children: children,
      ),
    );
  }
}
