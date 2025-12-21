import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';

/// A single cell widget in the data grid body.
/// Handles selection state and tap gestures to select rows.
class DataGridCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final double rowId;
  final int columnId;
  final int rowIndex;
  final DataGridController<T> controller;
  final Widget Function(T row, int columnId)? cellBuilder;

  const DataGridCell({
    super.key,
    required this.row,
    required this.rowId,
    required this.columnId,
    required this.rowIndex,
    required this.controller,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SelectionState>(
      stream: controller.selection$,
      initialData: controller.state.selection,
      builder: (context, snapshot) {
        final isSelected = snapshot.data?.isRowSelected(rowId) ?? false;

        return GestureDetector(
          onTap: () {
            controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: false));
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : (rowIndex % 2 == 0 ? Colors.white : Colors.grey[50]),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerLeft,
            child: cellBuilder != null
                ? cellBuilder!(row, columnId)
                : Text('Row ${row.id}, Col $columnId', overflow: TextOverflow.ellipsis),
          ),
        );
      },
    );
  }
}

