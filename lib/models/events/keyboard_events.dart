import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

/// Moves the focused row up by one position.
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
      selection: context.state.selection.copyWith(
        focusedRowId: newRowId,
        selectedRowIds: {newRowId},
      ),
    );
  }
}

/// Moves the focused row down by one position.
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
        selection: context.state.selection.copyWith(
          focusedRowId: firstRowId,
          selectedRowIds: {firstRowId},
        ),
      );
    }

    final currentIndex = context.state.displayOrder.indexOf(focusedRowId);
    if (currentIndex >= context.state.displayOrder.length - 1) return null;

    final newRowId = context.state.displayOrder[currentIndex + 1];
    return context.state.copyWith(
      selection: context.state.selection.copyWith(
        focusedRowId: newRowId,
        selectedRowIds: {newRowId},
      ),
    );
  }
}

/// Moves the focused column left by one position.
class NavigateLeftEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return null;
  }
}

/// Moves the focused column right by one position.
class NavigateRightEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return null;
  }
}

/// Selects all currently visible rows.
class SelectAllVisibleEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none) {
      return null;
    }

    return context.state.copyWith(
      selection: context.state.selection.copyWith(
        selectedRowIds: context.state.displayOrder.toSet(),
      ),
    );
  }
}
