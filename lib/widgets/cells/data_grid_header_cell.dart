import 'package:flutter/material.dart';
import 'package:data_grid/models/data/column.dart';
import 'package:data_grid/models/state/grid_state.dart';
import 'package:data_grid/models/enums/sort_direction.dart';
import 'package:data_grid/theme/data_grid_theme.dart';

/// A single header cell widget that displays column title and handles sorting/resizing.
/// Supports:
/// - Click to sort (ascending -> descending -> no sort)
/// - Drag right edge to resize column
/// - Visual feedback for sort state and multi-sort priority
class DataGridHeaderCell extends StatefulWidget {
  final DataGridColumn column;
  final SortState sortState;
  final Function(SortDirection?) onSort;
  final Function(double delta) onResize;

  const DataGridHeaderCell({
    super.key,
    required this.column,
    required this.sortState,
    required this.onSort,
    required this.onResize,
  });

  @override
  State<DataGridHeaderCell> createState() => _DataGridHeaderCellState();
}

class _DataGridHeaderCellState extends State<DataGridHeaderCell> {
  bool _isResizing = false;
  double _resizeStartX = 0;

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final sortColumn = widget.sortState.sortColumns.where((s) => s.columnId == widget.column.id).firstOrNull;

    final sortLabel = sortColumn == null
        ? 'Sort by ${widget.column.title}'
        : sortColumn.direction == SortDirection.ascending
        ? '${widget.column.title} sorted ascending'
        : '${widget.column.title} sorted descending';

    return Semantics(
      label: sortLabel,
      button: true,
      onTap: () {
        if (sortColumn == null) {
          widget.onSort(SortDirection.ascending);
        } else if (sortColumn.direction == SortDirection.ascending) {
          widget.onSort(SortDirection.descending);
        } else {
          widget.onSort(null);
        }
      },
      child: Container(
        decoration: BoxDecoration(color: theme.colors.headerColor, border: theme.borders.headerBorder),
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
                padding: theme.padding.headerPadding,
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
                      SizedBox(width: theme.padding.iconSpacing),
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
                    width: theme.dimensions.resizeHandleWidth,
                    color: _isResizing ? theme.colors.resizeHandleActiveColor : Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
