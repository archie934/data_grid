import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';

typedef CellValueAccessor<T> = dynamic Function(T row, DataGridColumn column);

class DataIndexer<T extends DataGridRow> {
  final Map<double, int> _rowIndexMap = {};
  List<T> _data = [];
  final CellValueAccessor<T>? cellValueAccessor;

  DataIndexer({this.cellValueAccessor});

  void setData(List<T> data) {
    _data = data;
    _rebuildIndexMap();
  }

  void _rebuildIndexMap() {
    _rowIndexMap.clear();
    for (var i = 0; i < _data.length; i++) {
      _rowIndexMap[_data[i].id] = i;
    }
  }

  int? getRowIndex(double rowId) => _rowIndexMap[rowId];

  T? getRow(double rowId) {
    final index = _rowIndexMap[rowId];
    return index != null ? _data[index] : null;
  }

  List<int> sort(List<T> rows, List<SortColumn> sortColumns, List<DataGridColumn> columns) {
    if (sortColumns.isEmpty) {
      return List<int>.generate(rows.length, (i) => i);
    }

    final indices = List<int>.generate(rows.length, (i) => i);

    indices.sort((aIdx, bIdx) {
      for (final sortCol in sortColumns) {
        final column = columns.firstWhere((c) => c.id == sortCol.columnId);
        final aValue = _getCellValue(rows[aIdx], column);
        final bValue = _getCellValue(rows[bIdx], column);

        final comparison = _compareValues(aValue, bValue);

        if (comparison != 0) {
          return sortCol.direction == SortDirection.ascending ? comparison : -comparison;
        }
      }
      return 0;
    });

    return indices;
  }

  List<int> sortIndices(List<T> rows, List<int> indices, List<SortColumn> sortColumns, List<DataGridColumn> columns) {
    if (sortColumns.isEmpty) {
      return indices;
    }

    final sortedIndices = List<int>.from(indices);

    sortedIndices.sort((aIdx, bIdx) {
      for (final sortCol in sortColumns) {
        final column = columns.firstWhere((c) => c.id == sortCol.columnId);
        final aValue = _getCellValue(rows[aIdx], column);
        final bValue = _getCellValue(rows[bIdx], column);

        final comparison = _compareValues(aValue, bValue);

        if (comparison != 0) {
          return sortCol.direction == SortDirection.ascending ? comparison : -comparison;
        }
      }
      return 0;
    });

    return sortedIndices;
  }

  List<int> filter(List<T> rows, List<ColumnFilter> filters, List<DataGridColumn> columns) {
    if (filters.isEmpty) {
      return List<int>.generate(rows.length, (i) => i);
    }

    final indices = <int>[];

    for (var i = 0; i < rows.length; i++) {
      bool matchesAllFilters = true;

      for (final filter in filters) {
        final column = columns.firstWhere((c) => c.id == filter.columnId);
        final cellValue = _getCellValue(rows[i], column);

        if (!_matchesFilter(cellValue, filter)) {
          matchesAllFilters = false;
          break;
        }
      }

      if (matchesAllFilters) {
        indices.add(i);
      }
    }

    return indices;
  }

  /// Get cell value for a specific row and column
  /// Made public to support isolate sorting
  dynamic getCellValue(T row, DataGridColumn column) {
    if (cellValueAccessor != null) {
      return cellValueAccessor!(row, column);
    }
    return null;
  }

  // Keep for internal backward compatibility
  dynamic _getCellValue(T row, DataGridColumn column) => getCellValue(row, column);

  int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (a is num && b is num) {
      return a.compareTo(b);
    }

    if (a is String && b is String) {
      return a.compareTo(b);
    }

    if (a is DateTime && b is DateTime) {
      return a.compareTo(b);
    }

    if (a is Comparable && b is Comparable) {
      return a.compareTo(b);
    }

    return a.toString().compareTo(b.toString());
  }

  bool _matchesFilter(dynamic value, ColumnFilter filter) {
    switch (filter.operator) {
      case FilterOperator.equals:
        return value == filter.value;
      case FilterOperator.notEquals:
        return value != filter.value;
      case FilterOperator.contains:
        return value?.toString().toLowerCase().contains(filter.value.toString().toLowerCase()) ?? false;
      case FilterOperator.startsWith:
        return value?.toString().toLowerCase().startsWith(filter.value.toString().toLowerCase()) ?? false;
      case FilterOperator.endsWith:
        return value?.toString().toLowerCase().endsWith(filter.value.toString().toLowerCase()) ?? false;
      case FilterOperator.greaterThan:
        return _compareValues(value, filter.value) > 0;
      case FilterOperator.lessThan:
        return _compareValues(value, filter.value) < 0;
      case FilterOperator.greaterThanOrEqual:
        return _compareValues(value, filter.value) >= 0;
      case FilterOperator.lessThanOrEqual:
        return _compareValues(value, filter.value) <= 0;
      case FilterOperator.isEmpty:
        return value == null || value.toString().isEmpty;
      case FilterOperator.isNotEmpty:
        return value != null && value.toString().isNotEmpty;
    }
  }

  List<int> getRangeIndices(int start, int end) {
    return List<int>.generate((end - start).clamp(0, _data.length), (i) => start + i);
  }
}
