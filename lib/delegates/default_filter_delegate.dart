import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/utils/data_indexer.dart';
import 'package:flutter_data_grid/utils/isolate_filter.dart';
import 'package:flutter_data_grid/delegates/filter_delegate.dart';

class DefaultFilterDelegate<T extends DataGridRow> extends FilterDelegate<T> {
  final DataIndexer<T> _dataIndexer;
  final Duration _debounce;
  final int _isolateThreshold;

  Timer? _debounceTimer;

  DefaultFilterDelegate({
    required DataIndexer<T> dataIndexer,
    required Duration filterDebounce,
    int isolateThreshold = 10000,
  }) : _dataIndexer = dataIndexer,
       _debounce = filterDebounce,
       _isolateThreshold = isolateThreshold;

  @override
  Future<List<double>> applyFilters({
    required Map<double, T> rowsById,
    required List<ColumnFilter> filters,
    required List<DataGridColumn<T>> columns,
  }) async {
    final completer = Completer<List<double>>();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () async {
      try {
        if (filters.isEmpty) {
          completer.complete(rowsById.keys.toList());
          return;
        }

        final List<double> filteredIds;

        if (rowsById.length > _isolateThreshold) {
          final rowValues = <double, Map<int, dynamic>>{};

          for (final entry in rowsById.entries) {
            final rowId = entry.key;
            final row = entry.value;
            final values = <int, dynamic>{};

            for (final filter in filters) {
              final column = columns.firstWhere((c) => c.id == filter.columnId);
              values[column.id] = _dataIndexer.getCellValue(row, column);
            }

            rowValues[rowId] = values;
          }

          final params = FilterParameters(
            rowValues: rowValues,
            filters: filters,
          );

          filteredIds = await compute(performFilterInIsolate, params);
        } else {
          filteredIds = _dataIndexer.filter(rowsById, filters, columns);
        }

        completer.complete(filteredIds);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
  }
}
