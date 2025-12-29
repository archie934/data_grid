import 'package:data_grid/models/state/grid_state.dart';

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
