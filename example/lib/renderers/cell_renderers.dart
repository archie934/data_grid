import 'package:flutter/material.dart';
import 'package:flutter_data_grid/data_grid.dart';
import '../models/product_row.dart';

/// Reads row data from [CellScope] — no builder function, no allocations.
/// Declare as `const` on the column for maximum element reuse.
class RedPriceCell extends StatelessWidget {
  const RedPriceCell({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<ProductRow>(context);
    final theme = DataGridTheme.of(context);

    return Container(
      color: Colors.red,
      padding: theme.padding.cellPadding,
      alignment: Alignment.centerLeft,
      child: Text(
        '\$${scope.row.price.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class ActionsCellWidget extends StatelessWidget {
  final void Function(double rowId) onDelete;

  const ActionsCellWidget({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<ProductRow>(context);

    return Center(
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
        tooltip: 'Delete row',
        onPressed: () => onDelete(scope.row.id),
      ),
    );
  }
}
