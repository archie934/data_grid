import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/enums/sort_direction.dart';

/// Data structure for passing sort parameters to isolate
class SortParameters {
  final List<List<dynamic>> columnValues; // [columnIndex][rowIndex] = value
  final List<SortColumn> sortColumns;
  final int rowCount;

  SortParameters({required this.columnValues, required this.sortColumns, required this.rowCount});
}

/// Top-level function that performs sorting in an isolate
/// Must be top-level or static to work with compute()
List<int> performSortInIsolate(SortParameters params) {
  if (params.sortColumns.isEmpty) {
    return List<int>.generate(params.rowCount, (i) => i);
  }

  final indices = List<int>.generate(params.rowCount, (i) => i);

  indices.sort((aIdx, bIdx) {
    for (var i = 0; i < params.sortColumns.length; i++) {
      final sortCol = params.sortColumns[i];

      // Get values for this sort column
      final aValue = params.columnValues[i][aIdx];
      final bValue = params.columnValues[i][bIdx];

      final comparison = _compareValues(aValue, bValue);

      if (comparison != 0) {
        return sortCol.direction == SortDirection.ascending ? comparison : -comparison;
      }
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
