import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/renderers/cell_renderer.dart';
import 'package:data_grid/data_grid/renderers/render_context.dart';
import 'package:data_grid/data_grid/theme/data_grid_theme.dart';

/// Default cell renderer implementation.
///
/// Renders cells with basic styling and uses the cellBuilder if provided.
class DefaultCellRenderer<T extends DataGridRow> extends CellRenderer<T> {
  const DefaultCellRenderer();

  @override
  Widget buildCell(
    BuildContext context,
    T row,
    DataGridColumn column,
    int rowIndex,
    CellRenderContext<T> renderContext,
  ) {
    final theme = DataGridTheme.of(context);

    return Container(
      padding: theme.padding.cellPadding,
      alignment: Alignment.centerLeft,
      child: renderContext.cellBuilder != null
          ? renderContext.cellBuilder!(row, column.id)
          : Text('Row ${row.id}, Col ${column.id}', overflow: TextOverflow.ellipsis),
    );
  }
}
