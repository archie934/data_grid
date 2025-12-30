import 'package:flutter/material.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';

class DataGridInherited<T extends DataGridRow> extends InheritedWidget {
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final DataGridState<T> state;

  const DataGridInherited({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.state,
    required super.child,
  });

  static DataGridInherited<T>? maybeOf<T extends DataGridRow>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataGridInherited<T>>();
  }

  @override
  bool updateShouldNotify(DataGridInherited<T> oldWidget) {
    return oldWidget.controller != controller ||
        oldWidget.scrollController != scrollController ||
        oldWidget.state != state;
  }
}

extension DataGridContext on BuildContext {
  DataGridController<T>? dataGridController<T extends DataGridRow>() {
    return DataGridInherited.maybeOf<T>(this)?.controller;
  }

  GridScrollController? gridScrollController<T extends DataGridRow>() {
    return DataGridInherited.maybeOf<T>(this)?.scrollController;
  }

  DataGridState<T>? dataGridState<T extends DataGridRow>() {
    return DataGridInherited.maybeOf<T>(this)?.state;
  }
}
