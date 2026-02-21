import 'package:flutter/material.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';

/// Aspects of grid state that widgets can selectively depend on.
enum DataGridAspect {
  columns,
  data,
  selection,
  edit,
  sort,
  filter,
  pagination,
  loading,
}

/// Provides the controller and scroll controller. These rarely change,
/// so widgets depending only on this won't rebuild on state updates.
class DataGridControllerScope<T extends DataGridRow> extends InheritedWidget {
  final DataGridController<T> controller;
  final GridScrollController scrollController;

  const DataGridControllerScope({
    super.key,
    required this.controller,
    required this.scrollController,
    required super.child,
  });

  static DataGridControllerScope<T>? maybeOf<T extends DataGridRow>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<DataGridControllerScope<T>>();
  }

  @override
  bool updateShouldNotify(DataGridControllerScope<T> oldWidget) {
    return oldWidget.controller != controller ||
        oldWidget.scrollController != scrollController;
  }
}

/// Provides grid state via [InheritedModel] so dependents can subscribe
/// to specific [DataGridAspect]s and skip rebuilds for unrelated changes.
class DataGridStateScope<T extends DataGridRow>
    extends InheritedModel<DataGridAspect> {
  final DataGridState<T> state;

  /// Pre-computed effective columns (cached once per state change).
  final List<DataGridColumn<T>> effectiveColumns;

  DataGridStateScope({
    super.key,
    required this.state,
    required super.child,
  }) : effectiveColumns = state.effectiveColumns;

  @override
  bool updateShouldNotify(DataGridStateScope<T> oldWidget) {
    return oldWidget.state != state;
  }

  @override
  bool updateShouldNotifyDependent(
    DataGridStateScope<T> oldWidget,
    Set<DataGridAspect> dependencies,
  ) {
    for (final aspect in dependencies) {
      switch (aspect) {
        case DataGridAspect.columns:
          if (state.columns != oldWidget.state.columns ||
              state.selection.mode != oldWidget.state.selection.mode) {
            return true;
          }
        case DataGridAspect.data:
          if (state.displayOrder != oldWidget.state.displayOrder ||
              state.rowsById != oldWidget.state.rowsById) {
            return true;
          }
        case DataGridAspect.selection:
          if (state.selection != oldWidget.state.selection) return true;
        case DataGridAspect.edit:
          if (state.edit != oldWidget.state.edit) return true;
        case DataGridAspect.sort:
          if (state.sort != oldWidget.state.sort) return true;
        case DataGridAspect.filter:
          if (state.filter != oldWidget.state.filter) return true;
        case DataGridAspect.pagination:
          if (state.pagination != oldWidget.state.pagination) return true;
        case DataGridAspect.loading:
          if (state.isLoading != oldWidget.state.isLoading ||
              state.loadingMessage != oldWidget.state.loadingMessage) {
            return true;
          }
      }
    }
    return false;
  }
}

/// Convenience wrapper that nests both scopes.
class DataGridInherited<T extends DataGridRow> extends StatelessWidget {
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final DataGridState<T> state;
  final Widget child;

  const DataGridInherited({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DataGridControllerScope<T>(
      controller: controller,
      scrollController: scrollController,
      child: DataGridStateScope<T>(
        state: state,
        child: child,
      ),
    );
  }
}

extension DataGridContext on BuildContext {
  /// Depends on [DataGridControllerScope] only (no rebuild on state change).
  DataGridController<T>? dataGridController<T extends DataGridRow>() {
    return DataGridControllerScope.maybeOf<T>(this)?.controller;
  }

  /// Depends on [DataGridControllerScope] only (no rebuild on state change).
  GridScrollController? gridScrollController<T extends DataGridRow>() {
    return DataGridControllerScope.maybeOf<T>(this)?.scrollController;
  }

  /// Depends on the given [aspects] of grid state. If [aspects] is null,
  /// depends on all state changes (backward-compatible fallback).
  DataGridState<T>? dataGridState<T extends DataGridRow>([
    Set<DataGridAspect>? aspects,
  ]) {
    if (aspects == null || aspects.isEmpty) {
      return InheritedModel.inheritFrom<DataGridStateScope<T>>(this)
          ?.state;
    }
    DataGridStateScope<T>? scope;
    for (final aspect in aspects) {
      scope = InheritedModel.inheritFrom<DataGridStateScope<T>>(
          this, aspect: aspect);
    }
    return scope?.state;
  }

  /// Depends on the [DataGridAspect.columns] aspect only.
  List<DataGridColumn<T>>? dataGridEffectiveColumns<T extends DataGridRow>() {
    return InheritedModel.inheritFrom<DataGridStateScope<T>>(
            this, aspect: DataGridAspect.columns)
        ?.effectiveColumns;
  }
}
