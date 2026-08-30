import 'package:flutter_data_grid/data_grid.dart';

class ProductRow implements DataGridRow {
  @override
  double id;
  String name;
  int quantity;
  double price;
  double total;
  Map<int, dynamic> extraData;

  /// Whether this row shows a thumbnail in the Photo column. Rows with a
  /// photo are naturally taller — good for exercising `autoRowHeight`.
  bool hasPhoto;

  /// Free-text notes, empty for most rows but occasionally several
  /// sentences long — wraps to multiple lines, driving row height
  /// variation independent of [hasPhoto].
  String notes;

  ProductRow({
    required this.id,
    this.name = '',
    this.quantity = 0,
    this.price = 0.0,
    Map<int, dynamic>? extraData,
    this.hasPhoto = false,
    this.notes = '',
  }) : total = quantity * price,
       extraData = extraData ?? {};

  void updateTotal() {
    total = quantity * price;
  }

  static const List<String> _sampleNotes = [
    'Customer requested gift wrapping for this order.',
    'Backordered — expected to ship within 2 weeks once the '
        'warehouse restocks this item. Customer has been notified '
        'and is okay with the delay.',
    'Fragile — pack with extra padding.',
    'Return requested: item arrived damaged in transit. Replacement '
        'has already been shipped via expedited courier, and a prepaid '
        'return label was emailed to the customer for the damaged unit.',
    'VIP customer — priority handling.',
  ];

  static List<ProductRow> generateSampleData(int count) {
    return List.generate(count, (index) {
      final hasNotes = index % 6 == 0;
      return ProductRow(
        id: index.toDouble(),
        name: index % 10 == 0 ? 'Special Item $index' : '',
        quantity: (index % 20) + 1,
        price: (index % 10 + 1) * 9.99,
        hasPhoto: index % 4 == 0,
        notes: hasNotes ? _sampleNotes[index % _sampleNotes.length] : '',
      );
    });
  }
}
