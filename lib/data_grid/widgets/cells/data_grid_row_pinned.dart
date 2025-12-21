import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';
import 'package:data_grid/data_grid/delegates/body_layout_delegate.dart';

/// A data grid row widget that supports pinned (frozen) columns.
/// 
/// This widget renders a row with both pinned and unpinned columns:
/// - Pinned columns remain fixed on the left side
/// - Unpinned columns scroll horizontally
/// - Both sections share the same row selection state
class DataGridRowWithPinnedCells<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final int index;
  final List<DataGridColumn> pinnedColumns;
  final List<DataGridColumn> unpinnedColumns;
  final double pinnedWidth;
  final double unpinnedWidth;
  final double horizontalOffset;
  final DataGridController<T> controller;
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
                          delegate: BodyLayoutDelegate(unpinnedColumns),
                          children: [
                            for (var column in unpinnedColumns) LayoutId(id: column.id, child: _buildCell(column)),
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
                      border: Border(right: BorderSide(color: Colors.grey[400]!, width: 2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: CustomMultiChildLayout(
                      delegate: BodyLayoutDelegate(pinnedColumns),
                      children: [for (var column in pinnedColumns) LayoutId(id: column.id, child: _buildCell(column))],
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

  Widget _buildCell(DataGridColumn column) {
    if (cellBuilder != null) {
      return cellBuilder!(row, column.id);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text('Row ${row.id}, Col ${column.id}', overflow: TextOverflow.ellipsis),
    );
  }
}

