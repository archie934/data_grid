import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/events/selection_events.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

// rxdart import needed for header checkbox

class DataGridCheckboxCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final double rowId;
  final int rowIndex;

  const DataGridCheckboxCell({super.key, required this.row, required this.rowId, required this.rowIndex});

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;
    final isSelected = controller.state.selection.isRowSelected(rowId);
    final bgColor = rowIndex % 2 == 0 ? theme.colors.evenRowColor : theme.colors.oddRowColor;

    return GestureDetector(
      onTap: () => controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true)),
      child: DecoratedBox(
        decoration: BoxDecoration(color: bgColor, border: theme.borders.checkboxCellBorder),
        child: Padding(
          padding: theme.padding.checkboxPadding,
          child: Center(
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true)),
            ),
          ),
        ),
      ),
    );
  }
}

class DataGridCheckboxHeaderCell<T extends DataGridRow> extends StatefulWidget {
  const DataGridCheckboxHeaderCell({super.key});

  @override
  State<DataGridCheckboxHeaderCell<T>> createState() => _DataGridCheckboxHeaderCellState<T>();
}

class _DataGridCheckboxHeaderCellState<T extends DataGridRow> extends State<DataGridCheckboxHeaderCell<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;

    return StreamBuilder<_CheckboxHeaderState>(
      stream: Rx.combineLatest2(controller.renderedRowIds$, controller.selection$, (
        Set<double> renderedRowIds,
        selection,
      ) {
        final allVisibleSelected =
            renderedRowIds.isNotEmpty && renderedRowIds.every((id) => selection.isRowSelected(id));
        final anySelected = selection.selectedRowIds.isNotEmpty;
        final someSelected = anySelected && !allVisibleSelected;

        return _CheckboxHeaderState(allVisibleSelected, someSelected, renderedRowIds);
      }).distinct(),
      initialData: _computeInitialState(controller),
      builder: (context, snapshot) {
        final headerState = snapshot.data!;

        return Semantics(
          label: headerState.allVisibleSelected
              ? 'Deselect all rows'
              : headerState.someSelected
              ? 'Some rows selected, click to deselect all'
              : 'Select all visible rows',
          checked: headerState.allVisibleSelected,
          onTap: () {
            if (headerState.allVisibleSelected || headerState.someSelected) {
              controller.addEvent(ClearSelectionEvent());
            } else {
              controller.addEvent(
                SelectAllRowsEvent(rowIds: headerState.visibleRowIds.isEmpty ? null : headerState.visibleRowIds),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(color: theme.colors.headerColor, border: theme.borders.headerBorder),
            padding: theme.padding.checkboxPadding,
            alignment: Alignment.center,
            child: Checkbox(
              value: headerState.someSelected ? null : headerState.allVisibleSelected,
              tristate: true,
              onChanged: (value) {
                if (headerState.allVisibleSelected || headerState.someSelected) {
                  controller.addEvent(ClearSelectionEvent());
                } else {
                  controller.addEvent(
                    SelectAllRowsEvent(rowIds: headerState.visibleRowIds.isEmpty ? null : headerState.visibleRowIds),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  _CheckboxHeaderState _computeInitialState(DataGridController<T> controller) {
    final state = controller.state;
    final renderedRowIds = controller.renderedRowIds;

    final allVisibleSelected =
        renderedRowIds.isNotEmpty && renderedRowIds.every((id) => state.selection.isRowSelected(id));
    final anySelected = state.selection.selectedRowIds.isNotEmpty;
    final someSelected = anySelected && !allVisibleSelected;

    return _CheckboxHeaderState(allVisibleSelected, someSelected, renderedRowIds);
  }
}

class _CheckboxHeaderState {
  final bool allVisibleSelected;
  final bool someSelected;
  final Set<double> visibleRowIds;

  _CheckboxHeaderState(this.allVisibleSelected, this.someSelected, this.visibleRowIds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CheckboxHeaderState &&
          allVisibleSelected == other.allVisibleSelected &&
          someSelected == other.someSelected &&
          visibleRowIds.length == other.visibleRowIds.length &&
          visibleRowIds.every((id) => other.visibleRowIds.contains(id));

  @override
  int get hashCode => Object.hash(allVisibleSelected, someSelected, Object.hashAll(visibleRowIds));
}
