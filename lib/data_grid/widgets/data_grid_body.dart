import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/widgets/data_grid_scroll_view.dart';
import 'package:data_grid/data_grid/widgets/custom_scrollbar.dart';

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

                return _DataCell<T>(
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
            child: _ScrollbarWrapper(
              axis: Axis.vertical,
              child: CustomVerticalScrollbar(controller: scrollController.verticalController, width: scrollbarWidth),
            ),
          ),
          Positioned(
            left: 0,
            right: scrollbarWidth,
            bottom: 0,
            child: _ScrollbarWrapper(
              axis: Axis.horizontal,
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

class _ScrollbarWrapper extends StatefulWidget {
  final Axis axis;
  final Widget child;

  const _ScrollbarWrapper({required this.axis, required this.child});

  @override
  State<_ScrollbarWrapper> createState() => _ScrollbarWrapperState();
}

class _ScrollbarWrapperState extends State<_ScrollbarWrapper> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == widget.axis) {
          setState(() {});
        }
        return false;
      },
      child: widget.child,
    );
  }
}

class _DataCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final double rowId;
  final int columnId;
  final int rowIndex;
  final DataGridController<T> controller;
  final Widget Function(T row, int columnId)? cellBuilder;

  const _DataCell({
    required this.row,
    required this.rowId,
    required this.columnId,
    required this.rowIndex,
    required this.controller,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SelectionState>(
      stream: controller.selection$,
      initialData: controller.state.selection,
      builder: (context, snapshot) {
        final isSelected = snapshot.data?.isRowSelected(rowId) ?? false;

        return GestureDetector(
          onTap: () {
            controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: false));
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : (rowIndex % 2 == 0 ? Colors.white : Colors.grey[50]),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerLeft,
            child: cellBuilder != null
                ? cellBuilder!(row, columnId)
                : Text('Row ${row.id}, Col $columnId', overflow: TextOverflow.ellipsis),
          ),
        );
      },
    );
  }
}
