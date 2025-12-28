import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/events/selection_events.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';

class DataGridCheckboxCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final double rowId;
  final int rowIndex;
  final DataGridController<T> controller;

  const DataGridCheckboxCell({
    super.key,
    required this.row,
    required this.rowId,
    required this.rowIndex,
    required this.controller,
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
            controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true));
          },
          child: Container(
            decoration: BoxDecoration(
              color: rowIndex % 2 == 0 ? Colors.white : Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) {
                controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true));
              },
            ),
          ),
        );
      },
    );
  }
}

class DataGridCheckboxHeaderCell<T extends DataGridRow> extends StatelessWidget {
  final DataGridController<T> controller;

  const DataGridCheckboxHeaderCell({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DataGridState<T>>(
      stream: controller.state$,
      initialData: controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final allSelected =
            state.displayOrder.isNotEmpty && state.displayOrder.every((id) => state.selection.isRowSelected(id));
        final someSelected = state.selection.selectedRowIds.isNotEmpty && !allSelected;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border(
              bottom: BorderSide(color: Colors.grey[400]!, width: 2),
              right: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Checkbox(
            value: allSelected,
            tristate: true,
            onChanged: (value) {
              if (allSelected || someSelected) {
                controller.addEvent(ClearSelectionEvent());
              } else {
                for (final rowId in state.displayOrder) {
                  controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true));
                }
              }
            },
          ),
        );
      },
    );
  }
}
