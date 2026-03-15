part of 'custom_layout_grid_body.dart';

/// Minimal column descriptor used by the drag-selection coordinate converter.
class _VisualColumn {
  final int colId;
  final double width;
  final bool pinned;
  const _VisualColumn({
    required this.colId,
    required this.width,
    required this.pinned,
  });
}

class _DragSelectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  const _DragSelectionPainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, end);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_DragSelectionPainter old) =>
      old.start != start || old.end != end || old.color != color;
}

mixin _GridBodyDragSelectMixin<T extends DataGridRow>
    on State<CustomLayoutGridBody<T>>, _GridBodyScrollMixin<T> {
  // -- Drag-select state (right-click rectangle) ----------------------------
  bool _isDragSelecting = false;
  Offset? _dragSelectStart;
  Offset? _dragSelectCurrent;

  // -- Layout cache (written in build, read by pointer handlers) ------------
  List<_VisualColumn> _visualColumns = const [];
  double _cachedPinnedWidth = 0;
  List<double> _cachedDisplayOrder = const [];

  // -- Layout cache update --------------------------------------------------

  void _updateLayoutCache(
    List<DataGridColumn<T>> columns,
    List<double> displayOrder,
    double pinnedWidth,
  ) {
    _cachedPinnedWidth = pinnedWidth;
    _cachedDisplayOrder = displayOrder;
    _visualColumns = [
      for (final col in columns.where((c) => c.visible && c.pinned))
        _VisualColumn(colId: col.id, width: col.width, pinned: true),
      for (final col in columns.where((c) => c.visible && !c.pinned))
        _VisualColumn(colId: col.id, width: col.width, pinned: false),
    ];
  }

  // -- Drag-select helpers --------------------------------------------------

  /// Converts a local pixel position to (rowIdx, colIdx in _visualColumns).
  /// Returns null if layout cache is empty.
  ({int rowIdx, int colIdx})? _localToCell(Offset local) {
    final order = _cachedDisplayOrder;
    final vcols = _visualColumns;
    if (order.isEmpty || vcols.isEmpty) return null;

    int rowIdx = ((local.dy + _vOffset.value) / widget.rowHeight).floor();
    rowIdx = rowIdx.clamp(0, order.length - 1);

    final x = local.dx;
    int colIdx;
    if (x < _cachedPinnedWidth) {
      // Pinned zone — walk pinned columns from x=0
      double cum = 0;
      colIdx = 0;
      for (int i = 0; i < vcols.length; i++) {
        if (!vcols[i].pinned) continue;
        cum += vcols[i].width;
        colIdx = i;
        if (x < cum) break;
      }
    } else {
      // Unpinned zone — offset by pinnedWidth and hScroll
      final unpinnedX = x - _cachedPinnedWidth + _hOffset.value;
      double cum = 0;
      colIdx = vcols.indexWhere((c) => !c.pinned);
      if (colIdx == -1) colIdx = vcols.length - 1;
      for (int i = 0; i < vcols.length; i++) {
        if (vcols[i].pinned) continue;
        cum += vcols[i].width;
        colIdx = i;
        if (unpinnedX < cum) break;
      }
    }

    return (rowIdx: rowIdx, colIdx: colIdx.clamp(0, vcols.length - 1));
  }

  void _commitDragSelection(Offset endLocal) {
    final startCell = _localToCell(_dragSelectStart!);
    final endCell = _localToCell(endLocal);
    if (startCell == null || endCell == null) return;

    final controller = context.dataGridController<T>();
    if (controller == null) return;

    final vcols = _visualColumns;
    final order = _cachedDisplayOrder;

    final minRow = math.min(startCell.rowIdx, endCell.rowIdx);
    final maxRow = math.max(startCell.rowIdx, endCell.rowIdx);
    final minCol = math.min(startCell.colIdx, endCell.colIdx);
    final maxCol = math.max(startCell.colIdx, endCell.colIdx);

    final cells = <String>[];
    for (int r = minRow; r <= maxRow; r++) {
      final rowId = order[r];
      for (int c = minCol; c <= maxCol; c++) {
        cells.add('${rowId}_${vcols[c].colId}');
      }
    }

    if (cells.isNotEmpty) {
      controller.addEvent(SetFocusedCellsEvent(cells));
    }
  }

  // -- Pointer handlers (drag-select) ---------------------------------------

  void _dragSelectPointerDown(PointerDownEvent event) {
    setState(() {
      _isDragSelecting = true;
      _dragSelectStart = event.localPosition;
      _dragSelectCurrent = event.localPosition;
    });
  }

  void _dragSelectPointerMove(PointerMoveEvent event) {
    setState(() => _dragSelectCurrent = event.localPosition);
  }

  void _dragSelectPointerUp(PointerUpEvent event) {
    _commitDragSelection(event.localPosition);
    setState(() {
      _isDragSelecting = false;
      _dragSelectStart = null;
      _dragSelectCurrent = null;
    });
  }

  void _dragSelectPointerCancel(PointerCancelEvent event) {
    setState(() {
      _isDragSelecting = false;
      _dragSelectStart = null;
      _dragSelectCurrent = null;
    });
  }
}
