import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/base_event.dart';
import 'package:flutter_data_grid/models/events/event_context.dart';

class ColumnResizeEvent extends DataGridEvent {
  final int columnId;
  final double newWidth;

  ColumnResizeEvent({required this.columnId, required this.newWidth});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final updatedColumns = context.state.columns.map((col) {
      if (col.id == columnId) {
        return col.copyWith(width: newWidth);
      }
      return col;
    }).toList();
    return context.state.copyWith(columns: updatedColumns);
  }
}

class ColumnReorderEvent extends DataGridEvent {
  final int oldIndex;
  final int newIndex;

  ColumnReorderEvent({required this.oldIndex, required this.newIndex});

  @override
  DataGridState<T>? apply<T extends DataGridRow>(EventContext<T> context) {
    final updatedColumns = List.of(context.state.columns);

    if (oldIndex < 0 ||
        oldIndex >= updatedColumns.length ||
        newIndex < 0 ||
        newIndex >= updatedColumns.length) {
      return null;
    }

    final column = updatedColumns.removeAt(oldIndex);
    updatedColumns.insert(newIndex, column);
    return context.state.copyWith(columns: updatedColumns);
  }
}
