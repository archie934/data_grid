import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/cell_selection_events.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/widgets/cells/cell_scope.dart';

/// Snapshot of the selection/edit state that is specific to one cell.
/// Used to gate rebuilds: only when THIS cell's derived state changes
/// does [_DataGridCellState] call [setState].
class _CellDisplayState {
  final bool isSelected;
  final bool isEditing;
  final bool isCellInPath;
  final bool isCellActive;

  const _CellDisplayState({
    required this.isSelected,
    required this.isEditing,
    required this.isCellInPath,
    required this.isCellActive,
  });

  factory _CellDisplayState.from(
    DataGridState state,
    double rowId,
    int columnId,
    String cellId, // pre-computed to avoid per-update string allocation
  ) {
    final focused = state.selection.focusedCells;
    return _CellDisplayState(
      isSelected: state.selection.isRowSelected(rowId),
      isEditing: state.edit.isCellEditing(rowId, columnId),
      // Use the list directly rather than going through isCellFocused() so the
      // pre-computed cellId string is reused rather than recreated each time.
      isCellInPath: focused.contains(cellId),
      isCellActive: focused.isNotEmpty && focused.last == cellId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _CellDisplayState &&
      isSelected == other.isSelected &&
      isEditing == other.isEditing &&
      isCellInPath == other.isCellInPath &&
      isCellActive == other.isCellActive;

  @override
  int get hashCode =>
      Object.hash(isSelected, isEditing, isCellInPath, isCellActive);
}

/// Cell widget whose content is always a stable widget instance wrapped in
/// [CellScope]. The child widget (either [DataGridColumn.cellWidget] or the
/// built-in [_DefaultTextCell]) is created once and never changes identity,
/// so Flutter preserves the entire element subtree across rebuilds.
///
/// Selection and edit state are tracked via a row/cell-scoped stream
/// subscription so only the cells belonging to the affected row rebuild
/// when selection or edit state changes.
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

  StreamSubscription<_CellDisplayState>? _subscription;
  DataGridController<T>? _subscribedController;
  late _CellDisplayState _displayState;
  // Cached cell ID string — computed once, reused on every state update to
  // avoid allocating a new String object for every visible cell per update.
  late String _cellId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.dataGridController<T>();
    if (!identical(controller, _subscribedController)) {
      _cancelSubscription();
      _subscribedController = controller;
      if (controller != null) {
        _cellId = '${widget.rowId}_${widget.column.id}';
        _displayState = _CellDisplayState.from(
          controller.state,
          widget.rowId,
          widget.column.id,
          _cellId,
        );
        _subscribe(controller);
      }
    }
  }

  @override
  void didUpdateWidget(covariant DataGridCell<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.column.cellWidget, widget.column.cellWidget)) {
      _cellWidget = widget.column.cellWidget ?? _DefaultTextCell<T>();
    }
    // Re-subscribe if the cell now represents a different row or column.
    // With ValueKey this shouldn't happen, but guard defensively.
    if (oldWidget.rowId != widget.rowId ||
        oldWidget.column.id != widget.column.id) {
      final controller = _subscribedController;
      if (controller != null) {
        _cancelSubscription();
        _cellId = '${widget.rowId}_${widget.column.id}';
        _displayState = _CellDisplayState.from(
          controller.state,
          widget.rowId,
          widget.column.id,
          _cellId,
        );
        _subscribe(controller);
      }
    }
  }

  void _subscribe(DataGridController<T> controller) {
    final cellId = _cellId;
    _subscription = controller.state$
        .map((s) => _CellDisplayState.from(
              s,
              widget.rowId,
              widget.column.id,
              cellId,
            ))
        .distinct()
        .skip(
          1,
        ) // Skip the BehaviorSubject seed — _displayState is already set from controller.state
        .listen((ds) {
          if (mounted) setState(() => _displayState = ds);
        });
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    // Reading controller via DataGridControllerScope never triggers a rebuild
    // on state changes — it only rebuilds if the controller reference itself
    // is replaced, which never happens in normal usage.
    final controller = context.dataGridController<T>()!;
    final ds = _displayState;

    if (ds.isEditing) {
      // Read editingValue directly from the synchronous BehaviorSubject value
      // rather than tracking it in _CellDisplayState, so that typing into the
      // editor does not cause extra cell rebuilds.
      // Fall back to _lastDisplayedValue when editingValue is null (i.e. the
      // state was seeded without calling valueAccessor in the event handler).
      final editingValue = _subscribedController!.state.edit.editingValue;
      return _EditingCell<T>(
        row: widget.row,
        rowId: widget.rowId,
        column: widget.column,
        rowIndex: widget.rowIndex,
        isPinned: widget.isPinned,
        editingValue: editingValue,
      );
    }

    final value = widget.column.valueAccessor?.call(widget.row);

    final isEven = widget.rowIndex % 2 == 0;
    final decoration = (ds.isCellInPath || ds.isCellActive)
        ? theme.cellDecorations.forFocusedCell(
            isEven: isEven,
            isPinned: widget.isPinned,
            isInPath: ds.isCellInPath,
            isActive: ds.isCellActive,
          )
        : theme.cellDecorations.forCell(
            isEven: isEven,
            isSelected: ds.isSelected,
            isPinned: widget.isPinned,
          );

    return _CellContainer(
      decoration: decoration,
      onTap: () {
        // Commit any in-progress edit before changing cell focus.
        // Safe: _onFocusChange's isCellEditing guard prevents double-commit.
        if (controller.state.edit.isEditing) {
          controller.commitCellEdit();
        }

        // Reclaim keyboard focus for the grid on every cell tap.
        // On WASM web, GestureDetector taps do not move Flutter focus, so
        // arrow-key navigation breaks unless we explicitly request it here.
        context.dataGridFocusNode<T>()?.requestFocus();

        final isShift = HardwareKeyboard.instance.isShiftPressed;
        final isCtrl = HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed;
        if (isShift) {
          controller.addEvent(
            ShiftSelectCellEvent(
              rowId: widget.rowId,
              columnId: widget.column.id,
            ),
          );
        } else if (isCtrl) {
          controller.addEvent(
            ToggleCellInSelectionEvent(
              rowId: widget.rowId,
              columnId: widget.column.id,
            ),
          );
        } else {
          controller.addEvent(
            FocusCellEvent(rowId: widget.rowId, columnId: widget.column.id),
          );
        }
      },
      onDoubleTap: widget.column.editable
          ? () => controller.startEditCell(widget.rowId, widget.column.id)
          : null,
      child: CellScope<T>(
        row: widget.row,
        column: widget.column,
        rowIndex: widget.rowIndex,
        isSelected: ds.isSelected,
        isPinned: widget.isPinned,
        value: value,
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
        child: Text(
          scope.value?.toString() ?? '',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CellContainer extends StatelessWidget {
  final BoxDecoration decoration;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Widget? child;

  const _CellContainer({
    required this.decoration,
    this.onTap,
    this.onDoubleTap,
    this.child,
  });

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
        onChanged: (text) => controller.updateCellEditValue(text),
        onSubmitted: (_) => _commitEdit(controller),
      ),
    );
  }
}
