import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/grid_events.dart';
import 'package:data_grid/utils/data_indexer.dart';
import 'package:data_grid/utils/isolate_sort.dart';
import 'package:data_grid/delegates/sort_delegate.dart';
import 'package:data_grid/delegates/filter_delegate.dart';

/// Default sort delegate with debouncing and isolate-based sorting for large datasets.
class DefaultSortDelegate<T extends DataGridRow> extends SortDelegate<T> {
  final DataIndexer<T> _dataIndexer;
  final FilterDelegate<T>? _filterDelegate;
  final Duration _debounce;
  final int _isolateThreshold;

  Timer? _debounceTimer;

  DefaultSortDelegate({
    required DataIndexer<T> dataIndexer,
    required Duration sortDebounce,
    int isolateThreshold = 10000,
    FilterDelegate<T>? filterDelegate,
  }) : _dataIndexer = dataIndexer,
       _filterDelegate = filterDelegate,
       _debounce = sortDebounce,
       _isolateThreshold = isolateThreshold;

  @override
  Future<SortResult?> handleSort(
    SortEvent event,
    DataGridState<T> currentState,
    void Function(SortResult) onComplete,
  ) async {
    _debounceTimer?.cancel();

    final completer = Completer<SortResult?>();

    _debounceTimer = Timer(_debounce, () async {
      final updatedSortColumn = _updateSortColumn(event, currentState.sort);
      final updatedSort = currentState.sort.copyWith(sortColumn: updatedSortColumn);

      if (updatedSortColumn == null) {
        final displayOrder = currentState.filter.hasFilters && _filterDelegate != null
            ? await _filterDelegate.applyFilters(
                rowsById: currentState.rowsById,
                filters: currentState.filter.columnFilters.values.toList(),
                columns: currentState.columns,
              )
            : currentState.rowsById.keys.toList();

        final result = SortResult(sortState: updatedSort, displayOrder: displayOrder);
        onComplete(result);
        completer.complete(result);
        return;
      }

      try {
        final idsToSort = currentState.filter.hasFilters && _filterDelegate != null
            ? await _filterDelegate.applyFilters(
                rowsById: currentState.rowsById,
                filters: currentState.filter.columnFilters.values.toList(),
                columns: currentState.columns,
              )
            : currentState.rowsById.keys.toList();

        final List<double> sortedIds;
        final column = currentState.columns.firstWhere((c) => c.id == updatedSortColumn.columnId);

        if (currentState.rowsById.length > _isolateThreshold) {
          final values = idsToSort.map((id) => _dataIndexer.getCellValue(currentState.rowsById[id]!, column)).toList();

          final params = SortParameters(
            columnValues: values,
            direction: updatedSortColumn.direction,
            rowCount: idsToSort.length,
          );

          final isolateResult = await compute(performSortInIsolate, params);
          sortedIds = isolateResult.map((idx) => idsToSort[idx]).toList();
        } else {
          sortedIds = _dataIndexer.sortIds(currentState.rowsById, idsToSort, updatedSortColumn, currentState.columns);
        }

        final result = SortResult(sortState: updatedSort, displayOrder: sortedIds);
        onComplete(result);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  SortColumn? _updateSortColumn(SortEvent event, SortState currentSort) {
    // If direction is explicitly provided, use it
    if (event.direction != null) {
      return SortColumn(columnId: event.columnId, direction: event.direction!);
    }

    // Direction is null - clear sort for this column
    // If this column was sorted, clear it; otherwise return current state
    final existing = currentSort.sortColumn;
    if (existing != null && existing.columnId == event.columnId) {
      return null; // Clear the sort
    }

    // Column wasn't sorted, nothing to clear
    return existing;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
  }
}
