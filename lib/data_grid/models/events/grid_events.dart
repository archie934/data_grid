import 'package:data_grid/data_grid/models/state/grid_state.dart';

abstract class DataGridEvent {}

class ScrollEvent extends DataGridEvent {
  final double offsetX;
  final double offsetY;

  ScrollEvent({required this.offsetX, required this.offsetY});
}

class ViewportResizeEvent extends DataGridEvent {
  final double width;
  final double height;

  ViewportResizeEvent({required this.width, required this.height});
}

class ColumnResizeEvent extends DataGridEvent {
  final int columnId;
  final double newWidth;

  ColumnResizeEvent({required this.columnId, required this.newWidth});
}

class ColumnReorderEvent extends DataGridEvent {
  final int oldIndex;
  final int newIndex;

  ColumnReorderEvent({required this.oldIndex, required this.newIndex});
}

class SortEvent extends DataGridEvent {
  final int columnId;
  final SortDirection? direction;
  final bool multiSort;

  SortEvent({required this.columnId, this.direction, this.multiSort = false});
}

class FilterEvent extends DataGridEvent {
  final int columnId;
  final FilterOperator operator;
  final dynamic value;

  FilterEvent({required this.columnId, required this.operator, required this.value});
}

class ClearFilterEvent extends DataGridEvent {
  final int? columnId;

  ClearFilterEvent({this.columnId});
}

class SelectRowEvent extends DataGridEvent {
  final double rowId;
  final bool multiSelect;

  SelectRowEvent({required this.rowId, this.multiSelect = false});
}

class SelectRowsRangeEvent extends DataGridEvent {
  final double startRowId;
  final double endRowId;

  SelectRowsRangeEvent({required this.startRowId, required this.endRowId});
}

class ClearSelectionEvent extends DataGridEvent {}

class GroupByColumnEvent extends DataGridEvent {
  final int columnId;

  GroupByColumnEvent({required this.columnId});
}

class UngroupColumnEvent extends DataGridEvent {
  final int columnId;

  UngroupColumnEvent({required this.columnId});
}

class ToggleGroupExpansionEvent extends DataGridEvent {
  final String groupKey;

  ToggleGroupExpansionEvent({required this.groupKey});
}

class LoadDataEvent<T> extends DataGridEvent {
  final List<T> rows;
  final bool append;

  LoadDataEvent({required this.rows, this.append = false});
}

class RefreshDataEvent extends DataGridEvent {}

class SetLoadingEvent extends DataGridEvent {
  final bool isLoading;
  final String? message;

  SetLoadingEvent({required this.isLoading, this.message});
}