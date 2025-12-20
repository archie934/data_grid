class DataGridColumn {
  final int id;
  final String title;
  final double width;
  final bool pinned;
  final bool visible;
  final bool resizable;
  final bool sortable;
  final bool filterable;

  DataGridColumn({
    required this.id,
    required this.title,
    required this.width,
    this.pinned = false,
    this.visible = true,
    this.resizable = true,
    this.sortable = true,
    this.filterable = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataGridColumn &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          width == other.width &&
          pinned == other.pinned &&
          visible == other.visible &&
          resizable == other.resizable &&
          sortable == other.sortable &&
          filterable == other.filterable;

  @override
  int get hashCode => Object.hash(id, title, width, pinned, visible, resizable, sortable, filterable);

  DataGridColumn copyWith({
    int? id,
    String? title,
    double? width,
    bool? pinned,
    bool? visible,
    bool? resizable,
    bool? sortable,
    bool? filterable,
  }) {
    return DataGridColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      width: width ?? this.width,
      pinned: pinned ?? this.pinned,
      visible: visible ?? this.visible,
      resizable: resizable ?? this.resizable,
      sortable: sortable ?? this.sortable,
      filterable: filterable ?? this.filterable,
    );
  }
}
