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
  bool shouldShowLoading(DataGridState state) => state.rowsById.length > 1000;

  @override
  String? loadingMessage() => 'Filtering data...';

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final updatedFilters = Map<int, ColumnFilter>.from(context.state.filter.columnFilters);
    updatedFilters[columnId] = ColumnFilter(columnId: columnId, operator: operator, value: value);

    final updatedFilter = context.state.filter.copyWith(columnFilters: updatedFilters);

    final filteredIds = context.dataIndexer.filter(
      context.state.rowsById,
      updatedFilters.values.toList(),
      context.state.columns,
    );

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            context.state.rowsById,
            filteredIds,
            context.state.sort.sortColumns,
            context.state.columns,
          )
        : filteredIds;

    return context.state.copyWith(filter: updatedFilter, displayOrder: sortedIds);
  }
}

class ClearFilterEvent extends DataGridEvent {
  final int? columnId;

  ClearFilterEvent({this.columnId});

  @override
  bool shouldShowLoading(DataGridState state) => state.rowsById.length > 1000;

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

    final filteredIds = updatedFilters.isEmpty
        ? context.state.rowsById.keys.toList()
        : context.dataIndexer.filter(context.state.rowsById, updatedFilters.values.toList(), context.state.columns);

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            context.state.rowsById,
            filteredIds,
            context.state.sort.sortColumns,
            context.state.columns,
          )
        : filteredIds;

    return context.state.copyWith(filter: updatedFilter, displayOrder: sortedIds);
  }
}
