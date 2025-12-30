import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/renderers/render_context.dart';

/// Abstract base class for custom cell rendering.
///
/// Implement this to create custom cell widgets, editors, formatters, etc.
abstract class CellRenderer<T extends DataGridRow> {
  const CellRenderer();

  /// Builds a single cell widget.
  ///
  /// [context] - Flutter BuildContext
  /// [row] - The data row containing this cell
  /// [column] - The column definition
  /// [rowIndex] - Row index
  /// [renderContext] - Additional rendering context
  Widget buildCell(
    BuildContext context,
    T row,
    DataGridColumn<T> column,
    int rowIndex,
    CellRenderContext<T> renderContext,
  );

  /// Optional: Determine if cell is editable
  bool isCellEditable(T row, DataGridColumn<T> column) => false;

  /// Optional: Build custom editor widget
  Widget? buildEditor(
    BuildContext context,
    T row,
    DataGridColumn<T> column,
    dynamic currentValue,
    void Function(dynamic newValue) onValueChanged,
  ) => null;
}
