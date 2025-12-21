import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/widgets/data_grid_viewport.dart';

class DataGridScrollView extends TwoDimensionalScrollView {
  final List<DataGridColumn> columns;
  final int rowCount;
  final double rowHeight;
  final Widget Function(BuildContext context, int row, int column) cellBuilder;

  DataGridScrollView({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.rowHeight,
    required this.cellBuilder,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.clipBehavior = Clip.hardEdge,
  }) : super(
         delegate: DataGridChildDelegate(columns: columns, rowCount: rowCount, cellBuilder: cellBuilder),
       );

  @override
  Widget buildViewport(BuildContext context, ViewportOffset verticalOffset, ViewportOffset horizontalOffset) {
    return DataGridViewport(
      verticalOffset: verticalOffset,
      verticalAxisDirection: AxisDirection.down,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: AxisDirection.right,
      delegate: delegate as DataGridChildDelegate,
      mainAxis: mainAxis,
      columns: columns,
      rowCount: rowCount,
      rowHeight: rowHeight,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}
