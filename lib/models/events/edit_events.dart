import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/models/events/data_events.dart';

/// Begins inline editing for a specific cell.
class StartCellEditEvent extends DataGridEvent {
  final double rowId;
  final int columnId;

  StartCellEditEvent({required this.rowId, required this.columnId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final column = context.state.columns.firstWhere(
      (c) => c.id == columnId,
      orElse: () => throw Exception('Column not found'),
    );

    if (!column.editable) {
      return null;
    }

    if (context.canEditCell != null && !context.canEditCell!(rowId, columnId)) {
      return null;
    }

    final row = context.state.rowsById[rowId];
    if (row == null) {
      return null;
    }

    final cellId = context.state.edit.createCellId(rowId, columnId);

    var newState = context.state;

    if (context.state.edit.isEditing) {
      final currentCellId = context.state.edit.editingCellId!;

      if (currentCellId != cellId) {
        final parts = currentCellId.split('_');
        final currentRowId = double.parse(parts[0]);
        final currentColumnId = int.parse(parts[1]);
        final editValue = context.state.edit.editingValue;

        context.dispatchEvent(
          UpdateCellEvent(
            rowId: currentRowId,
            columnId: currentColumnId,
            value: editValue,
          ),
        );
      }
    }

    final currentValue = column.valueAccessor != null
        ? column.valueAccessor!(row)
        : null;

    return newState.copyWith(
      edit: newState.edit.copyWith(
        editingCellId: cellId,
        editingValue: currentValue,
      ),
      selection: newState.selection.copyWith(focusedCells: [cellId]),
    );
  }
}

/// Updates the in-progress editing value without committing.
class UpdateCellEditValueEvent extends DataGridEvent {
  final dynamic value;

  UpdateCellEditValueEvent({required this.value});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (!context.state.edit.isEditing) {
      return null;
    }

    return context.state.copyWith(
      edit: context.state.edit.copyWith(editingValue: value),
    );
  }
}

/// Commits the current cell edit, persisting the value.
class CommitCellEditEvent extends DataGridEvent {
  CommitCellEditEvent();

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (!context.state.edit.isEditing) {
      return null;
    }

    final cellId = context.state.edit.editingCellId!;
    final parts = cellId.split('_');
    final rowId = double.parse(parts[0]);
    final columnId = int.parse(parts[1]);
    final newValue = context.state.edit.editingValue;

    // Apply the row update inline so that any events already queued (e.g.
    // CopyCellsEvent) see the new value immediately rather than reading stale
    // data from rowsById before a separately-dispatched UpdateCellEvent runs.
    final row = context.state.rowsById[rowId];
    final column = context.state.columns.firstWhere(
      (c) => c.id == columnId,
      orElse: () => throw Exception('Column $columnId not found'),
    );
    if (row != null && column.cellValueSetter != null) {
      column.cellValueSetter!(row, newValue);
    }
    final newRowsById = Map<double, T>.of(context.state.rowsById);
    context.dataIndexer.setData(newRowsById);

    return context.state.copyWith(
      edit: EditState.initial(),
      rowsById: newRowsById,
      selection: context.state.selection.copyWith(focusedCells: [cellId]),
    );
  }
}

/// Cancels the current cell edit, discarding changes.
class CancelCellEditEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final cancelledCellId = context.state.edit.editingCellId;
    return context.state.copyWith(
      edit: EditState.initial(),
      selection: cancelledCellId != null
          ? context.state.selection.copyWith(focusedCells: [cancelledCellId])
          : context.state.selection,
    );
  }
}
