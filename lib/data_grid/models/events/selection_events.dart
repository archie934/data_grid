import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/base_event.dart';
import 'package:data_grid/data_grid/models/events/event_context.dart';

class SelectRowEvent extends DataGridEvent {
  final double rowId;
  final bool multiSelect;

  SelectRowEvent({required this.rowId, this.multiSelect = false});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final selectedRows = Set<double>.from(context.state.selection.selectedRowIds);

    if (multiSelect) {
      if (selectedRows.contains(rowId)) {
        selectedRows.remove(rowId);
      } else {
        selectedRows.add(rowId);
      }
    } else {
      if (selectedRows.contains(rowId) && selectedRows.length == 1) {
        selectedRows.clear();
      } else {
        selectedRows.clear();
        selectedRows.add(rowId);
      }
    }

    return context.state.copyWith(
      selection: context.state.selection.copyWith(selectedRowIds: selectedRows, focusedRowId: rowId),
    );
  }
}

class SelectRowsRangeEvent extends DataGridEvent {
  final double startRowId;
  final double endRowId;

  SelectRowsRangeEvent({required this.startRowId, required this.endRowId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final selectedRows = Set<double>.from(context.state.selection.selectedRowIds);
    final start = startRowId < endRowId ? startRowId : endRowId;
    final end = startRowId < endRowId ? endRowId : startRowId;

    for (double i = start; i <= end; i++) {
      selectedRows.add(i);
    }

    return context.state.copyWith(selection: context.state.selection.copyWith(selectedRowIds: selectedRows));
  }
}

class ClearSelectionEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(selection: SelectionState.initial());
  }
}
