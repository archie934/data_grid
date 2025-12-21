import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
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
    return CustomMultiChildLayout(
      delegate: HeaderLayoutDelegate(state.columns),
      children: [
        for (var column in state.columns)
          LayoutId(
            id: column.id,
            child: DataGridHeaderCell(
              column: column,
              sortState: state.sort,
              onSort: (direction) {
                controller.addEvent(SortEvent(columnId: column.id, direction: direction, multiSort: false));
              },
              onResize: (delta) {
                final newWidth = (column.width + delta).clamp(50.0, 1000.0);
                controller.addEvent(ColumnResizeEvent(columnId: column.id, newWidth: newWidth));
              },
            ),
          ),
      ],
    );
  }
}
