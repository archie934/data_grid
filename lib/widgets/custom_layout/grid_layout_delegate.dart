import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/delegates/row_height_delegate.dart';
import 'package:flutter_data_grid/widgets/custom_layout/row_metrics.dart';

/// Identifies a single cell in the grid by its row and column indices.
class CellLayoutId {
  final int row;
  final int column;

  const CellLayoutId(this.row, this.column);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellLayoutId && row == other.row && column == other.column;

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'CellLayoutId($row, $column)';
}

/// A column's horizontal placement in content space (scroll-independent).
///
/// Stored once per column rather than once per cell: a cell's x/width depends
/// only on its column, and its y/height only on its row (via [RowMetrics]),
/// so neither needs a per-cell record.
class ColumnSpan {
  final double x;
  final double width;

  const ColumnSpan(this.x, this.width);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnSpan && x == other.x && width == other.width;

  @override
  int get hashCode => Object.hash(x, width);
}

/// Auto-row-height measurement hook for [GridLayoutDelegate].
///
/// For any cell whose row isn't yet [RowHeightDelegate.isMeasured], the
/// delegate lays it out with a loose height constraint (up to
/// [maxHeightClamp]) instead of the usual tight fit, and reports the
/// resolved size back via [onMeasured] — the same technique Flutter's own
/// `Table`/`IntrinsicHeight` use internally. Once a row is measured, its
/// cells fall back to the ordinary tight-constraint fast path, so this cost
/// is paid once per row rather than every frame.
class RowHeightMeasurement {
  RowHeightMeasurement({
    required this.delegate,
    required this.maxHeightClamp,
    required this.onMeasured,
  });

  final RowHeightDelegate delegate;
  final double maxHeightClamp;

  /// Called (possibly many times per frame, once per measured cell) with the
  /// row index and its cell's resolved height. Callers batch these and take
  /// the max per row before patching [delegate].
  final void Function(int row, double measuredHeight) onMeasured;
}

/// A [MultiChildLayoutDelegate] that positions grid cells in viewport space.
///
/// Cell geometry is resolved *here*, at layout time, from two scroll-
/// independent inputs — [columnSpans] for the horizontal axis and
/// [rowMetrics] for the vertical one — rather than being precomputed into
/// per-cell rects by the widget layer. That's what lets scrolling reposition
/// every cell through [relayout] → `markNeedsLayout` alone, with no widget
/// rebuild.
class GridLayoutDelegate extends MultiChildLayoutDelegate {
  /// The cells currently built, in child order.
  final List<CellLayoutId> cellIds;

  /// Horizontal placement per column index (content space).
  final Map<int, ColumnSpan> columnSpans;

  /// Row offsets/heights (content space). Fixed or auto-measured.
  final RowMetrics rowMetrics;

  /// Bumped whenever [rowMetrics]' underlying heights change without its
  /// identity changing (an auto-height measurement batch was applied), so
  /// [shouldRelayout] can tell that positions moved.
  final int rowMetricsVersion;

  /// Horizontal scroll offset notifier. Pass `null` for the pinned quadrant.
  final ValueNotifier<double>? hOffset;

  /// Vertical scroll offset notifier.
  final ValueNotifier<double> vOffset;

  /// Width of the pinned-column area; added to unpinned cells' x positions.
  final double pinnedWidth;

  /// When non-null, enables auto-row-height measurement (see
  /// [RowHeightMeasurement]) for rows that haven't been measured yet.
  final RowHeightMeasurement? measurement;

  GridLayoutDelegate({
    required this.cellIds,
    required this.columnSpans,
    required this.rowMetrics,
    required this.vOffset,
    required Listenable relayout,
    this.rowMetricsVersion = 0,
    this.hOffset,
    this.pinnedWidth = 0.0,
    this.measurement,
  }) : super(relayout: relayout);

  /// Builds the merged relayout listenable for a quadrant.
  ///
  /// Call this **once**, from the quadrant's `State`, and hold the result:
  /// `RenderCustomMultiChildLayoutBox`'s delegate setter detaches and
  /// reattaches `markNeedsLayout` whenever the listenable's identity changes,
  /// so merging per build would rebind listeners on every build.
  static Listenable buildRelayout({
    ValueNotifier<double>? hOffset,
    required ValueNotifier<double> vOffset,
  }) {
    if (hOffset == null) return vOffset;
    return Listenable.merge([hOffset, vOffset]);
  }

  @override
  void performLayout(Size size) {
    if (cellIds.isEmpty) return;

    final hScroll = hOffset?.value ?? 0.0;
    final vScroll = vOffset.value;
    final measurement = this.measurement;

    for (final id in cellIds) {
      if (!hasChild(id)) continue;
      final span = columnSpans[id.column];
      if (span == null) continue;

      final x = span.x - hScroll + pinnedWidth;
      final y = rowMetrics.offsetOf(id.row) - vScroll;

      if (measurement != null && !measurement.delegate.isMeasured(id.row)) {
        final resolvedSize = layoutChild(
          id,
          BoxConstraints(
            minWidth: span.width,
            maxWidth: span.width,
            maxHeight: measurement.maxHeightClamp,
          ),
        );
        positionChild(id, Offset(x, y));
        measurement.onMeasured(id.row, resolvedSize.height);
      } else {
        // Tight constraints make each cell its own relayout boundary, so an
        // invalidation inside one cell can't dirty the whole quadrant.
        layoutChild(
          id,
          BoxConstraints.tight(Size(span.width, rowMetrics.heightOf(id.row))),
        );
        positionChild(id, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRelayout(GridLayoutDelegate oldDelegate) {
    return !identical(cellIds, oldDelegate.cellIds) ||
        !identical(columnSpans, oldDelegate.columnSpans) ||
        !identical(hOffset, oldDelegate.hOffset) ||
        !identical(vOffset, oldDelegate.vOffset) ||
        rowMetrics != oldDelegate.rowMetrics ||
        rowMetricsVersion != oldDelegate.rowMetricsVersion ||
        pinnedWidth != oldDelegate.pinnedWidth ||
        !identical(measurement, oldDelegate.measurement);
  }
}
