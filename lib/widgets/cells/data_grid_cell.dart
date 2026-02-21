import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/events/selection_events.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/renderers/render_context.dart';

/// Cell widget that caches its content across rebuilds.
/// Only re-calls the cell renderer when the row data, column, or selection
/// state for THIS cell actually changes. Unrelated state changes (e.g.
/// selection of a different row) reuse the cached content widget, allowing
/// Flutter to skip diffing the entire subtree.
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
  Widget? _cachedContent;
  bool _cachedIsSelected = false;
  Object? _cachedRow;
  Object? _cachedValue;

  @override
  void didUpdateWidget(covariant DataGridCell<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.column != widget.column || oldWidget.column.valueAccessor?.call(widget.row) != widget.column.valueAccessor?.call(oldWidget.row) ||
        oldWidget.rowIndex != widget.rowIndex ||
        oldWidget.isPinned != widget.isPinned) {
      _cachedContent = null;
      _cachedRow = null;
      _cachedValue = null;
    }
  }

  Widget _buildContent(
    BuildContext context,
    DataGridController<T> controller,
    bool isSelected,
  ) {
    final newValue = widget.column.valueAccessor?.call(widget.row);
    if (_cachedContent != null &&
        _cachedIsSelected == isSelected &&
        identical(_cachedRow, widget.row) &&
        _cachedValue == newValue) {
      return _cachedContent!;
    }
    _cachedRow = widget.row;
    _cachedValue = newValue;
    _cachedIsSelected = isSelected;

    if (widget.column.cellRenderer != null) {
      _cachedContent = widget.column.cellRenderer!.buildCell(
        context,
        widget.row,
        widget.column,
        widget.rowIndex,
        CellRenderContext<T>(
          controller: controller,
          isSelected: isSelected,
          isHovered: false,
          isPinned: widget.isPinned,
          rowIndex: widget.rowIndex,
        ),
      );
    } else {
      final theme = DataGridTheme.of(context);
      final value = widget.column.valueAccessor?.call(widget.row);
      _cachedContent = Padding(
        padding: theme.padding.cellPadding,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(value?.toString() ?? '', overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return _cachedContent!;
  }

  @override
  Widget build(BuildContext context) {
    // All InheritedWidget reads are inside the Builder so this element
    // has no dependencies and won't be marked dirty by ancestor changes.
    return Builder(builder: (innerContext) {
      final theme = DataGridTheme.of(innerContext);
      final controller = innerContext.dataGridController<T>()!;
      final state = controller.state;
      final isSelected = state.selection.isRowSelected(widget.rowId);
      final isEditing =
          state.edit.isCellEditing(widget.rowId, widget.column.id);

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

      final cellContent =
          _buildContent(innerContext, controller, isSelected);

      return _CellContainer(
        decoration: theme.cellDecorations.forCell(
          isEven: widget.rowIndex % 2 == 0,
          isSelected: isSelected,
          isPinned: widget.isPinned,
        ),
        onTap: state.selection.mode != SelectionMode.none
            ? () => controller.addEvent(
                  SelectRowEvent(
                    rowId: widget.rowId,
                    multiSelect:
                        state.selection.mode == SelectionMode.multiple,
                  ),
                )
            : null,
        onDoubleTap: widget.column.editable
            ? () => controller.startEditCell(
                widget.rowId, widget.column.id)
            : null,
        child: cellContent,
      );
    });
  }
}

/// Single render object that handles both decoration painting and tap/double-tap
/// gestures. Replaces GestureDetector + DecoratedBox with one element.
/// Decoration changes trigger markNeedsPaint only; callback changes are just
/// pointer swaps with zero framework cost.
class _CellContainer extends SingleChildRenderObjectWidget {
  final BoxDecoration decoration;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const _CellContainer({
    required this.decoration,
    this.onTap,
    this.onDoubleTap,
    super.child,
  });

  @override
  _RenderCellContainer createRenderObject(BuildContext context) {
    return _RenderCellContainer(
      decoration: decoration,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCellContainer renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..onTap = onTap
      ..onDoubleTap = onDoubleTap;
  }
}

class _RenderCellContainer extends RenderProxyBox {
  _RenderCellContainer({
    required BoxDecoration decoration,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
  })  : _decoration = decoration,
        _onTap = onTap,
        _onDoubleTap = onDoubleTap;

  BoxDecoration _decoration;
  BoxPainter? _painter;

  set decoration(BoxDecoration value) {
    if (identical(_decoration, value)) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;
    markNeedsPaint();
  }

  VoidCallback? _onTap;
  set onTap(VoidCallback? value) {
    _onTap = value;
    _tapRecognizer?.onTap = value;
  }

  VoidCallback? _onDoubleTap;
  set onDoubleTap(VoidCallback? value) {
    _onDoubleTap = value;
    _doubleTapRecognizer?.onDoubleTap = value;
  }

  TapGestureRecognizer? _tapRecognizer;
  DoubleTapGestureRecognizer? _doubleTapRecognizer;

  @override
  bool hitTestSelf(Offset position) =>
      _onTap != null || _onDoubleTap != null;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      if (_onDoubleTap != null) {
        _doubleTapRecognizer ??= DoubleTapGestureRecognizer()
          ..onDoubleTap = _onDoubleTap;
        _doubleTapRecognizer!.addPointer(event);
      }
      if (_onTap != null) {
        _tapRecognizer ??= TapGestureRecognizer()
          ..onTap = _onTap;
        _tapRecognizer!.addPointer(event);
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _painter ??= _decoration.createBoxPainter(markNeedsPaint);
    _painter!.paint(
      context.canvas,
      offset,
      ImageConfiguration(size: size),
    );
    super.paint(context, offset);
  }

  @override
  void dispose() {
    _painter?.dispose();
    _tapRecognizer?.dispose();
    _doubleTapRecognizer?.dispose();
    super.dispose();
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
      controller.updateCellEditValue(_editController.text);
      controller.commitCellEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.rowIndex % 2 == 0
            ? theme.colors.evenRowColor
            : theme.colors.oddRowColor,
        border: theme.borders.editingBorder,
      ),
      alignment: Alignment.center,
      child: _CellEditor<T>(
        column: widget.column,
        value: widget.editingValue,
        editController: _editController,
        focusNode: _focusNode,
      ),
    );
  }
}

class _CellEditor<T extends DataGridRow> extends StatefulWidget {
  final DataGridColumn<T> column;
  final dynamic value;
  final TextEditingController editController;
  final FocusNode focusNode;

  const _CellEditor({
    required this.column,
    required this.value,
    required this.editController,
    required this.focusNode,
  });

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
    widget.editController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.editController.text.length,
    );
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
      return widget.column.cellEditorBuilder!(
        context,
        widget.value,
        (newValue) => controller.updateCellEditValue(newValue),
      );
    }

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          controller.cancelCellEdit();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        key: const ValueKey('cell_editor_textfield'),
        controller: widget.editController,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: theme.padding.editorPadding,
          isDense: true,
        ),
        onSubmitted: (_) => _commitEdit(controller),
      ),
    );
  }
}
