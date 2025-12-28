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
    return StreamBuilder<bool>(
      stream: controller.selection$.map((s) => s.isRowSelected(rowId)).distinct(),
      initialData: controller.state.selection.isRowSelected(rowId),
      builder: (context, snapshot) {
        final isSelected = snapshot.data ?? false;

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

class DataGridCheckboxHeaderCell<T extends DataGridRow> extends StatefulWidget {
  final DataGridController<T> controller;

  const DataGridCheckboxHeaderCell({super.key, required this.controller});

  @override
  State<DataGridCheckboxHeaderCell<T>> createState() => _DataGridCheckboxHeaderCellState<T>();
}

class _DataGridCheckboxHeaderCellState<T extends DataGridRow> extends State<DataGridCheckboxHeaderCell<T>> {
  late List<double> visibleRowIds;
  late bool allSelected;
  late bool someSelected;

  @override
  void initState() {
    super.initState();
    _updateSelectionState(widget.controller.state);
  }

  void _updateSelectionState(DataGridState<T> state) {
    final viewport = state.viewport;
    visibleRowIds = [];

    for (int i = viewport.firstVisibleRow; i <= viewport.lastVisibleRow && i < state.displayOrder.length; i++) {
      visibleRowIds.add(state.displayOrder[i]);
    }

    allSelected = visibleRowIds.isNotEmpty && visibleRowIds.every((id) => state.selection.isRowSelected(id));
    someSelected = visibleRowIds.any((id) => state.selection.isRowSelected(id)) && !allSelected;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DataGridState<T>>(
      stream: widget.controller.state$,
      initialData: widget.controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        _updateSelectionState(state);

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
                widget.controller.addEvent(ClearSelectionEvent());
              } else {
                widget.controller.addEvent(SelectAllRowsEvent());
              }
            },
          ),
        );
      },
    );
  }
}
