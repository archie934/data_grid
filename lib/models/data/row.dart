// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class DataGridRow {
  late double id;
}

class SomeRow implements DataGridRow {
  @override
  double id;
  String name;
  int quantity;
  double price;
  double total;
  Map<int, dynamic> extraData;

  SomeRow({required this.id, this.name = '', this.quantity = 0, this.price = 0.0, Map<int, dynamic>? extraData})
    : total = quantity * price,
      extraData = extraData ?? {};

  void updateTotal() {
    total = quantity * price;
  }
}
