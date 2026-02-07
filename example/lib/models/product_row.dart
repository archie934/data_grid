import 'package:flutter_data_grid/data_grid.dart';

class ProductRow implements DataGridRow {
  @override
  double id;
  String name;
  int quantity;
  double price;
  double total;
  Map<int, dynamic> extraData;

  ProductRow({
    required this.id,
    this.name = '',
    this.quantity = 0,
    this.price = 0.0,
    Map<int, dynamic>? extraData,
  }) : total = quantity * price,
       extraData = extraData ?? {};

  void updateTotal() {
    total = quantity * price;
  }

  static List<ProductRow> generateSampleData(int count) {
    return List.generate(
      count,
      (index) => ProductRow(
        id: index.toDouble(),
        name: index % 10 == 0 ? 'Special Item $index' : '',
        quantity: (index % 20) + 1,
        price: (index % 10 + 1) * 9.99,
      ),
    );
  }
}
