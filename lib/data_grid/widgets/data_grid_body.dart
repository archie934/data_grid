import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/widgets/data_grid_scroll_view.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_cell.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_horizontal.dart';
import 'package:data_grid/data_grid/renderers/row_renderer.dart';
import 'package:data_grid/data_grid/renderers/cell_renderer.dart';
import 'package:data_grid/data_grid/renderers/default_row_renderer.dart';
import 'package:data_grid/data_grid/renderers/render_context.dart';

class DataGridBody<T extends DataGridRow> extends StatelessWidget {
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final double rowHeight;
  final RowRenderer<T>? rowRenderer;
  final CellRenderer<T>? cellRenderer;
  final Widget Function(T row, int columnId)? cellBuilder;

  const DataGridBody({
    super.key,
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.rowHeight,
    this.rowRenderer,
    this.cellRenderer,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    const scrollbarWidth = 12.0;

    final pinnedColumns = state.columns.where((col) => col.pinned && col.visible).toList();
    final unpinnedColumns = state.columns.where((col) => !col.pinned && col.visible).toList();

    if (pinnedColumns.isEmpty) {
      // Current DataGridScrollView approach
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          return false;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: DataGridScrollView(
                columns: state.columns,
                rowCount: state.displayOrder.length,
                rowHeight: rowHeight,
                verticalDetails: ScrollableDetails.vertical(controller: scrollController.verticalController),
                horizontalDetails: ScrollableDetails.horizontal(controller: scrollController.horizontalController),
                cellBuilder: (context, rowIndex, columnIndex) {
                  final rowId = state.displayOrder[rowIndex];
                  final row = state.rowsById[rowId]!;
                  final column = state.columns[columnIndex];

                  return DataGridCell<T>(
                    row: row,
                    rowId: row.id,
                    columnId: column.id,
                    rowIndex: rowIndex,
                    controller: controller,
                    cellBuilder: cellBuilder,
                  );
                },
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: scrollbarWidth,
              child: CustomVerticalScrollbar(controller: scrollController.verticalController, width: scrollbarWidth),
            ),
            Positioned(
              left: 0,
              right: scrollbarWidth,
              bottom: 0,
              child: CustomHorizontalScrollbar(
                controller: scrollController.horizontalController,
                height: scrollbarWidth,
              ),
            ),
          ],
        ),
      );
    }

    // ListView with pinned columns and Listener for gestures
    return _buildPinnedLayout(pinnedColumns, unpinnedColumns, scrollbarWidth);
  }

  Widget _buildPinnedLayout(
    List<DataGridColumn> pinnedColumns,
    List<DataGridColumn> unpinnedColumns,
    double scrollbarWidth,
  ) {
    final pinnedWidth = pinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
    final unpinnedWidth = unpinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);

    // Use provided renderer or default
    final effectiveRowRenderer = rowRenderer ?? DefaultRowRenderer<T>(cellRenderer: cellRenderer);

    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            onPointerSignal: (event) {
              // Handle mouse wheel horizontal scrolling
              if (event is PointerScrollEvent) {
                if (scrollController.horizontalController.hasClients) {
                  final offset = scrollController.horizontalController.offset;
                  final max = scrollController.horizontalController.position.maxScrollExtent;
                  final newOffset = (offset + event.scrollDelta.dx).clamp(0.0, max);
                  scrollController.horizontalController.jumpTo(newOffset);
                }
              }
            },
            onPointerMove: (event) {
              // Handle drag gestures for horizontal scrolling
              if (event.localPosition.dx > pinnedWidth && event.delta.dx.abs() > event.delta.dy.abs()) {
                if (scrollController.horizontalController.hasClients) {
                  final offset = scrollController.horizontalController.offset;
                  final max = scrollController.horizontalController.position.maxScrollExtent;
                  final newOffset = (offset - event.delta.dx).clamp(0.0, max);
                  scrollController.horizontalController.jumpTo(newOffset);
                }
              }
            },
            child: AnimatedBuilder(
              animation: scrollController.horizontalController,
              builder: (context, child) {
                final horizontalOffset = scrollController.horizontalController.hasClients
                    ? scrollController.horizontalController.offset
                    : 0.0;

                return ListView.builder(
                  controller: scrollController.verticalController,
                  itemCount: state.displayOrder.length,
                  itemExtent: rowHeight,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    final rowId = state.displayOrder[index];
                    final row = state.rowsById[rowId]!;

                    // Build row render context
                    final renderContext = RowRenderContext<T>(
                      controller: controller,
                      scrollController: scrollController,
                      pinnedColumns: pinnedColumns,
                      unpinnedColumns: unpinnedColumns,
                      pinnedWidth: pinnedWidth,
                      unpinnedWidth: unpinnedWidth,
                      horizontalOffset: horizontalOffset,
                      rowHeight: rowHeight,
                      isSelected: controller.state.selection.isRowSelected(row.id),
                      isHovered: false,
                      cellBuilder: cellBuilder,
                    );

                    return effectiveRowRenderer.buildRow(context, row, index, renderContext);
                  },
                );
              },
            ),
          ),
        ),
        // Vertical scrollbar
        Positioned(
          right: 0,
          top: 0,
          bottom: scrollbarWidth,
          child: CustomVerticalScrollbar(controller: scrollController.verticalController, width: scrollbarWidth),
        ),
        // Horizontal scrollbar
        Positioned(
          left: pinnedWidth,
          right: scrollbarWidth,
          bottom: 0,
          child: CustomHorizontalScrollbar(controller: scrollController.horizontalController, height: scrollbarWidth),
        ),
      ],
    );
  }
}
