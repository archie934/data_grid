import 'package:flutter/material.dart';
import 'package:flutter_data_grid/data_grid.dart';
import '../models/product_row.dart';

class RedCellRenderer extends CellRenderer<ProductRow> {
  const RedCellRenderer();

  @override
  Widget buildCell(
    BuildContext context,
    ProductRow row,
    DataGridColumn column,
    int rowIndex,
    CellRenderContext<ProductRow> renderContext,
  ) {
    final theme = DataGridTheme.of(context);
    return Container(
      color: Colors.red,
      padding: theme.padding.cellPadding,
      alignment: Alignment.centerLeft,
      child: Text(
        '\$${row.price.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class ActionsCellRenderer extends CellRenderer<ProductRow> {
  final void Function(double rowId) onDelete;

  const ActionsCellRenderer({required this.onDelete});

  @override
  Widget buildCell(
    BuildContext context,
    ProductRow row,
    DataGridColumn column,
    int rowIndex,
    CellRenderContext<ProductRow> renderContext,
  ) {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
        tooltip: 'Delete row',
        onPressed: () => onDelete(row.id),
      ),
    );
  }
}
