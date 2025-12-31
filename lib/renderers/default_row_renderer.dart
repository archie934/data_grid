import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/delegates/body_layout_delegate.dart';
import 'package:flutter_data_grid/renderers/row_renderer.dart';
import 'package:flutter_data_grid/renderers/render_context.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_cell.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_checkbox_cell.dart';
import 'package:flutter_data_grid/widgets/visible_row_tracker.dart';

class DefaultRowRenderer<T extends DataGridRow> extends RowRenderer<T> {
  const DefaultRowRenderer();

  @override
  Widget buildRow(
    BuildContext context,
    T row,
    int index,
    RowRenderContext<T> renderContext,
  ) {
    return VisibleRowTracker<T>(
      rowId: row.id,
      rowIndex: index,
      rowHeight: renderContext.rowHeight,
      controller: renderContext.controller,
      child: SizedBox(
        height: renderContext.rowHeight,
        child: Stack(
          children: [
            _UnpinnedCells<T>(
              row: row,
              index: index,
              renderContext: renderContext,
            ),
            if (renderContext.pinnedColumns.isNotEmpty)
              _PinnedCells<T>(
                row: row,
                index: index,
                renderContext: renderContext,
              ),
          ],
        ),
      ),
    );
  }
}

class _UnpinnedCells<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final int index;
  final RowRenderContext<T> renderContext;

  const _UnpinnedCells({
    required this.row,
    required this.index,
    required this.renderContext,
  });

  @override
  Widget build(BuildContext context) {
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
              delegate: BodyLayoutDelegate<T>(
                columns: renderContext.unpinnedColumns,
              ),
              children: [
                for (var column in renderContext.unpinnedColumns)
                  LayoutId(
                    id: column.id,
                    child: _RendererCell<T>(
                      row: row,
                      column: column,
                      index: index,
                      isPinned: false,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinnedCells<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final int index;
  final RowRenderContext<T> renderContext;

  const _PinnedCells({
    required this.row,
    required this.index,
    required this.renderContext,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: renderContext.pinnedWidth,
      child: CustomMultiChildLayout(
        delegate: BodyLayoutDelegate<T>(columns: renderContext.pinnedColumns),
        children: [
          for (var column in renderContext.pinnedColumns)
            LayoutId(
              id: column.id,
              child: _RendererCell<T>(
                row: row,
                column: column,
                index: index,
                isPinned: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _RendererCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final DataGridColumn<T> column;
  final int index;
  final bool isPinned;

  const _RendererCell({
    required this.row,
    required this.column,
    required this.index,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    if (column.id == kSelectionColumnId) {
      return DataGridCheckboxCell<T>(row: row, rowId: row.id, rowIndex: index);
    }

    return DataGridCell<T>(
      row: row,
      rowId: row.id,
      column: column,
      rowIndex: index,
      isPinned: isPinned,
    );
  }
}
