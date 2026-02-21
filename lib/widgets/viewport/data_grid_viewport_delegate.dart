import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';

/// Delegate that provides children (cells) for the 2D grid viewport.
/// This is responsible for building widgets at specific grid coordinates.
class DataGridChildDelegate<T extends DataGridRow>
    extends TwoDimensionalChildDelegate {
  final List<DataGridColumn<T>> columns;
  final int rowCount;
  final Widget Function(BuildContext context, int row, int column) cellBuilder;

  DataGridChildDelegate({
    required this.columns,
    required this.rowCount,
    required this.cellBuilder,
  });

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

  @override
  bool shouldRebuild(covariant DataGridChildDelegate<T> oldDelegate) {
    return columns != oldDelegate.columns ||
        rowCount != oldDelegate.rowCount ||
        cellBuilder != oldDelegate.cellBuilder;
  }
}

/// Represents a cell's location in the 2D grid.
/// Maps row/column coordinates to xIndex/yIndex used by the viewport.
class DataGridVicinity extends ChildVicinity {
  const DataGridVicinity(int row, int column)
    : super(xIndex: column, yIndex: row);

  /// Convenience getter to access the row index
  int get row => yIndex;

  /// Convenience getter to access the column index
  int get column => xIndex;
}
