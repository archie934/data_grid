// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class DataGridRow {
  late double id;
}

class SomeRow implements DataGridRow {
  @override
  double id;

  SomeRow({
    required this.id,
  });
}
