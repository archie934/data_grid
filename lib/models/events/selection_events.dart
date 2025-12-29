import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/base_event.dart';
import 'package:data_grid/models/events/event_context.dart';
import 'package:data_grid/models/enums/selection_mode.dart';

class SelectRowEvent extends DataGridEvent {
  final double rowId;
  final bool multiSelect;

  SelectRowEvent({required this.rowId, this.multiSelect = false});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none) {
      return null;
    }

    if (context.canSelectRow != null && !context.canSelectRow!(rowId)) {
      return null;
    }

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
    if (context.state.selection.mode == SelectionMode.none) {
      return null;
    }

    final selectedRows = Set<double>.from(context.state.selection.selectedRowIds);

    final startIdx = context.state.displayOrder.indexOf(startRowId);
    final endIdx = context.state.displayOrder.indexOf(endRowId);

    if (startIdx == -1 || endIdx == -1) {
      return null;
    }

    final minIdx = startIdx < endIdx ? startIdx : endIdx;
    final maxIdx = startIdx < endIdx ? endIdx : startIdx;

    final rangeIds = context.state.displayOrder.sublist(minIdx, maxIdx + 1);
    selectedRows.addAll(rangeIds);

    return context.state.copyWith(selection: context.state.selection.copyWith(selectedRowIds: selectedRows));
  }
}

class ClearSelectionEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(
      selection: context.state.selection.copyWith(selectedRowIds: {}, selectedCellIds: {}, focusedRowId: null),
    );
  }
}

class SelectAllRowsEvent extends DataGridEvent {
  final Set<double>? rowIds;

  SelectAllRowsEvent({this.rowIds});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none) {
      return null;
    }

    final Set<double> visibleRowIds;

    if (rowIds != null) {
      visibleRowIds = rowIds!;
    } else {
      visibleRowIds = <double>{};
      final viewport = context.state.viewport;
      for (
        int i = viewport.firstVisibleRow;
        i <= viewport.lastVisibleRow && i < context.state.displayOrder.length;
        i++
      ) {
        visibleRowIds.add(context.state.displayOrder[i]);
      }
    }

    return context.state.copyWith(selection: context.state.selection.copyWith(selectedRowIds: visibleRowIds));
  }
}

class SetSelectionModeEvent extends DataGridEvent {
  final SelectionMode mode;

  SetSelectionModeEvent({required this.mode});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == mode) {
      return null;
    }

    return context.state.copyWith(
      selection: context.state.selection.copyWith(
        mode: mode,
        selectedRowIds: {},
        selectedCellIds: {},
        focusedRowId: null,
      ),
    );
  }
}
