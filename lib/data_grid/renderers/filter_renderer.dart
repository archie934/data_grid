import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';

/// Abstract base class for custom filter rendering.
///
/// Implement this to create custom filter widgets for different data types
/// (text, numbers, dates, enums, etc.)
abstract class FilterRenderer {
  const FilterRenderer();

  /// Builds a filter widget for a column.
  ///
  /// [context] - Flutter BuildContext
  /// [column] - The column definition
  /// [currentFilter] - Current active filter for this column (if any)
  /// [onChange] - Callback when filter value changes
  /// [onClear] - Callback to clear the filter
  Widget buildFilter(
    BuildContext context,
    DataGridColumn column,
    ColumnFilter? currentFilter,
    void Function(FilterOperator operator, dynamic value) onChange,
    void Function() onClear,
  );
}
