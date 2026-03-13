import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';

/// Scoped inherited widget that provides per-column filter data to descendant widgets.
///
/// Columns declare a [DataGridColumn.filterWidget] (ideally const) and read
/// the column, current filter state, and callbacks from the nearest [FilterScope].
///
/// This lets Flutter preserve element identity across rebuilds — the const
/// child widget never changes, so the framework skips subtree diffing entirely.
/// Only widgets that call [FilterScope.of] are rebuilt when the underlying
/// filter state actually changes.
///
/// ```dart
/// // On the column:
/// DataGridColumn<MyRow>(
///   id: 1,
///   title: 'Name',
///   width: 150,
///   filterWidget: const MyNameFilter(),
/// )
///
/// // The filter widget:
/// class MyNameFilter extends StatelessWidget {
///   const MyNameFilter({super.key});
///   @override
///   Widget build(BuildContext context) {
///     final scope = FilterScope.of(context);
///     return TextField(
///       onChanged: (v) => scope.onChange(FilterOperator.contains, v),
///     );
///   }
/// }
/// ```
class FilterScope extends InheritedWidget {
  /// The column this filter belongs to.
  final DataGridColumn column;

  /// The current active filter for this column, or null if no filter is applied.
  final ColumnFilter? currentFilter;

  /// Called when the user changes the filter value.
  final void Function(FilterOperator operator, dynamic value) onChange;

  /// Called when the user clears the filter.
  final void Function() onClear;

  /// When set, filter widgets inside this scope should use this border instead
  /// of the theme default (e.g. to suppress the right border on pinned columns).
  final Border? borderOverride;

  const FilterScope({
    super.key,
    required this.column,
    required this.currentFilter,
    required this.onChange,
    required this.onClear,
    required super.child,
    this.borderOverride,
  });

  /// Returns the nearest [FilterScope] ancestor.
  ///
  /// Throws if no [FilterScope] is found — use [maybeOf] for optional access.
  static FilterScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FilterScope>();
    assert(scope != null, 'No FilterScope found in context');
    return scope!;
  }

  /// Returns the nearest [FilterScope] ancestor, or null if none exists.
  static FilterScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FilterScope>();
  }

  @override
  bool updateShouldNotify(FilterScope old) {
    return currentFilter != old.currentFilter ||
        column != old.column ||
        borderOverride != old.borderOverride;
  }
}
