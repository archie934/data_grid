import 'package:flutter/material.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
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
  group,
  pagination,
  loading,
}

/// Provides the controller and scroll controller. These rarely change,
/// so widgets depending only on this won't rebuild on state updates.
class DataGridControllerScope<T extends DataGridRow> extends InheritedWidget {
  final DataGridController<T> controller;
  final GridScrollController scrollController;

  /// The [FocusNode] attached to the grid's root [Focus] widget.
  ///
  /// Cells call [FocusNode.requestFocus] on this node when tapped so that
  /// keyboard navigation works on WASM web, where [GestureDetector] taps do
  /// not automatically return Flutter keyboard focus from the browser.
  final FocusNode gridFocusNode;

  const DataGridControllerScope({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.gridFocusNode,
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
        oldWidget.scrollController != scrollController ||
        oldWidget.gridFocusNode != gridFocusNode;
  }
}

/// Provides grid state via [InheritedModel] so dependents can subscribe
/// to specific [DataGridAspect]s and skip rebuilds for unrelated changes.
class DataGridStateScope<T extends DataGridRow>
    extends InheritedModel<DataGridAspect> {
  final DataGridState<T> state;

  /// Effective columns for the current state, memoized by the caller so the
  /// list keeps its identity across emissions — `state.effectiveColumns` is a
  /// getter that allocates a new list on every access under multi-select, and
  /// the quadrants gate their cell caches on that identity.
  final List<DataGridColumn<T>> effectiveColumns;

  /// The flattened, grouping-aware list of visual row slots for the current
  /// state, computed once by the caller (see `computeDisplayRows`) rather
  /// than recomputed here, so every dependent reuses the same list.
  final List<GridDisplayRow<T>> displayRows;

  /// `state.rowsById` latched by the caller. Freezed re-wraps its collection
  /// getters in a fresh `EqualUnmodifiableMapView` on *every* access, so
  /// reading `state.rowsById` directly would hand every consumer a different
  /// object each build and defeat their identity-based caches. Read this.
  final Map<double, T> rowsById;

  const DataGridStateScope({
    super.key,
    required this.state,
    required this.displayRows,
    required this.effectiveColumns,
    required this.rowsById,
    required super.child,
  });

  @override
  bool updateShouldNotify(DataGridStateScope<T> oldWidget) {
    // Identity, not `==`: DataGridState's generated equality deep-compares
    // `rowsById`/`displayOrder`, which is O(row count) on every rebuild. This
    // is only the coarse gate — `updateShouldNotifyDependent` below does the
    // real per-aspect filtering — so erring towards "changed" is free.
    return !identical(oldWidget.state, state);
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
        case DataGridAspect.group:
          if (state.group != oldWidget.state.group) return true;
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
  final List<GridDisplayRow<T>> displayRows;
  final List<DataGridColumn<T>> effectiveColumns;
  final Map<double, T> rowsById;
  final FocusNode gridFocusNode;
  final Widget child;

  const DataGridInherited({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.state,
    required this.displayRows,
    required this.effectiveColumns,
    required this.rowsById,
    required this.gridFocusNode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DataGridControllerScope<T>(
      controller: controller,
      scrollController: scrollController,
      gridFocusNode: gridFocusNode,
      child: DataGridStateScope<T>(
        state: state,
        displayRows: displayRows,
        effectiveColumns: effectiveColumns,
        rowsById: rowsById,
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

  /// Returns the grid's root [FocusNode]. Widgets can call [FocusNode.requestFocus]
  /// on it to ensure keyboard events reach the grid (required on WASM web).
  FocusNode? dataGridFocusNode<T extends DataGridRow>() {
    return DataGridControllerScope.maybeOf<T>(this)?.gridFocusNode;
  }

  /// Depends on the given [aspects] of grid state. If [aspects] is null,
  /// depends on all state changes (backward-compatible fallback).
  DataGridState<T>? dataGridState<T extends DataGridRow>([
    Set<DataGridAspect>? aspects,
  ]) {
    if (aspects == null || aspects.isEmpty) {
      return InheritedModel.inheritFrom<DataGridStateScope<T>>(this)?.state;
    }
    DataGridStateScope<T>? scope;
    for (final aspect in aspects) {
      scope = InheritedModel.inheritFrom<DataGridStateScope<T>>(
        this,
        aspect: aspect,
      );
    }
    return scope?.state;
  }

  /// Depends on the [DataGridAspect.columns] aspect only.
  List<DataGridColumn<T>>? dataGridEffectiveColumns<T extends DataGridRow>() {
    return InheritedModel.inheritFrom<DataGridStateScope<T>>(
      this,
      aspect: DataGridAspect.columns,
    )?.effectiveColumns;
  }

  /// Depends on the [DataGridAspect.data] aspect only — the latched
  /// `rowsById` map. Prefer this over `state.rowsById`, which allocates a new
  /// view on every access (see [DataGridStateScope.rowsById]).
  Map<double, T>? dataGridRowsById<T extends DataGridRow>() {
    return InheritedModel.inheritFrom<DataGridStateScope<T>>(
      this,
      aspect: DataGridAspect.data,
    )?.rowsById;
  }

  /// Depends on [DataGridAspect.data] and [DataGridAspect.group] — the
  /// flattened, grouping-aware list of visual row slots for the current state.
  List<GridDisplayRow<T>>? dataGridDisplayRows<T extends DataGridRow>() {
    DataGridStateScope<T>? scope;
    for (final aspect in {DataGridAspect.data, DataGridAspect.group}) {
      scope = InheritedModel.inheritFrom<DataGridStateScope<T>>(
        this,
        aspect: aspect,
      );
    }
    return scope?.displayRows;
  }
}
