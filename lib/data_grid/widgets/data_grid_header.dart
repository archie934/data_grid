import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/delegates/header_layout_delegate.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_header_cell.dart';

class DataGridHeader<T extends DataGridRow> extends StatelessWidget {
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final GridScrollController scrollController;

  const DataGridHeader({super.key, required this.state, required this.controller, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final pinnedColumns = state.columns.where((col) => col.pinned && col.visible).toList();
    final unpinnedColumns = state.columns.where((col) => !col.pinned && col.visible).toList();

    if (pinnedColumns.isEmpty) {
      // Simple layout - no pinned columns
      return CustomMultiChildLayout(
        delegate: HeaderLayoutDelegate(columns: state.columns),
        children: [for (var column in state.columns) LayoutId(id: column.id, child: _buildHeaderCell(column))],
      );
    }

    // Split layout with pinned + scrollable unpinned
    final pinnedWidth = pinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
    final unpinnedWidth = unpinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);

    return Stack(
      children: [
        // Unpinned header (scrollable)
        Positioned(
          left: pinnedWidth,
          right: 0,
          top: 0,
          bottom: 0,
          child: SingleChildScrollView(
            controller: scrollController.horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: unpinnedWidth,
              child: CustomMultiChildLayout(
                delegate: HeaderLayoutDelegate(columns: unpinnedColumns),
                children: [
                  for (var column in unpinnedColumns) LayoutId(id: column.id, child: _buildHeaderCell(column)),
                ],
              ),
            ),
          ),
        ),
        // Pinned header (fixed)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: pinnedWidth,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(right: BorderSide(color: Colors.grey[400]!, width: 2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(2, 0)),
              ],
            ),
            child: CustomMultiChildLayout(
              delegate: HeaderLayoutDelegate(columns: pinnedColumns),
              children: [for (var column in pinnedColumns) LayoutId(id: column.id, child: _buildHeaderCell(column))],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(DataGridColumn column) {
    return DataGridHeaderCell(
      column: column,
      sortState: state.sort,
      onSort: (direction) {
        controller.addEvent(SortEvent(columnId: column.id, direction: direction, multiSort: false));
      },
      onResize: (delta) {
        final newWidth = (column.width + delta).clamp(50.0, 1000.0);
        controller.addEvent(ColumnResizeEvent(columnId: column.id, newWidth: newWidth));
      },
    );
  }
}
