import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';

class DataIndexer<T extends DataGridRow> {
  Map<double, T> _data = {};

  DataIndexer();

  void setData(Map<double, T> data) {
    _data = data;
  }

  T? getRow(double rowId) => _data[rowId];

  List<double> sort(
    Map<double, T> rowsById,
    SortColumn? sortColumn,
    List<DataGridColumn<T>> columns,
  ) {
    if (sortColumn == null) {
      return rowsById.keys.toList();
    }

    final ids = rowsById.keys.toList();
    final column = columns.firstWhere((c) => c.id == sortColumn.columnId);

    ids.sort((aId, bId) {
      final aValue = _getCellValue(rowsById[aId]!, column);
      final bValue = _getCellValue(rowsById[bId]!, column);

      final comparison = _compareValues(aValue, bValue);

      if (comparison != 0) {
        return sortColumn.direction == SortDirection.ascending
            ? comparison
            : -comparison;
      }
      return 0;
    });

    return ids;
  }

  List<double> sortIds(
    Map<double, T> rowsById,
    List<double> idsToSort,
    SortColumn sortColumn,
    List<DataGridColumn<T>> columns,
  ) {
    final sortedIds = List<double>.from(idsToSort);
    final column = columns.firstWhere((c) => c.id == sortColumn.columnId);

    sortedIds.sort((aId, bId) {
      final aValue = _getCellValue(rowsById[aId]!, column);
      final bValue = _getCellValue(rowsById[bId]!, column);

      final comparison = _compareValues(aValue, bValue);

      if (comparison != 0) {
        return sortColumn.direction == SortDirection.ascending
            ? comparison
            : -comparison;
      }
      return 0;
    });

    return sortedIds;
  }

  List<double> filter(
    Map<double, T> rowsById,
    List<ColumnFilter> filters,
    List<DataGridColumn<T>> columns,
  ) {
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
  dynamic getCellValue(T row, DataGridColumn<T> column) {
    if (column.valueAccessor != null) {
      return column.valueAccessor!(row);
    }
    return null;
  }

  dynamic _getCellValue(T row, DataGridColumn<T> column) =>
      getCellValue(row, column);

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

  String _sanitizeString(dynamic value) {
    return value?.toString().toLowerCase().trim().replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) ??
        '';
  }

  bool _matchesFilter(dynamic value, ColumnFilter filter) {
    switch (filter.operator) {
      case FilterOperator.equals:
        return value == filter.value;
      case FilterOperator.notEquals:
        return value != filter.value;
      case FilterOperator.contains:
        final sanitizedValue = _sanitizeString(value);
        final sanitizedFilter = _sanitizeString(filter.value);
        return sanitizedFilter.isEmpty ||
            sanitizedValue.contains(sanitizedFilter);
      case FilterOperator.startsWith:
        final sanitizedValue = _sanitizeString(value);
        final sanitizedFilter = _sanitizeString(filter.value);
        return sanitizedFilter.isEmpty ||
            sanitizedValue.startsWith(sanitizedFilter);
      case FilterOperator.endsWith:
        final sanitizedValue = _sanitizeString(value);
        final sanitizedFilter = _sanitizeString(filter.value);
        return sanitizedFilter.isEmpty ||
            sanitizedValue.endsWith(sanitizedFilter);
      case FilterOperator.greaterThan:
        return _compareValues(value, filter.value) > 0;
      case FilterOperator.lessThan:
        return _compareValues(value, filter.value) < 0;
      case FilterOperator.greaterThanOrEqual:
        return _compareValues(value, filter.value) >= 0;
      case FilterOperator.lessThanOrEqual:
        return _compareValues(value, filter.value) <= 0;
      case FilterOperator.isEmpty:
        return value == null || value.toString().trim().isEmpty;
      case FilterOperator.isNotEmpty:
        return value != null && value.toString().trim().isNotEmpty;
    }
  }

  List<double> getRangeIds(List<double> displayOrder, int start, int end) {
    final clampedStart = start.clamp(0, displayOrder.length);
    final clampedEnd = end.clamp(0, displayOrder.length);
    return displayOrder.sublist(clampedStart, clampedEnd);
  }
}
