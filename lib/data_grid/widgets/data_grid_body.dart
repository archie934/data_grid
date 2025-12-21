import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/widgets/data_grid_scroll_view.dart';
import 'package:data_grid/data_grid/widgets/cells/data_grid_cell.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_vertical.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_horizontal.dart';
import 'package:data_grid/data_grid/widgets/scroll/scrollbar_tracker.dart';

class DataGridBody<T extends DataGridRow> extends StatelessWidget {
  final DataGridState<T> state;
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final double rowHeight;
  final Widget Function(T row, int columnId)? cellBuilder;

  const DataGridBody({
    super.key,
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.rowHeight,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    const scrollbarWidth = 12.0;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        return false;
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: DataGridScrollView(
              columns: state.columns,
              rowCount: state.displayIndices.length,
              rowHeight: rowHeight,
              verticalDetails: ScrollableDetails.vertical(controller: scrollController.verticalController),
              horizontalDetails: ScrollableDetails.horizontal(controller: scrollController.horizontalController),
              cellBuilder: (context, rowIndex, columnIndex) {
                final actualRowIndex = state.displayIndices[rowIndex];
                final row = state.rows[actualRowIndex];
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
            child: ScrollbarTracker(
              axis: Axis.vertical,
              controller: scrollController.verticalController,
              child: CustomVerticalScrollbar(controller: scrollController.verticalController, width: scrollbarWidth),
            ),
          ),
          Positioned(
            left: 0,
            right: scrollbarWidth,
            bottom: 0,
            child: ScrollbarTracker(
              axis: Axis.horizontal,
              controller: scrollController.horizontalController,
              child: CustomHorizontalScrollbar(
                controller: scrollController.horizontalController,
                height: scrollbarWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
