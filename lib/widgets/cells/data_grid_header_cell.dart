import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// A single header cell widget that displays column title and handles sorting/resizing.
/// Supports:
/// - Click to sort (ascending -> descending -> no sort)
/// - Drag right edge to resize column
/// - Visual feedback for sort state and multi-sort priority
class DataGridHeaderCell extends StatefulWidget {
  final DataGridColumn column;
  final SortState sortState;
  final Function(SortDirection?) onSort;

  /// Called during a drag with the new **absolute** target width (already
  /// clamped to [columnMinWidth]..[columnMaxWidth]).
  final Function(double newWidth) onResize;

  /// When provided, overrides the default [DataGridBorders.headerBorder]
  /// for this cell's container decoration (e.g. to suppress the right border
  /// on pinned columns where the outer wrapper already draws it).
  final Border? borderOverride;

  const DataGridHeaderCell({
    super.key,
    required this.column,
    required this.sortState,
    required this.onSort,
    required this.onResize,
    this.borderOverride,
  });

  @override
  State<DataGridHeaderCell> createState() => _DataGridHeaderCellState();
}

class _DataGridHeaderCellState extends State<DataGridHeaderCell> {
  bool _isResizing = false;
  bool _isHovering = false;

  /// Locally-tracked width so every drag-update delta is applied to the
  /// most-recent value rather than a potentially stale rebuild value.
  late double _currentWidth;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.column.width;
  }

  @override
  void didUpdateWidget(DataGridHeaderCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync from the widget tree only when the user is not actively dragging;
    // during a drag we own the width value.
    if (!_isResizing) {
      _currentWidth = widget.column.width;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final sortColumn = widget.sortState.sortColumn;
    final isSorted =
        sortColumn != null && sortColumn.columnId == widget.column.id;

    final sortLabel = !isSorted
        ? 'Sort by ${widget.column.title}'
        : sortColumn.direction == SortDirection.ascending
        ? '${widget.column.title} sorted ascending'
        : '${widget.column.title} sorted descending';

    return Semantics(
      label: sortLabel,
      button: true,
      onTap: () {
        if (!isSorted) {
          widget.onSort(SortDirection.ascending);
        } else if (sortColumn.direction == SortDirection.ascending) {
          widget.onSort(SortDirection.descending);
        } else {
          widget.onSort(null);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.headerColor,
          border: widget.borderOverride ?? theme.borders.headerBorder,
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                if (!isSorted) {
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSorted) ...[
                      SizedBox(width: theme.padding.iconSpacing),
                      Icon(
                        sortColumn.direction == SortDirection.ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (_) {
                    setState(() => _isResizing = true);
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isResizing) {
                      final theme = DataGridTheme.of(context);
                      // Clamp per-event delta to prevent jarring jumps from
                      // coalesced or late-arriving pointer events.
                      final delta = details.delta.dx.clamp(-80.0, 80.0);
                      _currentWidth = (_currentWidth + delta).clamp(
                        theme.dimensions.columnMinWidth,
                        theme.dimensions.columnMaxWidth,
                      );
                      widget.onResize(_currentWidth);
                    }
                  },
                  onHorizontalDragEnd: (_) {
                    setState(() => _isResizing = false);
                  },
                  // Use a wider hit area (16 px) than the visual indicator so
                  // the handle is easy to grab without pixel-perfect aiming.
                  child: SizedBox(
                    width: 16.0,
                    child: Center(
                      child: Container(
                        width: theme.dimensions.resizeHandleWidth,
                        color: _isResizing
                            ? theme.colors.resizeHandleActiveColor
                            : _isHovering
                            ? theme.colors.resizeHandleActiveColor.withValues(
                                alpha: 0.45,
                              )
                            : Colors.transparent,
                      ),
                    ),
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
