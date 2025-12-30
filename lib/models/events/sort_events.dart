import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';

class SortEvent extends DataGridEvent {
  final int columnId;
  final SortDirection? direction;

  SortEvent({required this.columnId, this.direction});

  @override
  bool shouldShowLoading(DataGridState state) => state.rowsById.length > 1000;

  @override
  String? loadingMessage() => 'Sorting data...';

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    context.sortDelegate.handleSort(this, context.state, (result) {
      final newState = context.state.copyWith(sort: result.sortState, displayOrder: result.displayOrder);
      context.dispatchEvent(SortCompleteEvent(newState: newState));
    });
    return null;
  }
}

class SortCompleteEvent<T extends DataGridRow> extends DataGridEvent {
  final DataGridState<T> newState;

  SortCompleteEvent({required this.newState});

  @override
  DataGridState<R>? apply<R extends DataGridRow>(EventContext<R> context) {
    return (newState as DataGridState<R>).copyWith(isLoading: false);
  }
}
