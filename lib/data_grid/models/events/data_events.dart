import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/base_event.dart';
import 'package:data_grid/data_grid/models/events/event_context.dart';

class LoadDataEvent<T> extends DataGridEvent {
  final List<T> rows;
  final bool append;

  LoadDataEvent({required this.rows, this.append = false});

  @override
  DataGridState<TRow>? apply<TRow extends DataGridRow>(EventContext<TRow> context) {
    final newRows = append ? [...context.state.rows, ...rows as List<TRow>] : rows as List<TRow>;

    context.dataIndexer.setData(newRows);

    final filteredIndices = context.state.filter.hasFilters
        ? context.dataIndexer.filter(newRows, context.state.filter.columnFilters.values.toList(), context.state.columns)
        : List<int>.generate(newRows.length, (i) => i);

    final sortedIndices = context.state.sort.hasSort
        ? context.dataIndexer.sortIndices(
            newRows,
            filteredIndices,
            context.state.sort.sortColumns,
            context.state.columns,
          )
        : filteredIndices;

    return context.state.copyWith(rows: newRows, displayIndices: sortedIndices, isLoading: false);
  }
}

class RefreshDataEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(isLoading: true);
  }
}

class SetLoadingEvent extends DataGridEvent {
  final bool isLoading;
  final String? message;

  SetLoadingEvent({required this.isLoading, this.message});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(isLoading: isLoading, loadingMessage: message);
  }
}
