import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/renderers/filter_renderer.dart';
import 'package:flutter_data_grid/renderers/cell_renderer.dart';
import 'package:flutter_data_grid/models/data/row.dart';

/// Builder function for custom cell editor widgets.
typedef CellEditorBuilder =
    Widget Function(
      BuildContext context,
      dynamic value,
      ValueChanged<dynamic> onChanged,
    );

/// Formatter function to convert cell values to display strings.
typedef CellFormatter<T extends DataGridRow> =
    String Function(T row, DataGridColumn column);

/// Column ID used for the selection checkbox column.
const int kSelectionColumnId = -1;

/// Default width for the selection checkbox column.
const double kSelectionColumnWidth = 50.0;

/// Configuration for a column in the [DataGrid].
///
/// Each column defines its appearance, behavior, and how data is accessed
/// and modified for cells in that column.
class DataGridColumn<T extends DataGridRow> {
  /// Unique identifier for this column.
  final int id;

  /// Display title shown in the header.
  final String title;

  /// Current width of the column in pixels.
  final double width;

  /// Whether this column is pinned to the left.
  final bool pinned;

  /// Whether this column is visible.
  final bool visible;

  /// Whether users can resize this column.
  final bool resizable;

  /// Whether this column can be sorted.
  final bool sortable;

  /// Whether this column can be filtered.
  final bool filterable;

  /// Whether cells in this column can be edited.
  final bool editable;

  /// Custom filter widget renderer for this column.
  final FilterRenderer? filterRenderer;

  /// Custom editor builder for cell editing.
  final CellEditorBuilder? cellEditorBuilder;

  /// Custom cell renderer for this column.
  final CellRenderer? cellRenderer;

  /// Formatter function to format cell display values.
  final Function? cellFormatter;

  /// Function to extract the cell value from a row.
  final dynamic Function(T)? valueAccessor;

  /// Function to set the cell value on a row.
  final void Function(T row, dynamic value)? cellValueSetter;

  /// Validator function for cell edits. Return true to accept the edit.
  final bool Function(dynamic oldValue, dynamic newValue)? validator;

  /// Creates a [DataGridColumn] with the specified configuration.
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
    this.cellValueSetter,
    this.validator,
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
          cellRenderer == other.cellRenderer;

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
    cellRenderer,
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
    void Function(T row, dynamic value)? cellValueSetter,
    bool Function(dynamic oldValue, dynamic newValue)? validator,
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
      cellValueSetter: cellValueSetter ?? this.cellValueSetter,
      validator: validator ?? this.validator,
    );
  }

  /// Creates a selection checkbox column.
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
