import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The (buffered) window of row indices a quadrant should build, as
/// `[firstRow, lastRow)`.
class VisibleRowRange {
  final int firstRow;
  final int lastRow;

  const VisibleRowRange(this.firstRow, this.lastRow);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisibleRowRange &&
          firstRow == other.firstRow &&
          lastRow == other.lastRow;

  @override
  int get hashCode => Object.hash(firstRow, lastRow);
}

/// The row window (viewport plus [cacheExtent] buffer on each side) that should
/// be built for the given scroll position, out of [rowCount] total rows.
///
/// Shared by all three virtualized layers ([GridUnpinnedQuadrant],
/// [GridPinnedQuadrant], [FullWidthRowBandLayer]) so a pinned cell, an unpinned
/// cell and a group band belonging to the same row always agree on the window.
///
/// [cacheExtent] is clamped to 500px under [kDebugMode]: pre-rendering a large
/// buffer is what keeps release-build flings smooth, but it makes debug builds
/// and hot reload sluggish for no benefit.
VisibleRowRange visibleRowRange({
  required double scrollOffset,
  required double viewportExtent,
  required double cacheExtent,
  required double rowHeight,
  required int rowCount,
}) {
  final effectiveCacheExtent = kDebugMode
      ? cacheExtent.clamp(0.0, 500.0)
      : cacheExtent;

  final firstVisibleRow = (scrollOffset / rowHeight).floor().clamp(0, rowCount);
  final visibleRowCount = (viewportExtent / rowHeight).ceil() + 1;
  final lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(0, rowCount);
  final bufferRows = (effectiveCacheExtent / rowHeight).ceil();

  return VisibleRowRange(
    (firstVisibleRow - bufferRows).clamp(0, rowCount),
    (lastVisibleRow + bufferRows).clamp(0, rowCount),
  );
}

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
/// only on its column, and its y/height only on its row, so neither needs a
/// per-cell record.
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

/// A [MultiChildLayoutDelegate] that positions grid cells in viewport space.
///
/// Cell geometry is resolved *here*, at layout time, from two scroll-
/// independent inputs — [columnSpans] for the horizontal axis and [rowHeight]
/// for the vertical one — rather than being precomputed into per-cell rects by
/// the widget layer. That's what lets scrolling reposition every cell through
/// [relayout] → `markNeedsLayout` alone, with no widget rebuild.
class GridLayoutDelegate extends MultiChildLayoutDelegate {
  /// The cells currently built, in child order.
  final List<CellLayoutId> cellIds;

  /// Horizontal placement per column index (content space).
  final Map<int, ColumnSpan> columnSpans;

  /// Uniform row height, in logical pixels.
  final double rowHeight;

  /// Horizontal scroll offset notifier. Pass `null` for the pinned quadrant.
  final ValueNotifier<double>? hOffset;

  /// Vertical scroll offset notifier.
  final ValueNotifier<double> vOffset;

  /// Width of the pinned-column area; added to unpinned cells' x positions.
  final double pinnedWidth;

  GridLayoutDelegate({
    required this.cellIds,
    required this.columnSpans,
    required this.rowHeight,
    required this.vOffset,
    required Listenable relayout,
    this.hOffset,
    this.pinnedWidth = 0.0,
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

    for (final id in cellIds) {
      if (!hasChild(id)) continue;
      final span = columnSpans[id.column];
      if (span == null) continue;

      final x = span.x - hScroll + pinnedWidth;
      final y = id.row * rowHeight - vScroll;

      // Tight constraints make each cell its own relayout boundary, so an
      // invalidation inside one cell can't dirty the whole quadrant.
      layoutChild(id, BoxConstraints.tight(Size(span.width, rowHeight)));
      positionChild(id, Offset(x, y));
    }
  }

  @override
  bool shouldRelayout(GridLayoutDelegate oldDelegate) {
    return !identical(cellIds, oldDelegate.cellIds) ||
        !identical(columnSpans, oldDelegate.columnSpans) ||
        !identical(hOffset, oldDelegate.hOffset) ||
        !identical(vOffset, oldDelegate.vOffset) ||
        rowHeight != oldDelegate.rowHeight ||
        pinnedWidth != oldDelegate.pinnedWidth;
  }
}
