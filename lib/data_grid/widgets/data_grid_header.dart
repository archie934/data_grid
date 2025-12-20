import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/controller/grid_scroll_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/delegates/header_layout_delegate.dart';

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
            child: _HeaderCell(
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

class _HeaderCell extends StatefulWidget {
  final DataGridColumn column;
  final SortState sortState;
  final Function(SortDirection?) onSort;
  final Function(double delta) onResize;

  const _HeaderCell({required this.column, required this.sortState, required this.onSort, required this.onResize});

  @override
  State<_HeaderCell> createState() => _HeaderCellState();
}

class _HeaderCellState extends State<_HeaderCell> {
  bool _isResizing = false;
  double _resizeStartX = 0;

  @override
  Widget build(BuildContext context) {
    final sortColumn = widget.sortState.sortColumns.where((s) => s.columnId == widget.column.id).firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          right: BorderSide(color: Colors.grey[400]!),
          bottom: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              if (sortColumn == null) {
                widget.onSort(SortDirection.ascending);
              } else if (sortColumn.direction == SortDirection.ascending) {
                widget.onSort(SortDirection.descending);
              } else {
                widget.onSort(null);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.column.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (sortColumn != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      sortColumn.direction == SortDirection.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                    ),
                    if (widget.sortState.sortColumns.length > 1)
                      Text('${sortColumn.priority + 1}', style: const TextStyle(fontSize: 10)),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragStart: (details) {
                setState(() {
                  _isResizing = true;
                  _resizeStartX = details.globalPosition.dx;
                });
              },
              onHorizontalDragUpdate: (details) {
                if (_isResizing) {
                  final delta = details.globalPosition.dx - _resizeStartX;
                  widget.onResize(delta);
                  _resizeStartX = details.globalPosition.dx;
                }
              },
              onHorizontalDragEnd: (details) {
                setState(() => _isResizing = false);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Container(
                  width: 8,
                  color: _isResizing ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
