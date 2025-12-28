import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/base_event.dart';
import 'package:data_grid/data_grid/models/events/event_context.dart';
import 'package:data_grid/data_grid/models/events/data_events.dart';

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
    final currentValue = context.dataIndexer.getCellValue(row, column);

    return context.state.copyWith(
      edit: context.state.edit.copyWith(editingCellId: cellId, editingValue: currentValue),
    );
  }
}

class UpdateCellEditValueEvent extends DataGridEvent {
  final dynamic value;

  UpdateCellEditValueEvent({required this.value});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (!context.state.edit.isEditing) {
      return null;
    }

    return context.state.copyWith(edit: context.state.edit.copyWith(editingValue: value));
  }
}

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

    context.dispatchEvent(UpdateCellEvent(rowId: rowId, columnId: columnId, value: newValue));

    return context.state.copyWith(edit: EditState.initial());
  }
}

class CancelCellEditEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(edit: EditState.initial());
  }
}
