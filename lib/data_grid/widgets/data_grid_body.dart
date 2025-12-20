import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/delegates/body_layout_delegate.dart';

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
    return ListView.builder(
      controller: scrollController.verticalController,
      itemCount: state.displayIndices.length,
      itemExtent: rowHeight,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final rowIndex = state.displayIndices[index];
        final row = state.rows[rowIndex];

        return _DataGridRow<T>(
          key: ValueKey(row.id),
          row: row,
          index: index,
          columns: state.columns,
          controller: controller,
          rowHeight: rowHeight,
          cellBuilder: cellBuilder,
        );
      },
    );
  }
}

class _DataGridRow<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final int index;
  final List<DataGridColumn> columns;
  final DataGridController<T> controller;
  final double rowHeight;
  final Widget Function(T row, int columnId)? cellBuilder;

  const _DataGridRow({
    super.key,
    required this.row,
    required this.index,
    required this.columns,
    required this.controller,
    required this.rowHeight,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SelectionState>(
      stream: controller.selection$,
      initialData: controller.state.selection,
      builder: (context, snapshot) {
        final isSelected = snapshot.data?.isRowSelected(row.id) ?? false;

        return GestureDetector(
          onTap: () {
            controller.addEvent(SelectRowEvent(rowId: row.id, multiSelect: false));
          },
          child: Container(
            height: rowHeight,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : (index % 2 == 0 ? Colors.white : Colors.grey[50]),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: CustomMultiChildLayout(
              delegate: BodyLayoutDelegate(columns),
              children: [
                for (var column in columns)
                  LayoutId(
                    id: column.id,
                    child: _DataCell<T>(row: row, columnId: column.id, cellBuilder: cellBuilder),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DataCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final int columnId;
  final Widget Function(T row, int columnId)? cellBuilder;

  const _DataCell({required this.row, required this.columnId, this.cellBuilder});

  @override
  Widget build(BuildContext context) {
    if (cellBuilder != null) {
      return cellBuilder!(row, columnId);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text('Row ${row.id}, Col $columnId', overflow: TextOverflow.ellipsis),
    );
  }
}
