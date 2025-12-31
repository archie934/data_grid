import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/renderers/render_context.dart';

/// Abstract base class for custom row rendering.
///
/// Implement this to create custom row layouts, grouping, hierarchy, etc.
abstract class RowRenderer<T extends DataGridRow> {
  const RowRenderer();

  /// Builds a single row widget.
  ///
  /// [context] - Flutter BuildContext
  /// [row] - The data row to render
  /// [index] - Row index in the visible list
  /// [renderContext] - Additional rendering context (selection, controller, etc.)
  Widget buildRow(
    BuildContext context,
    T row,
    int index,
    RowRenderContext<T> renderContext,
  );

  /// Optional: Calculate row height dynamically.
  /// Return null to use default height.
  double? getRowHeight(T row, int index) => null;

  /// Optional: Determine if row should be built.
  /// Useful for conditional rendering (e.g., skip filtered rows).
  bool shouldBuildRow(T row, int index) => true;
}
