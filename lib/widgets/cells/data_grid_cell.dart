import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/events/selection_events.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

class _CellState {
  final bool isSelected;
  final bool isEditing;
  final dynamic editingValue;

  _CellState(this.isSelected, this.isEditing, this.editingValue);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CellState &&
          isSelected == other.isSelected &&
          isEditing == other.isEditing &&
          editingValue == other.editingValue;

  @override
  int get hashCode => Object.hash(isSelected, isEditing, editingValue);
}

class DataGridCell<T extends DataGridRow> extends StatefulWidget {
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
    final controller = context.dataGridController<T>()!;

    return StreamBuilder<bool>(
      stream: controller.selection$
          .map((s) => s.isRowSelected(widget.rowId))
          .distinct(),
      initialData: controller.state.selection.isRowSelected(widget.rowId),
      builder: (context, selectionSnapshot) {
        final isSelected = selectionSnapshot.data ?? false;

        return StreamBuilder<_CellState>(
          stream: controller.state$
              .map(
                (state) => _CellState(
                  isSelected,
                  state.edit.isCellEditing(widget.rowId, widget.column.id),
                  state.edit.editingValue,
                ),
              )
              .distinct(),
          initialData: _CellState(
            isSelected,
            controller.state.edit.isCellEditing(widget.rowId, widget.column.id),
            controller.state.edit.editingValue,
          ),
          builder: (context, snapshot) {
            final cellState = snapshot.data!;
            final isEditing = cellState.isEditing;

            Widget cellContent;
            if (isEditing) {
              cellContent = _CellEditor<T>(
                column: widget.column,
                value: cellState.editingValue,
                editController: _editController,
                focusNode: _focusNode,
                onKeyPress: _handleKeyPress,
              );
            } else {
              final value = widget.column.valueAccessor?.call(widget.row);
              final displayText = value?.toString() ?? '';
              cellContent = Text(displayText, overflow: TextOverflow.ellipsis);
            }

            return Semantics(
              label:
                  'Cell row ${widget.rowIndex + 1} column ${widget.column.title}',
              value: isEditing ? 'Editing' : null,
              selected: isSelected,
              button: true,
              onTap: isEditing
                  ? null
                  : () {
                      if (controller.state.selection.mode !=
                          SelectionMode.none) {
                        final isMultiSelectMode =
                            controller.state.selection.mode ==
                            SelectionMode.multiple;
                        controller.addEvent(
                          SelectRowEvent(
                            rowId: widget.rowId,
                            multiSelect: isMultiSelectMode,
                          ),
                        );
                      }
                    },
              child: GestureDetector(
                onDoubleTap: () {
                  if (!isEditing && widget.column.editable) {
                    controller.startEditCell(widget.rowId, widget.column.id);
                  }
                },
                onTap: () {
                  if (isEditing) return;

                  if (controller.state.selection.mode != SelectionMode.none) {
                    final isMultiSelectMode =
                        controller.state.selection.mode ==
                        SelectionMode.multiple;
                    controller.addEvent(
                      SelectRowEvent(
                        rowId: widget.rowId,
                        multiSelect: isMultiSelectMode,
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colors.selectionColor
                        : (widget.rowIndex % 2 == 0
                              ? theme.colors.evenRowColor
                              : theme.colors.oddRowColor),
                    border: isEditing
                        ? theme.borders.editingBorder
                        : (widget.isPinned
                              ? theme.borders.pinnedBorder
                              : theme.borders.cellBorder),
                    boxShadow: widget.isPinned
                        ? theme.borders.pinnedShadow
                        : null,
                  ),
                  padding: isEditing
                      ? EdgeInsets.zero
                      : theme.padding.cellPadding,
                  alignment: isEditing
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: cellContent,
                ),
              ),
            );
          },
        );
      },
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
    widget.editController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.editController.text.length,
    );
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
