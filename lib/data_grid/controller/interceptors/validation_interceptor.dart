import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/base_event.dart';
import 'package:data_grid/data_grid/models/events/edit_events.dart';
import 'package:data_grid/data_grid/models/events/selection_events.dart';
import 'package:data_grid/data_grid/controller/interceptors/data_grid_interceptor.dart';

class ValidationInterceptor<T extends DataGridRow> extends DataGridInterceptor<T> {
  final bool Function(double rowId, int columnId)? canEditCell;
  final bool Function(double rowId)? canSelectRow;
  final Future<bool> Function(double rowId, int columnId, dynamic oldValue, dynamic newValue)? onCellCommit;

  ValidationInterceptor({this.canEditCell, this.canSelectRow, this.onCellCommit});

  @override
  DataGridEvent? onBeforeEvent(DataGridEvent event, DataGridState<T> state) {
    if (event is StartCellEditEvent && canEditCell != null) {
      if (!canEditCell!(event.rowId, event.columnId)) {
        return null;
      }
    }

    if (event is SelectRowEvent && canSelectRow != null) {
      if (!canSelectRow!(event.rowId)) {
        return null;
      }
    }

    return event;
  }

  @override
  DataGridState<T>? onBeforeStateUpdate(DataGridState<T> newState, DataGridState<T> oldState, DataGridEvent? event) {
    if (event is CommitCellEditEvent && onCellCommit != null && oldState.edit.isEditing) {
      final cellId = oldState.edit.editingCellId!;
      final parts = cellId.split('_');
      final rowId = double.parse(parts[0]);
      final columnId = int.parse(parts[1]);
      final oldValue = oldState.rowsById[rowId];
      final newValue = oldState.edit.editingValue;

      onCellCommit!(rowId, columnId, oldValue, newValue).then((allowed) {
        if (!allowed) {
          return oldState;
        }
      });
    }

    return newState;
  }
}
