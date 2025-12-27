import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/events/grid_events.dart';
import 'package:data_grid/data_grid/delegates/body_layout_delegate.dart';
import 'package:data_grid/data_grid/renderers/row_renderer.dart';
import 'package:data_grid/data_grid/renderers/cell_renderer.dart';
import 'package:data_grid/data_grid/renderers/default_cell_renderer.dart';
import 'package:data_grid/data_grid/renderers/render_context.dart';

/// Default row renderer implementation.
///
/// Renders rows with support for pinned columns, selection, and zebra striping.
class DefaultRowRenderer<T extends DataGridRow> extends RowRenderer<T> {
  final CellRenderer<T>? cellRenderer;

  const DefaultRowRenderer({this.cellRenderer});

  @override
  Widget buildRow(BuildContext context, T row, int index, RowRenderContext<T> renderContext) {
    final effectiveCellRenderer = cellRenderer ?? DefaultCellRenderer<T>();

    return GestureDetector(
      onTap: () {
        renderContext.controller.addEvent(SelectRowEvent(rowId: row.id, multiSelect: false));
      },
      child: Container(
        height: renderContext.rowHeight,
        decoration: BoxDecoration(
          color: renderContext.isSelected
              ? Colors.blue.withValues(alpha: 0.1)
              : (index % 2 == 0 ? Colors.white : Colors.grey[50]),
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Stack(
          children: [
            // Unpinned cells (responds to horizontal scroll)
            _buildUnpinnedCells(context, row, index, renderContext, effectiveCellRenderer),
            // Pinned cells (fixed position)
            if (renderContext.pinnedColumns.isNotEmpty)
              _buildPinnedCells(context, row, index, renderContext, effectiveCellRenderer),
          ],
        ),
      ),
    );
  }

  Widget _buildUnpinnedCells(
    BuildContext context,
    T row,
    int index,
    RowRenderContext<T> renderContext,
    CellRenderer<T> cellRenderer,
  ) {
    return Positioned(
      left: renderContext.pinnedWidth,
      right: 0,
      top: 0,
      bottom: 0,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(-renderContext.horizontalOffset, 0),
          child: SizedBox(
            width: renderContext.unpinnedWidth,
            height: renderContext.rowHeight,
            child: CustomMultiChildLayout(
              delegate: BodyLayoutDelegate(columns: renderContext.unpinnedColumns),
              children: [
                for (var column in renderContext.unpinnedColumns)
                  LayoutId(
                    id: column.id,
                    child: _buildCell(context, row, column, index, renderContext, cellRenderer, isPinned: false),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedCells(
    BuildContext context,
    T row,
    int index,
    RowRenderContext<T> renderContext,
    CellRenderer<T> cellRenderer,
  ) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: renderContext.pinnedWidth,
      child: Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey[400]!, width: 2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(2, 0))],
        ),
        child: CustomMultiChildLayout(
          delegate: BodyLayoutDelegate(columns: renderContext.pinnedColumns),
          children: [
            for (var column in renderContext.pinnedColumns)
              LayoutId(
                id: column.id,
                child: _buildCell(context, row, column, index, renderContext, cellRenderer, isPinned: true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    T row,
    DataGridColumn column,
    int index,
    RowRenderContext<T> renderContext,
    CellRenderer<T> cellRenderer, {
    required bool isPinned,
  }) {
    final cellContext = CellRenderContext<T>(
      controller: renderContext.controller,
      isSelected: renderContext.isSelected,
      isHovered: renderContext.isHovered,
      isPinned: isPinned,
      rowIndex: index,
      cellBuilder: renderContext.cellBuilder,
    );

    return cellRenderer.buildCell(context, row, column, index, cellContext);
  }
}
