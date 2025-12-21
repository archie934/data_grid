import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:data_grid/data_grid/models/data/column.dart';

class DataGridChildDelegate extends TwoDimensionalChildDelegate {
  final List<DataGridColumn> columns;
  final int rowCount;
  final Widget Function(BuildContext context, int row, int column) cellBuilder;

  DataGridChildDelegate({required this.columns, required this.rowCount, required this.cellBuilder});

  @override
  Widget? build(BuildContext context, covariant ChildVicinity vicinity) {
    final childVicinity = vicinity as _DataGridVicinity;
    if (childVicinity.row < 0 ||
        childVicinity.row >= rowCount ||
        childVicinity.column < 0 ||
        childVicinity.column >= columns.length) {
      return null;
    }
    return cellBuilder(context, childVicinity.row, childVicinity.column);
  }

  @override
  bool shouldRebuild(covariant DataGridChildDelegate oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.rowCount != rowCount;
  }
}

class _DataGridVicinity extends ChildVicinity {
  _DataGridVicinity(int row, int column) : super(xIndex: column, yIndex: row);

  int get row => yIndex;
  int get column => xIndex;
}

class DataGridViewport extends TwoDimensionalViewport {
  final List<DataGridColumn> columns;
  final int rowCount;
  final double rowHeight;

  const DataGridViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required this.columns,
    required this.rowCount,
    required this.rowHeight,
    super.cacheExtent,
    super.clipBehavior,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderDataGridViewport(
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      delegate: delegate as DataGridChildDelegate,
      mainAxis: mainAxis,
      childManager: context as TwoDimensionalChildManager,
      columns: columns,
      rowCount: rowCount,
      rowHeight: rowHeight,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDataGridViewport renderObject) {
    renderObject
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..delegate = delegate
      ..mainAxis = mainAxis
      ..columns = columns
      ..rowCount = rowCount
      ..rowHeight = rowHeight
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderDataGridViewport extends RenderTwoDimensionalViewport {
  List<DataGridColumn> columns;
  int rowCount;
  double rowHeight;

  RenderDataGridViewport({
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required DataGridChildDelegate super.delegate,
    required super.mainAxis,
    required super.childManager,
    required this.columns,
    required this.rowCount,
    required this.rowHeight,
    super.cacheExtent,
    super.clipBehavior,
  });

  @override
  void layoutChildSequence() {
    final double viewportWidth = viewportDimension.width;
    final double viewportHeight = viewportDimension.height;
    final double verticalScrollOffset = verticalOffset.pixels;
    final double horizontalScrollOffset = horizontalOffset.pixels;

    final int firstVisibleRow = (verticalScrollOffset / rowHeight).floor().clamp(0, rowCount);
    final int visibleRowCount = (viewportHeight / rowHeight).ceil() + 1;
    final int lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(0, rowCount);

    double accumulatedWidth = 0;
    int firstVisibleColumn = -1;
    int lastVisibleColumn = columns.length;

    for (int i = 0; i < columns.length; i++) {
      if (accumulatedWidth + columns[i].width > horizontalScrollOffset && firstVisibleColumn == -1) {
        firstVisibleColumn = i;
      }
      accumulatedWidth += columns[i].width;
      if (accumulatedWidth >= horizontalScrollOffset + viewportWidth) {
        lastVisibleColumn = (i + 1).clamp(0, columns.length);
        break;
      }
    }

    if (firstVisibleColumn == -1) {
      firstVisibleColumn = 0;
    }

    double yOffset = 0;
    for (int row = firstVisibleRow; row < lastVisibleRow; row++) {
      double xOffset = 0;

      for (int col = firstVisibleColumn; col < lastVisibleColumn; col++) {
        final vicinity = _DataGridVicinity(row, col);
        final child = buildOrObtainChildFor(vicinity);

        if (child != null) {
          child.layout(BoxConstraints.tight(Size(columns[col].width, rowHeight)));
          parentDataOf(child).layoutOffset = Offset(xOffset, yOffset);
        }

        xOffset += columns[col].width;
      }
      yOffset += rowHeight;
    }

    final totalWidth = columns.fold<double>(0, (sum, col) => sum + col.width);
    final totalHeight = rowCount * rowHeight;

    verticalOffset.applyContentDimensions(0, (totalHeight - viewportHeight).clamp(0, double.infinity));
    horizontalOffset.applyContentDimensions(0, (totalWidth - viewportWidth).clamp(0, double.infinity));
  }
}
