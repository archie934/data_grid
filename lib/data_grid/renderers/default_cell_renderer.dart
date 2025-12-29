import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/renderers/cell_renderer.dart';
import 'package:data_grid/data_grid/renderers/render_context.dart';
import 'package:data_grid/data_grid/theme/data_grid_theme.dart';

/// Default cell renderer implementation.
class DefaultCellRenderer<T extends DataGridRow> extends CellRenderer<T> {
  const DefaultCellRenderer();

  @override
  Widget buildCell(
    BuildContext context,
    T row,
    DataGridColumn<T> column,
    int rowIndex,
    CellRenderContext<T> renderContext,
  ) {
    final theme = DataGridTheme.of(context);
    final value = column.valueAccessor?.call(row);
    final displayText = value?.toString() ?? '';

    return Container(
      padding: theme.padding.cellPadding,
      alignment: Alignment.centerLeft,
      child: Text(displayText, overflow: TextOverflow.ellipsis),
    );
  }
}
