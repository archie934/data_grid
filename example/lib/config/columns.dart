import 'package:flutter_data_grid/data_grid.dart';
import '../models/product_row.dart';
import '../renderers/cell_renderers.dart';

List<DataGridColumn<ProductRow>> createColumns(ActionsCellRenderer actionsRenderer) {
  return [
    DataGridColumn<ProductRow>(
      id: -1,
      title: '',
      width: 50,
      pinned: true,
      editable: false,
      sortable: false,
      filterable: false,
      resizable: false,
      cellRenderer: actionsRenderer,
    ),
    DataGridColumn<ProductRow>(
      id: 0,
      title: 'ID',
      width: 80,
      editable: false,
      valueAccessor: (row) => row.id.toInt().toString(),
    ),
    DataGridColumn<ProductRow>(
      id: 1,
      title: 'Name',
      width: 200,
      editable: true,
      valueAccessor: (row) => row.name.isEmpty ? 'Item ${row.id.toInt()}' : row.name,
      cellValueSetter: (row, value) => row.name = value.toString(),
    ),
    DataGridColumn<ProductRow>(
      id: 2,
      title: 'Quantity',
      width: 100,
      editable: true,
      valueAccessor: (row) => row.quantity.toString(),
      cellValueSetter: (row, value) {
        row.quantity = int.tryParse(value.toString()) ?? 0;
        row.updateTotal();
      },
      validator: (oldValue, newValue) {
        final parsed = int.tryParse(newValue.toString());
        return parsed != null && parsed >= 0;
      },
    ),
    DataGridColumn<ProductRow>(
      id: 3,
      title: 'Price',
      width: 100,
      editable: true,
      cellRenderer: const RedCellRenderer(),
      valueAccessor: (row) => '\$${row.price.toStringAsFixed(2)}',
      cellValueSetter: (row, value) {
        final cleanValue = value.toString().replaceAll('\$', '').trim();
        row.price = double.tryParse(cleanValue) ?? 0.0;
        row.updateTotal();
      },
      validator: (oldValue, newValue) {
        final cleanValue = newValue.toString().replaceAll('\$', '').trim();
        final parsed = double.tryParse(cleanValue);
        return parsed != null && parsed >= 0;
      },
    ),
    DataGridColumn<ProductRow>(
      id: 4,
      title: 'Total',
      width: 100,
      editable: false,
      valueAccessor: (row) => '\$${row.total.toStringAsFixed(2)}',
    ),
    ...List.generate(50, (index) {
      final columnId = index + 5;
      return DataGridColumn<ProductRow>(
        id: columnId,
        title: 'Extra ${index + 1}',
        width: 120,
        pinned: index < 2,
        editable: true,
        valueAccessor: (row) => row.extraData[columnId]?.toString() ?? 'Data ${row.id.toInt()}',
        cellValueSetter: (row, value) => row.extraData[columnId] = value,
      );
    }),
  ];
}
