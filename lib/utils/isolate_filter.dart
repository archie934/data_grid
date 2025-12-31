import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';

class FilterParameters {
  final Map<double, Map<int, dynamic>> rowValues;
  final List<ColumnFilter> filters;

  FilterParameters({required this.rowValues, required this.filters});
}

List<double> performFilterInIsolate(FilterParameters params) {
  if (params.filters.isEmpty) {
    return params.rowValues.keys.toList();
  }

  final matchingIds = <double>[];

  for (final entry in params.rowValues.entries) {
    bool matchesAllFilters = true;

    for (final filter in params.filters) {
      final cellValue = entry.value[filter.columnId];

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
