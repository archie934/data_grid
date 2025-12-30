import 'dart:async';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';

abstract class FilterDelegate<T extends DataGridRow> {
  const FilterDelegate();

  Future<List<double>> applyFilters({
    required Map<double, T> rowsById,
    required List<ColumnFilter> filters,
    required List<DataGridColumn<T>> columns,
  });

  void dispose();
}

class FilterResult {
  final FilterState filterState;
  final List<double> filteredIds;

  FilterResult({required this.filterState, required this.filteredIds});
}
