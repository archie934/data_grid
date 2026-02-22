import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/events/selection_events.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/widgets/cells/cell_scope.dart';

/// Cell widget whose content is always a stable widget instance wrapped in
/// [CellScope]. The child widget (either [DataGridColumn.cellWidget] or the
/// built-in [_DefaultTextCell]) is created once and never changes identity,
/// so Flutter preserves the entire element subtree across rebuilds.
/// [CellScope.updateShouldNotify] gates descendant rebuilds when the
/// underlying row data or selection state changes.
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
  late Widget _cellWidget = widget.column.cellWidget ?? _DefaultTextCell<T>();

  @override
  void didUpdateWidget(covariant DataGridCell<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.column.cellWidget, widget.column.cellWidget)) {
      _cellWidget = widget.column.cellWidget ?? _DefaultTextCell<T>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;
    final state = context.dataGridState<T>({DataGridAspect.selection, DataGridAspect.edit})!;
    final isSelected = state.selection.isRowSelected(widget.rowId);
    final isEditing = state.edit.isCellEditing(widget.rowId, widget.column.id);

    if (isEditing) {
      return _EditingCell<T>(
        row: widget.row,
        rowId: widget.rowId,
        column: widget.column,
        rowIndex: widget.rowIndex,
        isPinned: widget.isPinned,
        editingValue: state.edit.editingValue,
      );
    }

    return _CellContainer(
      decoration: theme.cellDecorations.forCell(
        isEven: widget.rowIndex % 2 == 0,
        isSelected: isSelected,
        isPinned: widget.isPinned,
      ),
      onTap: state.selection.mode != SelectionMode.none
          ? () => controller.addEvent(SelectRowEvent(
                rowId: widget.rowId,
                multiSelect: state.selection.mode == SelectionMode.multiple,
              ))
          : null,
      onDoubleTap: widget.column.editable
          ? () => controller.startEditCell(widget.rowId, widget.column.id)
          : null,
      child: CellScope<T>(
        row: widget.row,
        column: widget.column,
        rowIndex: widget.rowIndex,
        isSelected: isSelected,
        isPinned: widget.isPinned,
        value: widget.column.valueAccessor?.call(widget.row),
        controller: controller,
        child: _cellWidget,
      ),
    );
  }
}

/// Built-in cell content for columns without a [DataGridColumn.cellWidget].
/// Created once per cell and stored in [_DataGridCellState], so the same
/// instance is reused across every rebuild. Reads display data from [CellScope].
class _DefaultTextCell<T extends DataGridRow> extends StatelessWidget {
  const _DefaultTextCell();

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<T>(context);
    final theme = DataGridTheme.of(context);

    return Padding(
      padding: theme.padding.cellPadding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(scope.value?.toString() ?? '', overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _CellContainer extends StatelessWidget {
  final BoxDecoration decoration;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Widget? child;

  const _CellContainer({required this.decoration, this.onTap, this.onDoubleTap, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: DecoratedBox(decoration: decoration, child: child),
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

  const _EditingCell({required this.row, required this.rowId, required this.column, required this.rowIndex, required this.isPinned, required this.editingValue});

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
    if (controller != null && !_focusNode.hasFocus && controller.state.edit.isCellEditing(widget.rowId, widget.column.id)) {
      controller.updateCellEditValue(_editController.text);
      controller.commitCellEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);

    return Container(
      decoration: BoxDecoration(color: widget.rowIndex % 2 == 0 ? theme.colors.evenRowColor : theme.colors.oddRowColor, border: theme.borders.editingBorder),
      alignment: Alignment.center,
      child: _CellEditor<T>(column: widget.column, value: widget.editingValue, editController: _editController, focusNode: _focusNode),
    );
  }
}

class _CellEditor<T extends DataGridRow> extends StatefulWidget {
  final DataGridColumn<T> column;
  final dynamic value;
  final TextEditingController editController;
  final FocusNode focusNode;

  const _CellEditor({required this.column, required this.value, required this.editController, required this.focusNode});

  @override
  State<_CellEditor<T>> createState() => _CellEditorState<T>();
}

class _CellEditorState<T extends DataGridRow> extends State<_CellEditor<T>> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
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

  void _commitEdit(DataGridController<T> controller) {
    controller.updateCellEditValue(widget.editController.text);
    controller.commitCellEdit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final controller = context.dataGridController<T>()!;

    if (widget.column.cellEditorBuilder != null) {
      return widget.column.cellEditorBuilder!(context, widget.value, (newValue) => controller.updateCellEditValue(newValue));
    }

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          controller.cancelCellEdit();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        key: const ValueKey('cell_editor_textfield'),
        controller: widget.editController,
        focusNode: widget.focusNode,
        decoration: InputDecoration(border: InputBorder.none, contentPadding: theme.padding.editorPadding, isDense: true),
        onSubmitted: (_) => _commitEdit(controller),
      ),
    );
  }
}
