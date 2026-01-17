import 'dart:math' as math;
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';

class LoadDataEvent<T> extends DataGridEvent {
  final List<T> rows;
  final bool append;

  LoadDataEvent({required this.rows, this.append = false});

  @override
  Future<DataGridState<TRow>?> apply<TRow extends DataGridRow>(
    EventContext<TRow> context,
  ) async {
    final rowsMap = {for (var row in rows) (row as TRow).id: row as TRow};
    final newRowsById = append
        ? {...context.state.rowsById, ...rowsMap}
        : rowsMap;

    context.dataIndexer.setData(newRowsById);

    final filteredIds = context.state.filter.hasFilters
        ? await context.filterDelegate.applyFilters(
            rowsById: newRowsById,
            filters: context.state.filter.columnFilters.values.toList(),
            columns: context.state.columns,
          )
        : newRowsById.keys.toList();

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            newRowsById,
            filteredIds,
            context.state.sort.sortColumn!,
            context.state.columns,
          )
        : filteredIds;

    final totalItems = sortedIds.length;

    List<double> finalDisplayOrder;
    if (context.state.pagination.enabled &&
        !context.state.pagination.serverSide) {
      final startIndex = context.state.pagination.startIndex(totalItems);
      final endIndex = context.state.pagination.endIndex(totalItems);
      finalDisplayOrder = sortedIds.sublist(
        math.min(startIndex, sortedIds.length),
        math.min(endIndex, sortedIds.length),
      );
    } else {
      finalDisplayOrder = sortedIds;
    }

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: finalDisplayOrder,
      totalItems: totalItems,
      isLoading: false,
    );
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
    return context.state.copyWith(
      isLoading: isLoading,
      loadingMessage: message,
    );
  }
}

class SetTotalItemsEvent extends DataGridEvent {
  final int totalItems;

  SetTotalItemsEvent({required this.totalItems});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(totalItems: totalItems);
  }
}

class InsertRowEvent extends DataGridEvent {
  final DataGridRow row;
  final int? position;

  InsertRowEvent({required this.row, this.position});

  @override
  Future<DataGridState<T>?> apply<T extends DataGridRow>(
    EventContext<T> context,
  ) async {
    final newRowsById = Map<double, T>.from(context.state.rowsById);
    final isNew = !newRowsById.containsKey(row.id);
    newRowsById[row.id] = row as T;

    final newDisplayOrder = List<double>.from(context.state.displayOrder);
    if (isNew) {
      if (position != null &&
          position! >= 0 &&
          position! <= newDisplayOrder.length) {
        newDisplayOrder.insert(position!, row.id);
      } else {
        newDisplayOrder.add(row.id);
      }
    }

    context.dataIndexer.setData(newRowsById);

    final filteredIds = context.state.filter.hasFilters
        ? await context.filterDelegate.applyFilters(
            rowsById: newRowsById,
            filters: context.state.filter.columnFilters.values.toList(),
            columns: context.state.columns,
          )
        : newDisplayOrder;

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            newRowsById,
            filteredIds,
            context.state.sort.sortColumn!,
            context.state.columns,
          )
        : filteredIds;

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: sortedIds,
    );
  }
}

class InsertRowsEvent extends DataGridEvent {
  final List<DataGridRow> rows;

  InsertRowsEvent({required this.rows});

  @override
  Future<DataGridState<T>?> apply<T extends DataGridRow>(
    EventContext<T> context,
  ) async {
    final newRowsById = Map<double, T>.from(context.state.rowsById);
    for (final row in rows) {
      newRowsById[row.id] = row as T;
    }

    final newDisplayOrder = List<double>.from(context.state.displayOrder);
    for (final row in rows) {
      if (!newDisplayOrder.contains(row.id)) {
        newDisplayOrder.add(row.id);
      }
    }

    context.dataIndexer.setData(newRowsById);

    final filteredIds = context.state.filter.hasFilters
        ? await context.filterDelegate.applyFilters(
            rowsById: newRowsById,
            filters: context.state.filter.columnFilters.values.toList(),
            columns: context.state.columns,
          )
        : newDisplayOrder;

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            newRowsById,
            filteredIds,
            context.state.sort.sortColumn!,
            context.state.columns,
          )
        : filteredIds;

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: sortedIds,
    );
  }
}

class DeleteRowEvent extends DataGridEvent {
  final double rowId;

  DeleteRowEvent({required this.rowId});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final newRowsById = Map<double, T>.from(context.state.rowsById);
    newRowsById.remove(rowId);

    final newDisplayOrder = context.state.displayOrder
        .where((id) => id != rowId)
        .toList();

    context.dataIndexer.setData(newRowsById);

    final selectedRows = Set<double>.from(
      context.state.selection.selectedRowIds,
    );
    selectedRows.remove(rowId);

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: newDisplayOrder,
      selection: context.state.selection.copyWith(
        selectedRowIds: selectedRows,
        focusedRowId: context.state.selection.focusedRowId == rowId
            ? null
            : context.state.selection.focusedRowId,
      ),
    );
  }
}

class DeleteRowsEvent extends DataGridEvent {
  final Set<double> rowIds;

  DeleteRowsEvent({required this.rowIds});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final newRowsById = Map<double, T>.from(context.state.rowsById);
    for (final id in rowIds) {
      newRowsById.remove(id);
    }

    final newDisplayOrder = context.state.displayOrder
        .where((id) => !rowIds.contains(id))
        .toList();

    context.dataIndexer.setData(newRowsById);

    final selectedRows = Set<double>.from(
      context.state.selection.selectedRowIds,
    );
    selectedRows.removeAll(rowIds);

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: newDisplayOrder,
      selection: context.state.selection.copyWith(
        selectedRowIds: selectedRows,
        focusedRowId: rowIds.contains(context.state.selection.focusedRowId)
            ? null
            : context.state.selection.focusedRowId,
      ),
    );
  }
}

class UpdateRowEvent extends DataGridEvent {
  final double rowId;
  final DataGridRow newRow;

  UpdateRowEvent({required this.rowId, required this.newRow});

  @override
  Future<DataGridState<T>?> apply<T extends DataGridRow>(
    EventContext<T> context,
  ) async {
    if (!context.state.rowsById.containsKey(rowId)) {
      return null;
    }

    final newRowsById = Map<double, T>.from(context.state.rowsById);
    newRowsById[rowId] = newRow as T;

    context.dataIndexer.setData(newRowsById);

    final filteredIds = context.state.filter.hasFilters
        ? await context.filterDelegate.applyFilters(
            rowsById: newRowsById,
            filters: context.state.filter.columnFilters.values.toList(),
            columns: context.state.columns,
          )
        : context.state.displayOrder;

    final sortedIds = context.state.sort.hasSort
        ? context.dataIndexer.sortIds(
            newRowsById,
            filteredIds,
            context.state.sort.sortColumn!,
            context.state.columns,
          )
        : filteredIds;

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: sortedIds,
    );
  }
}

class UpdateCellEvent extends DataGridEvent {
  final double rowId;
  final int columnId;
  final dynamic value;

  UpdateCellEvent({
    required this.rowId,
    required this.columnId,
    required this.value,
  });

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final row = context.state.rowsById[rowId];
    if (row == null) {
      return null;
    }

    final column = context.state.columns.firstWhere((c) => c.id == columnId);
    if (column.cellValueSetter != null) {
      column.cellValueSetter!(row, value);
    }

    final newRowsById = Map<double, T>.of(context.state.rowsById);
    context.dataIndexer.setData(newRowsById);

    return context.state.copyWith(rowsById: newRowsById);
  }
}
