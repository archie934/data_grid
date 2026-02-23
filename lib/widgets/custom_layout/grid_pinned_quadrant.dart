import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/custom_layout/layout_grid_cell.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';

/// Renders the pinned (frozen) columns quadrant of the custom layout grid.
///
/// Only listens to [vOffset] so horizontal scrolling does not trigger rebuilds.
class GridPinnedQuadrant<T extends DataGridRow> extends StatelessWidget {
  final List<DataGridColumn<T>> columns;
  final List<int> pinnedIndices;
  final double viewportHeight;
  final List<double> displayOrder;
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
    required this.displayOrder,
    required this.rowsById,
    required this.rowCount,
    required this.rowHeight,
    required this.cacheExtent,
    required this.backgroundColor,
    required this.vOffset,
  });

  Widget _buildContent() {
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

    final cellRects = <CellLayoutId, Rect>{};
    final children = <Widget>[];
    final startingY = (firstRow * rowHeight) - vScroll;

    double yOffset = startingY;
    for (int row = firstRow; row < lastRow; row++) {
      if (row < 0 || row >= displayOrder.length) {
        yOffset += rowHeight;
        continue;
      }

      double xOffset = 0;
      for (final colIndex in pinnedIndices) {
        if (colIndex < 0 || colIndex >= columns.length) continue;

        final colWidth = columns[colIndex].width;
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
      child: ColoredBox(
        color: backgroundColor,
        child: CustomMultiChildLayout(
          delegate: GridLayoutDelegate(cellRects: cellRects),
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vOffset,
      builder: (context, _) => _buildContent(),
    );
  }
}
