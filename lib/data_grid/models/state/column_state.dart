import 'package:freezed_annotation/freezed_annotation.dart';

part 'column_state.freezed.dart';

@freezed
class ColumnState with _$ColumnState {
  const factory ColumnState({
    required int columnId,
    required double width,
    @Default(true) bool visible,
    @Default(false) bool pinned,
    required int order,
    @Default(true) bool resizable,
    @Default(true) bool sortable,
    @Default(true) bool filterable,
  }) = _ColumnState;

  factory ColumnState.fromColumn(int columnId, double width, int order) =>
      ColumnState(columnId: columnId, width: width, order: order);
}

@freezed
class ColumnsState with _$ColumnsState {
  const factory ColumnsState({
    required Map<int, ColumnState> columns,
    required List<int> columnOrder,
    required double totalWidth,
  }) = _ColumnsState;

  const ColumnsState._();

  factory ColumnsState.initial() => const ColumnsState(columns: {}, columnOrder: [], totalWidth: 0);

  List<ColumnState> get visibleColumns =>
      columnOrder.where((id) => columns[id]?.visible ?? false).map((id) => columns[id]!).toList();

  ColumnState? getColumn(int columnId) => columns[columnId];

  double getColumnOffset(int columnId) {
    double offset = 0;
    for (final id in columnOrder) {
      if (id == columnId) break;
      final col = columns[id];
      if (col?.visible ?? false) {
        offset += col!.width;
      }
    }
    return offset;
  }

  ColumnsState updateColumnWidth(int columnId, double newWidth) {
    final column = columns[columnId];
    if (column == null) return this;

    final updatedColumns = Map<int, ColumnState>.from(columns);
    updatedColumns[columnId] = column.copyWith(width: newWidth);

    final newTotalWidth = updatedColumns.values.where((c) => c.visible).fold(0.0, (sum, c) => sum + c.width);

    return copyWith(columns: updatedColumns, totalWidth: newTotalWidth);
  }

  ColumnsState reorderColumns(int oldIndex, int newIndex) {
    final newOrder = List<int>.from(columnOrder);
    final item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);

    final updatedColumns = Map<int, ColumnState>.from(columns);
    for (var i = 0; i < newOrder.length; i++) {
      final colId = newOrder[i];
      updatedColumns[colId] = updatedColumns[colId]!.copyWith(order: i);
    }

    return copyWith(columns: updatedColumns, columnOrder: newOrder);
  }
}
