import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/base_event.dart';
import 'package:data_grid/models/events/event_context.dart';
import 'package:data_grid/models/enums/selection_mode.dart';

class NavigateUpEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none) {
      return null;
    }

    final focusedRowId = context.state.selection.focusedRowId;
    if (focusedRowId == null) return null;

    final currentIndex = context.state.displayOrder.indexOf(focusedRowId);
    if (currentIndex <= 0) return null;

    final newRowId = context.state.displayOrder[currentIndex - 1];
    return context.state.copyWith(
      selection: context.state.selection.copyWith(focusedRowId: newRowId, selectedRowIds: {newRowId}),
    );
  }
}

class NavigateDownEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none) {
      return null;
    }

    final focusedRowId = context.state.selection.focusedRowId;
    if (focusedRowId == null) {
      if (context.state.displayOrder.isEmpty) return null;
      final firstRowId = context.state.displayOrder.first;
      return context.state.copyWith(
        selection: context.state.selection.copyWith(focusedRowId: firstRowId, selectedRowIds: {firstRowId}),
      );
    }

    final currentIndex = context.state.displayOrder.indexOf(focusedRowId);
    if (currentIndex >= context.state.displayOrder.length - 1) return null;

    final newRowId = context.state.displayOrder[currentIndex + 1];
    return context.state.copyWith(
      selection: context.state.selection.copyWith(focusedRowId: newRowId, selectedRowIds: {newRowId}),
    );
  }
}

class NavigateLeftEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return null;
  }
}

class NavigateRightEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return null;
  }
}

class SelectAllVisibleEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none) {
      return null;
    }

    final viewport = context.state.viewport;
    final visibleRowIds = <double>{};

    for (int i = viewport.firstVisibleRow; i <= viewport.lastVisibleRow && i < context.state.displayOrder.length; i++) {
      visibleRowIds.add(context.state.displayOrder[i]);
    }

    return context.state.copyWith(selection: context.state.selection.copyWith(selectedRowIds: visibleRowIds));
  }
}
