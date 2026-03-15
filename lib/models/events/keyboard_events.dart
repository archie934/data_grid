import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/models/events/cell_selection_events.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

/// Moves focus up by one cell (or row when no cell is active).
class NavigateUpEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none &&
        context.state.selection.activeCellId == null) {
      return null;
    }
    return NavigateCellEvent(CellNavDirection.up).apply(context);
  }
}

/// Moves focus down by one cell (or row when no cell is active).
class NavigateDownEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    if (context.state.selection.mode == SelectionMode.none &&
        context.state.selection.activeCellId == null) {
      return null;
    }
    return NavigateCellEvent(CellNavDirection.down).apply(context);
  }
}

/// Moves focus left by one cell (no-op when no cell is active).
class NavigateLeftEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return NavigateCellEvent(CellNavDirection.left).apply(context);
  }
}

/// Moves focus right by one cell (no-op when no cell is active).
class NavigateRightEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return NavigateCellEvent(CellNavDirection.right).apply(context);
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
