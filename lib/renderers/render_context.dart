import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';

/// Context provided to row renderers with all necessary state and callbacks.
class RowRenderContext<T extends DataGridRow> {
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final List<DataGridColumn<T>> pinnedColumns;
  final List<DataGridColumn<T>> unpinnedColumns;
  final double pinnedWidth;
  final double unpinnedWidth;
  final double horizontalOffset;
  final double rowHeight;
  final bool isSelected;
  final bool isHovered;

  const RowRenderContext({
    required this.controller,
    required this.scrollController,
    required this.pinnedColumns,
    required this.unpinnedColumns,
    required this.pinnedWidth,
    required this.unpinnedWidth,
    required this.horizontalOffset,
    required this.rowHeight,
    required this.isSelected,
    required this.isHovered,
  });
}

/// Context provided to cell renderers.
class CellRenderContext<T extends DataGridRow> {
  final DataGridController<T> controller;
  final bool isSelected;
  final bool isHovered;
  final bool isPinned;
  final int rowIndex;

  const CellRenderContext({
    required this.controller,
    required this.isSelected,
    required this.isHovered,
    required this.isPinned,
    required this.rowIndex,
  });
}
