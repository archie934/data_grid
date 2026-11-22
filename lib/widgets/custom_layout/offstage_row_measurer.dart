import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/custom_layout/grid_layout_delegate.dart';
import 'package:flutter_data_grid/widgets/custom_layout/layout_grid_cell.dart';

/// Measures rows near the viewport in an [Offstage] layer while scrolling is
/// idle, so they already have real heights by the time they scroll in.
///
/// Works in small batches: a batch is picked only once the vertical offset has
/// been still for [_idleDelay] (so any drag, fling, thumb drag or wheel scroll
/// pauses it), then one batch per frame until the look-ahead window is fully
/// measured. Heights are
/// reported through the same [RowHeightMeasurement.onMeasured] hook the
/// quadrants use, so they're batched, clamped and offset-corrected there.
///
/// Every visible column is measured (pinned and unpinned), so a tall cell in a
/// horizontally off-screen column still counts toward its row's height.
class OffstageRowMeasurer<T extends DataGridRow> extends StatefulWidget {
  const OffstageRowMeasurer({
    super.key,
    required this.columns,
    required this.columnIndices,
    required this.rows,
    required this.rowsById,
    required this.measurement,
    required this.vOffset,
    required this.viewportHeight,
    required this.measureAheadExtent,
  });

  final List<DataGridColumn<T>> columns;

  /// Indices into [columns] of every visible column.
  final List<int> columnIndices;
  final List<GridDisplayRow<T>> rows;
  final Map<double, T> rowsById;
  final RowHeightMeasurement measurement;
  final ValueNotifier<double> vOffset;
  final double viewportHeight;

  /// How far above and below the viewport (in pixels) rows are measured.
  final double measureAheadExtent;

  @override
  State<OffstageRowMeasurer<T>> createState() => _OffstageRowMeasurerState<T>();
}

class _OffstageRowMeasurerState<T extends DataGridRow>
    extends State<OffstageRowMeasurer<T>> {
  static const _idleDelay = Duration(milliseconds: 150);
  static const _cellsPerBatch = 120;

  Timer? _idleTimer;
  double _lastOffset = 0;
  bool _scrollingDown = true;
  Timer? _batchTimer;
  List<int> _batch = const [];

  @override
  void initState() {
    super.initState();
    _lastOffset = widget.vOffset.value;
    widget.vOffset.addListener(_onOffsetChanged);
    _scheduleNextBatch();
  }

  @override
  void didUpdateWidget(OffstageRowMeasurer<T> old) {
    super.didUpdateWidget(old);
    if (!identical(old.vOffset, widget.vOffset)) {
      old.vOffset.removeListener(_onOffsetChanged);
      widget.vOffset.addListener(_onOffsetChanged);
    }
    if (!identical(old.rows, widget.rows) ||
        !identical(old.rowsById, widget.rowsById) ||
        !identical(old.columns, widget.columns)) {
      // Row indices in the old batch may now point at different rows.
      _batch = const [];
      _scheduleNextBatch();
    }
  }

  @override
  void dispose() {
    widget.vOffset.removeListener(_onOffsetChanged);
    _idleTimer?.cancel();
    _batchTimer?.cancel();
    super.dispose();
  }

  void _onOffsetChanged() {
    final offset = widget.vOffset.value;
    if (offset != _lastOffset) _scrollingDown = offset > _lastOffset;
    _lastOffset = offset;
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleDelay, () {
      _idleTimer = null;
      _scheduleNextBatch();
    });
  }

  // A zero-duration Timer rather than SchedulerBinding.scheduleTask: an
  // idle-priority task re-arms a zero-duration timer every event-loop turn
  // while any animation runs, which busy-spins (and hangs fake-async tests).
  void _scheduleNextBatch() {
    if (_batchTimer != null) return;
    _batchTimer = Timer(Duration.zero, _pickNextBatch);
  }

  void _pickNextBatch() {
    _batchTimer = null;
    if (!mounted || _idleTimer != null) return;

    final next = _collectBatch();
    // Same rows still unmeasured after a full pass (e.g. a custom delegate
    // that never flags them): stop instead of re-measuring forever.
    if (listEquals(next, _batch)) return;
    setState(() => _batch = next);
  }

  List<int> _collectBatch() {
    final rows = widget.rows;
    final delegate = widget.measurement.delegate;
    if (rows.isEmpty || widget.columnIndices.isEmpty) return const [];

    final maxRows = math.max(1, _cellsPerBatch ~/ widget.columnIndices.length);
    final top = widget.vOffset.value;
    final bottom = top + widget.viewportHeight;
    final extent = widget.measureAheadExtent;

    final first = delegate.indexAtOffset(top);
    final last = math.min(rows.length - 1, delegate.indexAtOffset(bottom));
    final aheadEnd = math.min(
      rows.length - 1,
      delegate.indexAtOffset(bottom + extent),
    );
    final behindStart = delegate.indexAtOffset(math.max(0.0, top - extent));

    final batch = <int>[];
    bool take(int i) {
      final entry = rows[i];
      if (entry is GridDataRow<T> &&
          widget.rowsById.containsKey(entry.rowId) &&
          !delegate.isMeasured(i)) {
        batch.add(i);
      }
      return batch.length >= maxRows;
    }

    if (_scrollingDown) {
      for (int i = first; i <= aheadEnd; i++) {
        if (take(i)) return batch;
      }
      for (int i = first - 1; i >= behindStart; i--) {
        if (take(i)) return batch;
      }
    } else {
      for (int i = last; i >= behindStart; i--) {
        if (take(i)) return batch;
      }
      for (int i = last + 1; i <= aheadEnd; i++) {
        if (take(i)) return batch;
      }
    }
    return batch;
  }

  @override
  Widget build(BuildContext context) {
    if (_batch.isEmpty) return const SizedBox.shrink();

    final cells = <(CellLayoutId, double)>[];
    final children = <Widget>[];
    for (final row in _batch) {
      final entry = widget.rows[row] as GridDataRow<T>;
      final rowData = widget.rowsById[entry.rowId]!;
      for (final colIndex in widget.columnIndices) {
        final column = widget.columns[colIndex];
        final id = CellLayoutId(row, colIndex);
        cells.add((id, column.width));
        children.add(
          LayoutId(
            id: id,
            child: LayoutGridCell<T>(
              row: rowData,
              rowId: entry.rowId,
              column: column,
              rowIndex: row,
            ),
          ),
        );
      }
    }

    // The timer fires from the event loop, after every post-frame callback —
    // including the one that applies this frame's measurements — so the next
    // pick sees these rows as measured.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleNextBatch();
    });

    return Offstage(
      child: CustomMultiChildLayout(
        delegate: _MeasureAheadDelegate(
          cells: cells,
          measurement: widget.measurement,
        ),
        children: children,
      ),
    );
  }
}

class _MeasureAheadDelegate extends MultiChildLayoutDelegate {
  _MeasureAheadDelegate({required this.cells, required this.measurement});

  final List<(CellLayoutId, double)> cells;
  final RowHeightMeasurement measurement;

  @override
  void performLayout(Size size) {
    for (final (id, width) in cells) {
      final measured = layoutChild(
        id,
        BoxConstraints(
          minWidth: width,
          maxWidth: width,
          maxHeight: measurement.maxHeightClamp,
        ),
      );
      positionChild(id, Offset.zero);
      measurement.onMeasured(id.row, measured.height);
    }
  }

  @override
  bool shouldRelayout(_MeasureAheadDelegate oldDelegate) =>
      !identical(cells, oldDelegate.cells) ||
      !identical(measurement, oldDelegate.measurement);
}
