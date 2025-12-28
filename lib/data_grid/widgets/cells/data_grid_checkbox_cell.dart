import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/events/selection_events.dart';
import 'package:data_grid/data_grid/theme/data_grid_theme.dart';

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
    final theme = DataGridTheme.of(context);

    return StreamBuilder<bool>(
      stream: controller.selection$.map((s) => s.isRowSelected(rowId)).distinct(),
      initialData: controller.state.selection.isRowSelected(rowId),
      builder: (context, snapshot) {
        final isSelected = snapshot.data ?? false;

        return Semantics(
          label: 'Select row ${rowIndex + 1}',
          checked: isSelected,
          onTap: () {
            controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true));
          },
          child: GestureDetector(
            onTap: () {
              controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true));
            },
            child: Container(
              decoration: BoxDecoration(
                color: rowIndex % 2 == 0 ? theme.colors.evenRowColor : theme.colors.oddRowColor,
                border: theme.borders.checkboxCellBorder,
              ),
              padding: theme.padding.checkboxPadding,
              alignment: Alignment.center,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true));
                },
              ),
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
  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);

    return StreamBuilder<_CheckboxHeaderState>(
      stream: widget.controller.state$.map((state) {
        final viewport = state.viewport;
        final visibleRowIds = <double>[];

        for (int i = viewport.firstVisibleRow; i <= viewport.lastVisibleRow && i < state.displayOrder.length; i++) {
          visibleRowIds.add(state.displayOrder[i]);
        }

        final allSelected = visibleRowIds.isNotEmpty && visibleRowIds.every((id) => state.selection.isRowSelected(id));
        final someSelected = visibleRowIds.any((id) => state.selection.isRowSelected(id)) && !allSelected;

        return _CheckboxHeaderState(allSelected, someSelected);
      }).distinct(),
      initialData: _computeInitialState(),
      builder: (context, snapshot) {
        final headerState = snapshot.data!;

        return Semantics(
          label: headerState.allSelected
              ? 'Deselect all rows'
              : headerState.someSelected
              ? 'Some rows selected, click to deselect all'
              : 'Select all visible rows',
          checked: headerState.allSelected,
          onTap: () {
            if (headerState.allSelected || headerState.someSelected) {
              widget.controller.addEvent(ClearSelectionEvent());
            } else {
              widget.controller.addEvent(SelectAllRowsEvent());
            }
          },
          child: Container(
            decoration: BoxDecoration(color: theme.colors.headerColor, border: theme.borders.headerBorder),
            padding: theme.padding.checkboxPadding,
            alignment: Alignment.center,
            child: Checkbox(
              value: headerState.allSelected,
              tristate: true,
              onChanged: (value) {
                if (headerState.allSelected || headerState.someSelected) {
                  widget.controller.addEvent(ClearSelectionEvent());
                } else {
                  widget.controller.addEvent(SelectAllRowsEvent());
                }
              },
            ),
          ),
        );
      },
    );
  }

  _CheckboxHeaderState _computeInitialState() {
    final state = widget.controller.state;
    final viewport = state.viewport;
    final visibleRowIds = <double>[];

    for (int i = viewport.firstVisibleRow; i <= viewport.lastVisibleRow && i < state.displayOrder.length; i++) {
      visibleRowIds.add(state.displayOrder[i]);
    }

    final allSelected = visibleRowIds.isNotEmpty && visibleRowIds.every((id) => state.selection.isRowSelected(id));
    final someSelected = visibleRowIds.any((id) => state.selection.isRowSelected(id)) && !allSelected;

    return _CheckboxHeaderState(allSelected, someSelected);
  }
}

class _CheckboxHeaderState {
  final bool allSelected;
  final bool someSelected;

  _CheckboxHeaderState(this.allSelected, this.someSelected);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CheckboxHeaderState && allSelected == other.allSelected && someSelected == other.someSelected;

  @override
  int get hashCode => Object.hash(allSelected, someSelected);
}
