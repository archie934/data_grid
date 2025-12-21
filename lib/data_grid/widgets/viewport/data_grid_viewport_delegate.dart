import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/models/data/column.dart';

/// Delegate that provides children (cells) for the 2D grid viewport.
/// This is responsible for building widgets at specific grid coordinates.
class DataGridChildDelegate extends TwoDimensionalChildDelegate {
  final List<DataGridColumn> columns;
  final int rowCount;
  final Widget Function(BuildContext context, int row, int column) cellBuilder;

  DataGridChildDelegate({required this.columns, required this.rowCount, required this.cellBuilder});

  /// Builds a child widget for a specific cell location (vicinity).
  /// Returns null if the coordinates are out of bounds.
  @override
  Widget? build(BuildContext context, covariant ChildVicinity vicinity) {
    final childVicinity = vicinity as DataGridVicinity;

    // Validate that the requested cell is within grid bounds
    if (childVicinity.row < 0 ||
        childVicinity.row >= rowCount ||
        childVicinity.column < 0 ||
        childVicinity.column >= columns.length) {
      return null;
    }

    // Build and return the cell widget at this location
    return cellBuilder(context, childVicinity.row, childVicinity.column);
  }

  /// Determines if the delegate needs to rebuild children.
  /// Returns true if columns or row count has changed.
  @override
  bool shouldRebuild(covariant DataGridChildDelegate oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.rowCount != rowCount;
  }
}

/// Represents a cell's location in the 2D grid.
/// Maps row/column coordinates to xIndex/yIndex used by the viewport.
class DataGridVicinity extends ChildVicinity {
  const DataGridVicinity(int row, int column) : super(xIndex: column, yIndex: row);

  /// Convenience getter to access the row index
  int get row => yIndex;

  /// Convenience getter to access the column index
  int get column => xIndex;
}

