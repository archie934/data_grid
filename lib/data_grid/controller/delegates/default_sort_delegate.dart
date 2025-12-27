import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/utils/data_indexer.dart';
import 'package:data_grid/data_grid/utils/isolate_sort.dart';
import 'package:data_grid/data_grid/controller/delegates/sort_delegate.dart';

/// Default sort delegate with debouncing and isolate-based sorting for large datasets.
class DefaultSortDelegate<T extends DataGridRow> extends SortDelegate<T> {
  final DataIndexer<T> _dataIndexer;
  final Duration _debounce;
  final int _isolateThreshold;

  Timer? _debounceTimer;

  DefaultSortDelegate({
    required DataIndexer<T> dataIndexer,
    required Duration sortDebounce,
    int isolateThreshold = 10000,
  }) : _dataIndexer = dataIndexer,
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
      final updatedSortColumns = _updateSortColumns(event, currentState.sort);
      final updatedSort = currentState.sort.copyWith(sortColumns: updatedSortColumns);

      if (updatedSortColumns.isEmpty) {
        final result = SortResult(
          sortState: updatedSort.copyWith(sortColumns: []),
          displayIndices: currentState.filter.hasFilters
              ? _dataIndexer.filter(
                  currentState.rows,
                  currentState.filter.columnFilters.values.toList(),
                  currentState.columns,
                )
              : List<int>.generate(currentState.rows.length, (i) => i),
        );
        onComplete(result);
        completer.complete(result);
        return;
      }

      try {
        final indicesToSort = currentState.filter.hasFilters
            ? _dataIndexer.filter(
                currentState.rows,
                currentState.filter.columnFilters.values.toList(),
                currentState.columns,
              )
            : List<int>.generate(currentState.rows.length, (i) => i);

        final List<int> sortedIndices;

        if (currentState.rows.length > _isolateThreshold) {
          final columnValues = <List<dynamic>>[];
          for (final sortCol in updatedSortColumns) {
            final column = currentState.columns.firstWhere((c) => c.id == sortCol.columnId);
            final values = currentState.rows.map((row) => _dataIndexer.getCellValue(row, column)).toList();
            columnValues.add(values);
          }

          final params = SortParameters(
            columnValues: columnValues,
            sortColumns: updatedSortColumns,
            rowCount: indicesToSort.length,
          );

          final isolateResult = await compute(performSortInIsolate, params);
          sortedIndices = isolateResult.map((idx) => indicesToSort[idx]).toList();
        } else {
          sortedIndices = _dataIndexer.sortIndices(
            currentState.rows,
            indicesToSort,
            updatedSortColumns,
            currentState.columns,
          );
        }

        final result = SortResult(sortState: updatedSort, displayIndices: sortedIndices);
        onComplete(result);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  List<SortColumn> _updateSortColumns(SortEvent event, SortState currentSort) {
    final existing = currentSort.sortColumns.where((s) => s.columnId == event.columnId).firstOrNull;
    final updatedColumns = currentSort.sortColumns.where((s) => s.columnId != event.columnId).toList();

    if (existing == null) {
      return [
        ...updatedColumns,
        SortColumn(columnId: event.columnId, direction: SortDirection.ascending, priority: updatedColumns.length),
      ];
    } else if (existing.direction == SortDirection.ascending) {
      return [
        ...updatedColumns,
        SortColumn(columnId: event.columnId, direction: SortDirection.descending, priority: updatedColumns.length),
      ];
    } else {
      return updatedColumns;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
  }
}
