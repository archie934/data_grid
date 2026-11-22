import 'dart:math' as math;
import 'package:flutter_data_grid/models/data/cell_value_change.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';

/// Loads a new set of rows into the grid, optionally appending to existing data.
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

/// Triggers a data refresh by setting the loading flag.
class RefreshDataEvent extends DataGridEvent {
  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(isLoading: true);
  }
}

/// Explicitly sets the loading state and optional message.
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

/// Sets the total item count (used for server-side pagination).
class SetTotalItemsEvent extends DataGridEvent {
  final int totalItems;

  SetTotalItemsEvent({required this.totalItems});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    return context.state.copyWith(totalItems: totalItems);
  }
}

/// Inserts a single row, optionally at a specific position.
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

/// Inserts multiple rows at the end of the grid.
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

/// Deletes a single row by its ID.
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

    final newTotalItems = context.state.totalItems - 1;
    final pagination = context.state.pagination;
    final newTotalPages = pagination.totalPages(newTotalItems);
    final adjustedPage = pagination.currentPage > newTotalPages
        ? newTotalPages
        : pagination.currentPage;

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: newDisplayOrder,
      totalItems: newTotalItems,
      pagination: pagination.copyWith(currentPage: adjustedPage),
      selection: context.state.selection.copyWith(
        selectedRowIds: selectedRows,
        focusedRowId: context.state.selection.focusedRowId == rowId
            ? null
            : context.state.selection.focusedRowId,
      ),
    );
  }
}

/// Deletes multiple rows by their IDs.
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

    final removedCount = context.state.rowsById.length - newRowsById.length;
    final newTotalItems = context.state.totalItems - removedCount;
    final pagination = context.state.pagination;
    final newTotalPages = pagination.totalPages(newTotalItems);
    final adjustedPage = pagination.currentPage > newTotalPages
        ? newTotalPages
        : pagination.currentPage;

    return context.state.copyWith(
      rowsById: newRowsById,
      displayOrder: newDisplayOrder,
      totalItems: newTotalItems,
      pagination: pagination.copyWith(currentPage: adjustedPage),
      selection: context.state.selection.copyWith(
        selectedRowIds: selectedRows,
        focusedRowId: rowIds.contains(context.state.selection.focusedRowId)
            ? null
            : context.state.selection.focusedRowId,
      ),
    );
  }
}

/// Replaces an entire row with a new instance.
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

/// Asks cells to re-read their value, without changing any state.
///
/// The grid keeps edited rows out of the immutable state path on purpose — a
/// `cellValueSetter` mutates the [DataGridRow] in place and the affected cells
/// are notified through [DataGridController.cellValueChanges] (see AGENTS.md's
/// cell-edit fast path). Cells decide whether to rebuild by diffing what their
/// own [DataGridColumn.valueAccessor] returns, which covers every value the
/// grid can actually see.
///
/// Dispatch this event for the cases it can't:
///
/// * a row was mutated by application code rather than through
///   [UpdateCellEvent] / an inline edit, so no notification was ever emitted;
/// * a column has no `valueAccessor`, or its `cellWidget` reads fields straight
///   off `CellScope.row`, so there is nothing to diff.
///
/// Refreshing is strictly a render concern: no state is produced, `rowsById`
/// and `displayOrder` keep their identity, and the virtualization window is
/// untouched. Only the cells named here rebuild.
///
/// ```dart
/// order.applyDiscount(0.1);            // mutates several fields at once
/// controller.refreshCells(rowIds: [order.id]);
/// ```
class RefreshCellsEvent extends DataGridEvent {
  /// Rows to refresh. Empty means every row currently held by the grid.
  final List<double> rowIds;

  /// Columns to refresh within [rowIds]. Null refreshes every column of those
  /// rows — the usual case, since the point is that the caller doesn't know
  /// which columns derive from what changed.
  final List<int>? columnIds;

  const RefreshCellsEvent({this.rowIds = const [], this.columnIds});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final notify = context.notifyCellValueChanged;
    if (notify == null) return null;

    final rows = rowIds.isEmpty ? context.state.rowsById.keys : rowIds;
    final columns =
        columnIds ?? context.state.columns.map((c) => c.id).toList();

    for (final rowId in rows) {
      for (final columnId in columns) {
        notify(
          CellValueChange(
            rowId: rowId,
            columnId: columnId,
            value: null,
            source: CellValueChangeSource.refresh,
          ),
        );
      }
    }

    // Deliberately no state change: this event exists precisely so a render
    // refresh doesn't have to cost a state emission.
    return null;
  }
}

/// Updates a single cell value on an existing row.
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
    if (column.cellValueSetter == null) {
      return null;
    }

    column.cellValueSetter!(row, value);
    context.notifyCellValueChanged?.call(
      CellValueChange(
        rowId: rowId,
        columnId: columnId,
        value: value,
        source: CellValueChangeSource.programmatic,
      ),
    );

    return context.state;
  }
}
