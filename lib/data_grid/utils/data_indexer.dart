import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';

typedef CellValueAccessor<T> = dynamic Function(T row, DataGridColumn column);

class DataIndexer<T extends DataGridRow> {
  Map<double, T> _data = {};
  final CellValueAccessor<T>? cellValueAccessor;

  DataIndexer({this.cellValueAccessor});

  void setData(Map<double, T> data) {
    _data = data;
  }

  T? getRow(double rowId) => _data[rowId];

  List<double> sort(Map<double, T> rowsById, List<SortColumn> sortColumns, List<DataGridColumn> columns) {
    if (sortColumns.isEmpty) {
      return rowsById.keys.toList();
    }

    final ids = rowsById.keys.toList();

    ids.sort((aId, bId) {
      for (final sortCol in sortColumns) {
        final column = columns.firstWhere((c) => c.id == sortCol.columnId);
        final aValue = _getCellValue(rowsById[aId]!, column);
        final bValue = _getCellValue(rowsById[bId]!, column);

        final comparison = _compareValues(aValue, bValue);

        if (comparison != 0) {
          return sortCol.direction == SortDirection.ascending ? comparison : -comparison;
        }
      }
      return 0;
    });

    return ids;
  }

  List<double> sortIds(
    Map<double, T> rowsById,
    List<double> idsToSort,
    List<SortColumn> sortColumns,
    List<DataGridColumn> columns,
  ) {
    if (sortColumns.isEmpty) {
      return idsToSort;
    }

    final sortedIds = List<double>.from(idsToSort);

    sortedIds.sort((aId, bId) {
      for (final sortCol in sortColumns) {
        final column = columns.firstWhere((c) => c.id == sortCol.columnId);
        final aValue = _getCellValue(rowsById[aId]!, column);
        final bValue = _getCellValue(rowsById[bId]!, column);

        final comparison = _compareValues(aValue, bValue);

        if (comparison != 0) {
          return sortCol.direction == SortDirection.ascending ? comparison : -comparison;
        }
      }
      return 0;
    });

    return sortedIds;
  }

  List<double> filter(Map<double, T> rowsById, List<ColumnFilter> filters, List<DataGridColumn> columns) {
    if (filters.isEmpty) {
      return rowsById.keys.toList();
    }

    final matchingIds = <double>[];

    for (final entry in rowsById.entries) {
      bool matchesAllFilters = true;

      for (final filter in filters) {
        final column = columns.firstWhere((c) => c.id == filter.columnId);
        final cellValue = _getCellValue(entry.value, column);

        if (!_matchesFilter(cellValue, filter)) {
          matchesAllFilters = false;
          break;
        }
      }

      if (matchesAllFilters) {
        matchingIds.add(entry.key);
      }
    }

    return matchingIds;
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

  List<double> getRangeIds(List<double> displayOrder, int start, int end) {
    final clampedStart = start.clamp(0, displayOrder.length);
    final clampedEnd = end.clamp(0, displayOrder.length);
    return displayOrder.sublist(clampedStart, clampedEnd);
  }
}
