import 'package:material_ui/material_ui.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

// rxdart import needed for header checkbox

class DataGridCheckboxCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final double rowId;
  final int rowIndex;

  const DataGridCheckboxCell({
    super.key,
    required this.row,
    required this.rowId,
    required this.rowIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;
    final isSelected = context
        .dataGridState<T>({DataGridAspect.selection})!
        .selection
        .isRowSelected(rowId);

    return GestureDetector(
      onTap: () => controller.selectRow(rowId, multiSelect: true),
      child: DecoratedBox(
        decoration: theme.cellDecorations.forCheckbox(
          isEven: rowIndex % 2 == 0,
        ),
        child: Padding(
          padding: theme.padding.checkboxPadding,
          // heightFactor: 1.0 — see DataGridCell's _DefaultTextCell for why
          // Center (Align without heightFactor) needs this under
          // DataGrid.autoRowHeight's loose measurement pass.
          child: Center(
            heightFactor: 1.0,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) =>
                  controller.selectRow(rowId, multiSelect: true),
            ),
          ),
        ),
      ),
    );
  }
}

class DataGridCheckboxHeaderCell<T extends DataGridRow> extends StatefulWidget {
  /// When provided, overrides the default [DataGridBorders.headerBorder]
  /// for this cell's container decoration (e.g. to suppress the right border
  /// when the outer pinned wrapper already draws it).
  final Border? borderOverride;

  const DataGridCheckboxHeaderCell({super.key, this.borderOverride});

  @override
  State<DataGridCheckboxHeaderCell<T>> createState() =>
      _DataGridCheckboxHeaderCellState<T>();
}

class _DataGridCheckboxHeaderCellState<T extends DataGridRow>
    extends State<DataGridCheckboxHeaderCell<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;

    return StreamBuilder<_CheckboxHeaderState>(
      stream: Rx.combineLatest2(
        controller.renderedRowIds$,
        controller.selection$,
        (Set<double> renderedRowIds, selection) {
          final allVisibleSelected =
              renderedRowIds.isNotEmpty &&
              renderedRowIds.every((id) => selection.isRowSelected(id));
          final anySelected = selection.selectedRowIds.isNotEmpty;
          final someSelected = anySelected && !allVisibleSelected;

          return _CheckboxHeaderState(
            allVisibleSelected,
            someSelected,
            renderedRowIds,
          );
        },
      ).distinct(),
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
              controller.clearSelection();
            } else {
              controller.selectAllRows(
                rowIds: headerState.visibleRowIds.isEmpty
                    ? null
                    : headerState.visibleRowIds,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.colors.headerColor,
              border: widget.borderOverride ?? theme.borders.headerBorder,
            ),
            padding: theme.padding.checkboxPadding,
            // Align explicitly (with heightFactor: 1.0) rather than via
            // Container's `alignment` param: a plain Align/Center expands to
            // fill any bounded incoming height, so under
            // DataGrid.autoHeaderHeight's loose measurement pass it would
            // report maxHeight as the header's measured height.
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1.0,
              child: Checkbox(
                value: headerState.someSelected
                    ? null
                    : headerState.allVisibleSelected,
                tristate: true,
                onChanged: (value) {
                  if (headerState.allVisibleSelected ||
                      headerState.someSelected) {
                    controller.clearSelection();
                  } else {
                    controller.selectAllRows(
                      rowIds: headerState.visibleRowIds.isEmpty
                          ? null
                          : headerState.visibleRowIds,
                    );
                  }
                },
              ),
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
        renderedRowIds.isNotEmpty &&
        renderedRowIds.every((id) => state.selection.isRowSelected(id));
    final anySelected = state.selection.selectedRowIds.isNotEmpty;
    final someSelected = anySelected && !allVisibleSelected;

    return _CheckboxHeaderState(
      allVisibleSelected,
      someSelected,
      renderedRowIds,
    );
  }
}

class _CheckboxHeaderState {
  final bool allVisibleSelected;
  final bool someSelected;
  final Set<double> visibleRowIds;

  _CheckboxHeaderState(
    this.allVisibleSelected,
    this.someSelected,
    this.visibleRowIds,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CheckboxHeaderState &&
          allVisibleSelected == other.allVisibleSelected &&
          someSelected == other.someSelected &&
          visibleRowIds.length == other.visibleRowIds.length &&
          visibleRowIds.every((id) => other.visibleRowIds.contains(id));

  @override
  int get hashCode => Object.hash(
    allVisibleSelected,
    someSelected,
    Object.hashAll(visibleRowIds),
  );
}
