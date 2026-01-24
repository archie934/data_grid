import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/events/selection_events.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/renderers/render_context.dart';

/// Optimized cell widget - uses StatelessWidget for display, StatefulWidget only for editing
class DataGridCell<T extends DataGridRow> extends StatelessWidget {
  final T row;
  final double rowId;
  final DataGridColumn<T> column;
  final int rowIndex;
  final bool isPinned;

  const DataGridCell({
    super.key,
    required this.row,
    required this.rowId,
    required this.column,
    required this.rowIndex,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;
    final state = controller.state;
    final isSelected = state.selection.isRowSelected(rowId);
    final isEditing = state.edit.isCellEditing(rowId, column.id);

    // Use editing widget only when actually editing
    if (isEditing) {
      return _EditingCell<T>(
        row: row,
        rowId: rowId,
        column: column,
        rowIndex: rowIndex,
        isPinned: isPinned,
        editingValue: state.edit.editingValue,
      );
    }

    final bgColor = isSelected
        ? theme.colors.selectionColor
        : (rowIndex % 2 == 0 ? theme.colors.evenRowColor : theme.colors.oddRowColor);

    Widget cellContent;

    if (column.cellRenderer != null) {
      final renderContext = CellRenderContext<T>(
        controller: controller,
        isSelected: isSelected,
        isHovered: false,
        isPinned: isPinned,
        rowIndex: rowIndex,
      );
      cellContent = column.cellRenderer!.buildCell(context, row, column, rowIndex, renderContext);
    } else {
      final value = column.valueAccessor?.call(row);
      final displayText = value?.toString() ?? '';
      cellContent = Padding(
        padding: theme.padding.cellPadding,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(displayText, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: column.editable ? () => controller.startEditCell(rowId, column.id) : null,
      onTap: state.selection.mode != SelectionMode.none
          ? () => controller.addEvent(
              SelectRowEvent(rowId: rowId, multiSelect: state.selection.mode == SelectionMode.multiple),
            )
          : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          border: isPinned ? theme.borders.pinnedBorder : theme.borders.cellBorder,
          boxShadow: isPinned ? theme.borders.pinnedShadow : null,
        ),
        child: cellContent,
      ),
    );
  }
}

/// Editing cell - only created when cell is being edited
class _EditingCell<T extends DataGridRow> extends StatefulWidget {
  final T row;
  final double rowId;
  final DataGridColumn<T> column;
  final int rowIndex;
  final bool isPinned;
  final dynamic editingValue;

  const _EditingCell({
    required this.row,
    required this.rowId,
    required this.column,
    required this.rowIndex,
    required this.isPinned,
    required this.editingValue,
  });

  @override
  State<_EditingCell<T>> createState() => _EditingCellState<T>();
}

class _EditingCellState<T extends DataGridRow> extends State<_EditingCell<T>> {
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
    final controller = context.dataGridController<T>();
    if (controller != null &&
        !_focusNode.hasFocus &&
        controller.state.edit.isCellEditing(widget.rowId, widget.column.id)) {
      controller.commitCellEdit();
    }
  }

  void _handleKeyPress(KeyEvent event) {
    final controller = context.dataGridController<T>();
    if (controller != null && event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        controller.commitCellEdit();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        controller.cancelCellEdit();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.rowIndex % 2 == 0 ? theme.colors.evenRowColor : theme.colors.oddRowColor,
        border: theme.borders.editingBorder,
      ),
      alignment: Alignment.center,
      child: _CellEditor<T>(
        column: widget.column,
        value: widget.editingValue,
        editController: _editController,
        focusNode: _focusNode,
        onKeyPress: _handleKeyPress,
      ),
    );
  }
}

class _CellEditor<T extends DataGridRow> extends StatefulWidget {
  final DataGridColumn<T> column;
  final dynamic value;
  final TextEditingController editController;
  final FocusNode focusNode;
  final void Function(KeyEvent) onKeyPress;

  const _CellEditor({
    required this.column,
    required this.value,
    required this.editController,
    required this.focusNode,
    required this.onKeyPress,
  });

  @override
  State<_CellEditor<T>> createState() => _CellEditorState<T>();
}

class _CellEditorState<T extends DataGridRow> extends State<_CellEditor<T>> {
  late final FocusNode _keyboardListenerFocusNode;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _keyboardListenerFocusNode = FocusNode();
    _initializeController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.focusNode.requestFocus();
      }
    });
  }

  void _initializeController() {
    if (_initialized) return;
    widget.editController.text = widget.value?.toString() ?? '';
    widget.editController.selection = TextSelection(baseOffset: 0, extentOffset: widget.editController.text.length);
    _initialized = true;
  }

  @override
  void dispose() {
    _keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;

    if (widget.column.cellEditorBuilder != null) {
      return widget.column.cellEditorBuilder!(
        context,
        widget.value,
        (newValue) => controller.updateCellEditValue(newValue),
      );
    }

    return KeyboardListener(
      focusNode: _keyboardListenerFocusNode,
      onKeyEvent: widget.onKeyPress,
      child: TextField(
        key: const ValueKey('cell_editor_textfield'),
        controller: widget.editController,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: theme.padding.editorPadding,
          isDense: true,
        ),
        onChanged: (newValue) => controller.updateCellEditValue(newValue),
      ),
    );
  }
}
