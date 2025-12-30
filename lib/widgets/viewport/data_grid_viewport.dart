import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_viewport_delegate.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_viewport_render.dart';

/// The viewport widget that displays a scrollable window into the 2D grid.
/// This widget creates and manages the render object that performs layout.
class DataGridViewport<T extends DataGridRow> extends TwoDimensionalViewport {
  final List<DataGridColumn<T>> columns;
  final int rowCount;
  final double rowHeight;
  final Color pinnedMaskColor;

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
    required this.pinnedMaskColor,
    super.cacheExtent,
    super.clipBehavior,
  });

  /// Creates the render object that performs the actual layout and rendering.
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
      pinnedMaskColor: pinnedMaskColor,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  /// Updates the render object when widget properties change.
  @override
  void updateRenderObject(BuildContext context, covariant RenderDataGridViewport renderObject) {
    renderObject
      ..delegate = delegate as DataGridChildDelegate
      ..columns = columns
      ..rowCount = rowCount
      ..rowHeight = rowHeight
      ..pinnedMaskColor = pinnedMaskColor;
  }
}
