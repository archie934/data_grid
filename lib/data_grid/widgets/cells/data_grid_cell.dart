import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_grid/data_grid/controller/data_grid_controller.dart';
import 'package:data_grid/data_grid/models/data/row.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/models/events/selection_events.dart';
import 'package:data_grid/data_grid/models/state/grid_state.dart';

class DataGridCell<T extends DataGridRow> extends StatefulWidget {
  final T row;
  final double rowId;
  final DataGridColumn column;
  final int rowIndex;
  final DataGridController<T> controller;
  final Widget Function(T row, int columnId)? cellBuilder;

  const DataGridCell({
    super.key,
    required this.row,
    required this.rowId,
    required this.column,
    required this.rowIndex,
    required this.controller,
    this.cellBuilder,
  });

  @override
  State<DataGridCell<T>> createState() => _DataGridCellState<T>();
}

class _DataGridCellState<T extends DataGridRow> extends State<DataGridCell<T>> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.controller.state.edit.isCellEditing(widget.rowId, widget.column.id)) {
      widget.controller.commitCellEdit();
    }
  }

  void _handleDoubleTap() {
    if (widget.column.editable) {
      widget.controller.startEditCell(widget.rowId, widget.column.id);
    }
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        widget.controller.commitCellEdit();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.controller.cancelCellEdit();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DataGridState<T>>(
      stream: widget.controller.state$,
      initialData: widget.controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final isSelected = state.selection.isRowSelected(widget.rowId);
        final isEditing = state.edit.isCellEditing(widget.rowId, widget.column.id);

        Widget cellContent;
        if (isEditing) {
          cellContent = _CellEditor<T>(
            column: widget.column,
            controller: widget.controller,
            value: state.edit.editingValue,
            editController: _editController,
            focusNode: _focusNode,
            onKeyPress: _handleKeyPress,
          );
        } else {
          cellContent = widget.cellBuilder != null
              ? widget.cellBuilder!(widget.row, widget.column.id)
              : Text('Row ${widget.row.id}, Col ${widget.column.id}', overflow: TextOverflow.ellipsis);
        }

        return GestureDetector(
          onTap: () {
            widget.controller.addEvent(SelectRowEvent(rowId: widget.rowId, multiSelect: false));
          },
          onDoubleTap: _handleDoubleTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : (widget.rowIndex % 2 == 0 ? Colors.white : Colors.grey[50]),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            padding: isEditing ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: isEditing ? Alignment.center : Alignment.centerLeft,
            child: cellContent,
          ),
        );
      },
    );
  }
}

class _CellEditor<T extends DataGridRow> extends StatelessWidget {
  final DataGridColumn column;
  final DataGridController<T> controller;
  final dynamic value;
  final TextEditingController editController;
  final FocusNode focusNode;
  final void Function(KeyEvent) onKeyPress;

  const _CellEditor({
    required this.column,
    required this.controller,
    required this.value,
    required this.editController,
    required this.focusNode,
    required this.onKeyPress,
  });

  @override
  Widget build(BuildContext context) {
    if (column.cellEditorBuilder != null) {
      return column.cellEditorBuilder!(context, value, (newValue) => controller.updateCellEditValue(newValue));
    }

    editController.text = value?.toString() ?? '';
    editController.selection = TextSelection(baseOffset: 0, extentOffset: editController.text.length);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyPress,
      child: TextField(
        controller: editController,
        focusNode: focusNode,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
        ),
        onChanged: (newValue) => controller.updateCellEditValue(newValue),
      ),
    );
  }
}
