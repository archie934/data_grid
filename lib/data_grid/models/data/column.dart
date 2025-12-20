class DataGridColumn {
  final int id;
  final String title;
  final double width;

  DataGridColumn({required this.id, required this.title, required this.width});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataGridColumn &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          width == other.width;

  @override
  int get hashCode => Object.hash(id, title, width);

  DataGridColumn copyWith({int? id, String? title, double? width}) {
    return DataGridColumn(id: id ?? this.id, title: title ?? this.title, width: width ?? this.width);
  }
}
