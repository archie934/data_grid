import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_viewport.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_viewport_delegate.dart';

class DataGridScrollView<T extends DataGridRow> extends TwoDimensionalScrollView {
  final List<DataGridColumn<T>> columns;
  final int rowCount;
  final double rowHeight;
  final Color pinnedMaskColor;
  final Widget Function(BuildContext context, int row, int column) cellBuilder;

  DataGridScrollView({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.rowHeight,
    required this.pinnedMaskColor,
    required this.cellBuilder,
    super.cacheExtent,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
  }) : super(
         mainAxis: Axis.vertical,
         diagonalDragBehavior: DiagonalDragBehavior.none,
         dragStartBehavior: DragStartBehavior.start,
         clipBehavior: Clip.hardEdge,
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
      pinnedMaskColor: pinnedMaskColor,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  
}
