import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/base_event.dart';
import 'package:data_grid/data_grid/models/events/event_context.dart';

class FilterEvent extends DataGridEvent {
  final int columnId;
  final FilterOperator operator;
  final dynamic value;

  FilterEvent({required this.columnId, required this.operator, required this.value});

  @override
  bool shouldShowLoading(DataGridState state) => state.rows.length > 1000;

  @override
  String? loadingMessage() => 'Filtering data...';

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final updatedFilters = Map<int, ColumnFilter>.from(context.state.filter.columnFilters);
    updatedFilters[columnId] = ColumnFilter(columnId: columnId, operator: operator, value: value);

    final updatedFilter = context.state.filter.copyWith(columnFilters: updatedFilters);

    final filteredIndices = context.dataIndexer.filter(
      context.state.rows,
      updatedFilters.values.toList(),
      context.state.columns,
    );

    final sortedIndices = context.state.sort.hasSort
        ? context.dataIndexer.sortIndices(
            context.state.rows,
            filteredIndices,
            context.state.sort.sortColumns,
            context.state.columns,
          )
        : filteredIndices;

    return context.state.copyWith(filter: updatedFilter, displayIndices: sortedIndices);
  }
}

class ClearFilterEvent extends DataGridEvent {
  final int? columnId;

  ClearFilterEvent({this.columnId});

  @override
  bool shouldShowLoading(DataGridState state) => state.rows.length > 1000;

  @override
  String? loadingMessage() => 'Clearing filters...';

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final updatedFilters = Map<int, ColumnFilter>.from(context.state.filter.columnFilters);

    if (columnId != null) {
      updatedFilters.remove(columnId);
    } else {
      updatedFilters.clear();
    }

    final updatedFilter = context.state.filter.copyWith(columnFilters: updatedFilters);

    final filteredIndices = updatedFilters.isEmpty
        ? List<int>.generate(context.state.rows.length, (i) => i)
        : context.dataIndexer.filter(context.state.rows, updatedFilters.values.toList(), context.state.columns);

    final sortedIndices = context.state.sort.hasSort
        ? context.dataIndexer.sortIndices(
            context.state.rows,
            filteredIndices,
            context.state.sort.sortColumns,
            context.state.columns,
          )
        : filteredIndices;

    return context.state.copyWith(filter: updatedFilter, displayIndices: sortedIndices);
  }
}
