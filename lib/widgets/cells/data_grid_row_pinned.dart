import 'package:flutter/material.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/delegates/body_layout_delegate.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

/// A data grid row widget that supports pinned (frozen) columns.
///
/// This widget renders a row with both pinned and unpinned columns:
/// - Pinned columns remain fixed on the left side
/// - Unpinned columns scroll horizontally
/// - Both sections share the same row selection state
class DataGridRowWithPinnedCells<T extends DataGridRow>
    extends StatelessWidget {
  final T row;
  final int index;
  final List<DataGridColumn<T>> pinnedColumns;
  final List<DataGridColumn<T>> unpinnedColumns;
  final double pinnedWidth;
  final double unpinnedWidth;
  final double horizontalOffset;
  final DataGridController<T> controller;
  final GridScrollController scrollController;
  final double rowHeight;
  final Widget Function(T row, int columnId)? cellBuilder;

  const DataGridRowWithPinnedCells({
    super.key,
    required this.row,
    required this.index,
    required this.pinnedColumns,
    required this.unpinnedColumns,
    required this.pinnedWidth,
    required this.unpinnedWidth,
    required this.horizontalOffset,
    required this.controller,
    required this.scrollController,
    required this.rowHeight,
    this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);

    return StreamBuilder<bool>(
      stream: controller.selection$
          .map((s) => s.isRowSelected(row.id))
          .distinct(),
      initialData: controller.state.selection.isRowSelected(row.id),
      builder: (context, snapshot) {
        final isSelected = snapshot.data ?? false;

        return GestureDetector(
          onTap: () {
            if (controller.state.selection.mode != SelectionMode.none) {
              final isMultiSelectMode =
                  controller.state.selection.mode == SelectionMode.multiple;
              controller.addEvent(
                SelectRowEvent(rowId: row.id, multiSelect: isMultiSelectMode),
              );
            }
          },
          child: Container(
            height: rowHeight,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colors.selectionColor
                  : (index % 2 == 0
                        ? theme.colors.evenRowColor
                        : theme.colors.oddRowColor),
              border: theme.borders.rowBorder,
            ),
            child: Stack(
              children: [
                // Unpinned cells (responds to horizontal scroll)
                Positioned(
                  left: pinnedWidth,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(-horizontalOffset, 0),
                      child: SizedBox(
                        width: unpinnedWidth,
                        height: rowHeight,
                        child: CustomMultiChildLayout(
                          delegate: BodyLayoutDelegate(
                            columns: unpinnedColumns,
                          ),
                          children: [
                            for (var column in unpinnedColumns)
                              LayoutId(
                                id: column.id,
                                child: _RowCell<T>(
                                  row: row,
                                  column: column,
                                  cellBuilder: cellBuilder,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Pinned cells (fixed position)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: pinnedWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: theme.borders.pinnedBorder,
                      boxShadow: theme.borders.pinnedShadow,
                    ),
                    child: CustomMultiChildLayout(
                      delegate: BodyLayoutDelegate(columns: pinnedColumns),
                      children: [
                        for (var column in pinnedColumns)
                          LayoutId(
                            id: column.id,
                            child: _RowCell<T>(
                              row: row,
                              column: column,
                              cellBuilder: cellBuilder,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RowCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final DataGridColumn<T> column;
  final Widget Function(T row, int columnId)? cellBuilder;

  const _RowCell({required this.row, required this.column, this.cellBuilder});

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);

    if (cellBuilder != null) {
      return cellBuilder!(row, column.id);
    }

    return Container(
      padding: theme.padding.cellPadding,
      alignment: Alignment.centerLeft,
      child: Text(
        'Row ${row.id}, Col ${column.id}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
