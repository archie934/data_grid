import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:data_grid/models/data/row.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/events/grid_events.dart';
import 'package:data_grid/models/enums/sort_direction.dart';
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
      final updatedSortColumns = _updateSortColumns(event, currentState.sort);
      final updatedSort = currentState.sort.copyWith(sortColumns: updatedSortColumns);

      if (updatedSortColumns.isEmpty) {
        final displayOrder = currentState.filter.hasFilters && _filterDelegate != null
            ? await _filterDelegate.applyFilters(
                rowsById: currentState.rowsById,
                filters: currentState.filter.columnFilters.values.toList(),
                columns: currentState.columns,
              )
            : currentState.rowsById.keys.toList();

        final result = SortResult(
          sortState: updatedSort.copyWith(sortColumns: []),
          displayOrder: displayOrder,
        );
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

        if (currentState.rowsById.length > _isolateThreshold) {
          final columnValues = <List<dynamic>>[];
          for (final sortCol in updatedSortColumns) {
            final column = currentState.columns.firstWhere((c) => c.id == sortCol.columnId);
            final values = idsToSort
                .map((id) => _dataIndexer.getCellValue(currentState.rowsById[id]!, column))
                .toList();
            columnValues.add(values);
          }

          final params = SortParameters(
            columnValues: columnValues,
            sortColumns: updatedSortColumns,
            rowCount: idsToSort.length,
          );

          final isolateResult = await compute(performSortInIsolate, params);
          sortedIds = isolateResult.map((idx) => idsToSort[idx]).toList();
        } else {
          sortedIds = _dataIndexer.sortIds(currentState.rowsById, idsToSort, updatedSortColumns, currentState.columns);
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
