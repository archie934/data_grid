import 'package:flutter/widgets.dart';
import 'package:data_grid/renderers/filter_renderer.dart';
import 'package:data_grid/renderers/cell_renderer.dart';
import 'package:data_grid/models/data/row.dart';

typedef CellEditorBuilder = Widget Function(BuildContext context, dynamic value, ValueChanged<dynamic> onChanged);

typedef CellFormatter<T extends DataGridRow> = String Function(T row, DataGridColumn column);

const int kSelectionColumnId = -1;
const double kSelectionColumnWidth = 50.0;

class DataGridColumn<T extends DataGridRow> {
  final int id;
  final String title;
  final double width;
  final bool pinned;
  final bool visible;
  final bool resizable;
  final bool sortable;
  final bool filterable;
  final bool editable;
  final FilterRenderer? filterRenderer;
  final CellEditorBuilder? cellEditorBuilder;
  final CellRenderer? cellRenderer;
  final Function? cellFormatter;
  final dynamic Function(T)? valueAccessor;

  DataGridColumn({
    required this.id,
    required this.title,
    required this.width,
    this.pinned = false,
    this.visible = true,
    this.resizable = true,
    this.sortable = true,
    this.filterable = true,
    this.editable = true,
    this.filterRenderer,
    this.cellEditorBuilder,
    this.cellRenderer,
    this.cellFormatter,
    this.valueAccessor,
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
          filterable == other.filterable &&
          editable == other.editable &&
          filterRenderer == other.filterRenderer &&
          cellEditorBuilder == other.cellEditorBuilder &&
          cellRenderer == other.cellRenderer &&
          cellFormatter == other.cellFormatter;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    width,
    pinned,
    visible,
    resizable,
    sortable,
    filterable,
    editable,
    filterRenderer,
    cellEditorBuilder,
    cellRenderer,
    cellFormatter,
  );

  DataGridColumn<T> copyWith({
    int? id,
    String? title,
    double? width,
    bool? pinned,
    bool? visible,
    bool? resizable,
    bool? sortable,
    bool? filterable,
    bool? editable,
    FilterRenderer? filterRenderer,
    CellEditorBuilder? cellEditorBuilder,
    CellRenderer? cellRenderer,
    Function? cellFormatter,
    dynamic Function(T)? valueAccessor,
  }) {
    return DataGridColumn<T>(
      id: id ?? this.id,
      title: title ?? this.title,
      width: width ?? this.width,
      pinned: pinned ?? this.pinned,
      visible: visible ?? this.visible,
      resizable: resizable ?? this.resizable,
      sortable: sortable ?? this.sortable,
      filterable: filterable ?? this.filterable,
      editable: editable ?? this.editable,
      filterRenderer: filterRenderer ?? this.filterRenderer,
      cellEditorBuilder: cellEditorBuilder ?? this.cellEditorBuilder,
      cellRenderer: cellRenderer ?? this.cellRenderer,
      cellFormatter: cellFormatter ?? this.cellFormatter,
      valueAccessor: valueAccessor ?? this.valueAccessor,
    );
  }

  factory DataGridColumn.selection({required bool pinned}) {
    return DataGridColumn<T>(
      id: kSelectionColumnId,
      title: '',
      width: kSelectionColumnWidth,
      pinned: pinned,
      visible: true,
      resizable: false,
      sortable: false,
      filterable: false,
      editable: false,
    );
  }
}
