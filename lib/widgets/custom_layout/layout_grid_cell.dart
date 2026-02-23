import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_cell.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_checkbox_cell.dart';

/// Dispatches to the appropriate cell widget based on column type.
class LayoutGridCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final double rowId;
  final DataGridColumn<T> column;
  final int rowIndex;

  const LayoutGridCell({
    super.key,
    required this.row,
    required this.rowId,
    required this.column,
    required this.rowIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (column.id == kSelectionColumnId) {
      return DataGridCheckboxCell<T>(
        row: row,
        rowId: rowId,
        rowIndex: rowIndex,
      );
    }
    return DataGridCell<T>(
      row: row,
      rowId: rowId,
      column: column,
      rowIndex: rowIndex,
      isPinned: column.pinned,
    );
  }
}
