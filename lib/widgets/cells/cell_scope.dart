import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';

/// Scoped inherited widget that provides per-cell data to descendant widgets.
///
/// Columns declare a [DataGridColumn.cellWidget] (ideally const) and read
/// row/column/selection data from the nearest [CellScope] ancestor.
///
/// This lets Flutter preserve element identity across rebuilds — the const
/// child widget never changes, so the framework skips subtree diffing entirely.
/// Only widgets that call [CellScope.of] are rebuilt when the underlying data
/// actually changes.
///
/// ```dart
/// // On the column:
/// DataGridColumn<MyRow>(
///   id: 1,
///   title: 'Price',
///   width: 100,
///   cellWidget: const PriceCell(),
/// )
///
/// // The cell widget:
/// class PriceCell extends StatelessWidget {
///   const PriceCell({super.key});
///   @override
///   Widget build(BuildContext context) {
///     final scope = CellScope.of<MyRow>(context);
///     return Text('\$${scope.row.price}');
///   }
/// }
/// ```
class CellScope<T extends DataGridRow> extends InheritedWidget {
  /// The typed row object for this cell.
  final T row;

  /// The column configuration for this cell.
  final DataGridColumn<T> column;

  /// Zero-based visible row index.
  final int rowIndex;

  /// Whether the row containing this cell is selected.
  final bool isSelected;

  /// Whether the column containing this cell is pinned.
  final bool isPinned;

  /// Pre-computed value from [DataGridColumn.valueAccessor], if any.
  final dynamic value;

  /// The grid controller for dispatching events.
  final DataGridController<T> controller;

  /// Creates a [CellScope] providing cell data to descendants.
  const CellScope({
    super.key,
    required this.row,
    required this.column,
    required this.rowIndex,
    required this.isSelected,
    required this.isPinned,
    required this.value,
    required this.controller,
    required super.child,
  });

  /// Returns the nearest [CellScope] ancestor, throwing if none exists.
  static CellScope<T> of<T extends DataGridRow>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CellScope<T>>();
    assert(scope != null, 'No CellScope<$T> found in context');
    return scope!;
  }

  /// Returns the nearest [CellScope] ancestor, or null if none exists.
  static CellScope<T>? maybeOf<T extends DataGridRow>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CellScope<T>>();
  }

  @override
  bool updateShouldNotify(CellScope<T> oldWidget) {
    return !identical(row, oldWidget.row) ||
        value != oldWidget.value ||
        rowIndex != oldWidget.rowIndex ||
        isSelected != oldWidget.isSelected ||
        isPinned != oldWidget.isPinned;
  }
}
