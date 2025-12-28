import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/widgets/data_grid_scroll_view.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_cell.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_checkbox_cell.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_horizontal.dart';
import 'package:data_grid/data_grid/renderers/row_renderer.dart';
import 'package:data_grid/data_grid/renderers/cell_renderer.dart';
import 'package:data_grid/data_grid/renderers/default_row_renderer.dart';
import 'package:data_grid/data_grid/renderers/render_context.dart';

const scrollbarWidth = 12.0;

class DataGridBody<T extends DataGridRow> extends StatefulWidget {
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
  State<DataGridBody<T>> createState() => _DataGridBodyState<T>();
}

class _DataGridBodyState<T extends DataGridRow> extends State<DataGridBody<T>> {
  late List<DataGridColumn> pinnedColumns;
  late List<DataGridColumn> unpinnedColumns;

  @override
  void initState() {
    super.initState();
    _updateColumns();
  }

  @override
  void didUpdateWidget(DataGridBody<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.effectiveColumns != widget.state.effectiveColumns) {
      _updateColumns();
    }
  }

  void _updateColumns() {
    pinnedColumns = widget.state.effectiveColumns.where((col) => col.pinned && col.visible).toList();
    unpinnedColumns = widget.state.effectiveColumns.where((col) => !col.pinned && col.visible).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (pinnedColumns.isEmpty) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          return false;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: DataGridScrollView(
                columns: widget.state.effectiveColumns,
                rowCount: widget.state.displayOrder.length,
                rowHeight: widget.rowHeight,
                verticalDetails: ScrollableDetails.vertical(controller: widget.scrollController.verticalController),
                horizontalDetails: ScrollableDetails.horizontal(
                  controller: widget.scrollController.horizontalController,
                ),
                cellBuilder: (context, rowIndex, columnIndex) {
                  final rowId = widget.state.displayOrder[rowIndex];
                  final row = widget.state.rowsById[rowId]!;
                  final column = widget.state.effectiveColumns[columnIndex];

                  if (column.id == kSelectionColumnId) {
                    return DataGridCheckboxCell<T>(
                      row: row,
                      rowId: row.id,
                      rowIndex: rowIndex,
                      controller: widget.controller,
                    );
                  }

                  return DataGridCell<T>(
                    row: row,
                    rowId: row.id,
                    column: column,
                    rowIndex: rowIndex,
                    controller: widget.controller,
                    cellBuilder: widget.cellBuilder,
                  );
                },
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: scrollbarWidth,
              child: CustomVerticalScrollbar(
                controller: widget.scrollController.verticalController,
                width: scrollbarWidth,
              ),
            ),
            Positioned(
              left: 0,
              right: scrollbarWidth,
              bottom: 0,
              child: CustomHorizontalScrollbar(
                controller: widget.scrollController.horizontalController,
                height: scrollbarWidth,
              ),
            ),
          ],
        ),
      );
    }

    return _PinnedLayout<T>(
      state: widget.state,
      controller: widget.controller,
      scrollController: widget.scrollController,
      pinnedColumns: pinnedColumns,
      unpinnedColumns: unpinnedColumns,
      rowHeight: widget.rowHeight,
      rowRenderer: widget.rowRenderer,
      cellRenderer: widget.cellRenderer,
      cellBuilder: widget.cellBuilder,
    );
  }
}

class _PinnedLayout<T extends DataGridRow> extends StatelessWidget {
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final List<DataGridColumn> pinnedColumns;
  final List<DataGridColumn> unpinnedColumns;
  final double rowHeight;
  final RowRenderer<T>? rowRenderer;
  final CellRenderer<T>? cellRenderer;
  final Widget Function(T row, int columnId)? cellBuilder;

  const _PinnedLayout({
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.pinnedColumns,
    required this.unpinnedColumns,
    required this.rowHeight,
    this.rowRenderer,
    this.cellRenderer,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final pinnedWidth = pinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
    final unpinnedWidth = unpinnedColumns.fold<double>(0.0, (sum, col) => sum + col.width);
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
        Positioned(
          right: 0,
          top: 0,
          bottom: scrollbarWidth,
          child: CustomVerticalScrollbar(controller: scrollController.verticalController, width: scrollbarWidth),
        ),
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
