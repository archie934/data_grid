import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_cell.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_checkbox_cell.dart';

/// Delegate that provides children (cells) for the 2D grid viewport.
/// Builds [DataGridCell] / [DataGridCheckboxCell] widgets directly from
/// the grid's data, avoiding closure allocation on every body rebuild.
class DataGridChildDelegate<T extends DataGridRow> extends TwoDimensionalChildDelegate {
  final List<DataGridColumn<T>> columns;
  final int rowCount;
  final List<double> displayOrder;
  final Map<double, T> rowsById;

  DataGridChildDelegate({required this.columns, required this.rowCount, required this.displayOrder, required this.rowsById});

  @override
  Widget? build(BuildContext context, covariant ChildVicinity vicinity) {
    final v = vicinity as DataGridVicinity;
    if (v.row < 0 || v.row >= rowCount || v.column < 0 || v.column >= columns.length) {
      return null;
    }

    final rowId = displayOrder[v.row];
    final row = rowsById[rowId]!;
    final column = columns[v.column];

    if (column.id == kSelectionColumnId) {
      return DataGridCheckboxCell<T>(key: ValueKey('cell_${row.id}_${column.id}'), row: row, rowId: row.id, rowIndex: v.row);
    }

    return DataGridCell<T>(key: ValueKey('cell_${row.id}_${column.id}'), row: row, rowId: row.id, column: column, rowIndex: v.row, isPinned: column.pinned);
  }

  @override
  bool shouldRebuild(covariant DataGridChildDelegate<T> oldDelegate) {
    return columns != oldDelegate.columns || rowCount != oldDelegate.rowCount || !identical(displayOrder, oldDelegate.displayOrder) || !identical(rowsById, oldDelegate.rowsById);
  }
}

/// Represents a cell's location in the 2D grid.
class DataGridVicinity extends ChildVicinity {
  const DataGridVicinity(int row, int column) : super(xIndex: column, yIndex: row);

  int get row => yIndex;
  int get column => xIndex;
}
