import 'package:data_grid/models/enums/sort_direction.dart';

/// Data structure for passing sort parameters to isolate
class SortParameters {
  final List<dynamic> columnValues; // [rowIndex] = value
  final SortDirection direction;
  final int rowCount;

  SortParameters({required this.columnValues, required this.direction, required this.rowCount});
}

/// Top-level function that performs sorting in an isolate
/// Must be top-level or static to work with compute()
List<int> performSortInIsolate(SortParameters params) {
  final indices = List<int>.generate(params.rowCount, (i) => i);

  indices.sort((aIdx, bIdx) {
    final aValue = params.columnValues[aIdx];
    final bValue = params.columnValues[bIdx];

    final comparison = _compareValues(aValue, bValue);

    if (comparison != 0) {
      return params.direction == SortDirection.ascending ? comparison : -comparison;
    }
    return 0;
  });

  return indices;
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
