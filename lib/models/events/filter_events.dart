import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';

class FilterEvent extends DataGridEvent {
  final int columnId;
  final FilterOperator operator;
  final dynamic value;

  FilterEvent({
    required this.columnId,
    required this.operator,
    required this.value,
  });

  @override
  bool shouldShowLoading(DataGridState state) => state.rowsById.length > 10000;

  @override
  String? loadingMessage() => 'Filtering data...';

  @override
  Future<DataGridState<T>?> apply<T extends DataGridRow>(
    EventContext<T> context,
  ) async {
    // Check if column is filterable
    final column = context.state.columns.firstWhere(
      (c) => c.id == columnId,
      orElse: () => throw StateError('Column $columnId not found'),
    );
    if (!column.filterable) return null;

    final updatedFilters = Map<int, ColumnFilter>.from(
      context.state.filter.columnFilters,
    );
    updatedFilters[columnId] = ColumnFilter(
      columnId: columnId,
      operator: operator,
      value: value,
    );

    final updatedFilter = context.state.filter.copyWith(
      columnFilters: updatedFilters,
    );

    final filteredIds = await context.filterDelegate.applyFilters(
      rowsById: context.state.rowsById,
      filters: updatedFilters.values.toList(),
      columns: context.state.columns,
    );

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            context.state.rowsById,
            filteredIds,
            context.state.sort.sortColumn!,
            context.state.columns,
          )
        : filteredIds;

    return context.state.copyWith(
      filter: updatedFilter,
      displayOrder: sortedIds,
    );
  }
}

class ClearFilterEvent extends DataGridEvent {
  final int? columnId;

  ClearFilterEvent({this.columnId});

  @override
  bool shouldShowLoading(DataGridState state) => state.rowsById.length > 10000;

  @override
  String? loadingMessage() => 'Clearing filters...';

  @override
  Future<DataGridState<T>?> apply<T extends DataGridRow>(
    EventContext<T> context,
  ) async {
    final updatedFilters = Map<int, ColumnFilter>.from(
      context.state.filter.columnFilters,
    );

    if (columnId != null) {
      updatedFilters.remove(columnId);
    } else {
      updatedFilters.clear();
    }

    final updatedFilter = context.state.filter.copyWith(
      columnFilters: updatedFilters,
    );

    final filteredIds = updatedFilters.isEmpty
        ? context.state.rowsById.keys.toList()
        : await context.filterDelegate.applyFilters(
            rowsById: context.state.rowsById,
            filters: updatedFilters.values.toList(),
            columns: context.state.columns,
          );

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            context.state.rowsById,
            filteredIds,
            context.state.sort.sortColumn!,
            context.state.columns,
          )
        : filteredIds;

    return context.state.copyWith(
      filter: updatedFilter,
      displayOrder: sortedIds,
    );
  }
}
