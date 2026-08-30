import 'package:flutter/foundation.dart';
import 'package:flutter_data_grid/delegates/row_height_delegate.dart';

/// The (possibly buffered) window of row indices that should currently be
/// built by a quadrant, as `[firstRow, lastRow)`.
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

/// Converts between row index and vertical content-space offset.
///
/// This is the single source of truth every quadrant ([GridUnpinnedQuadrant],
/// [GridPinnedQuadrant], [FullWidthRowBandLayer]) reads row positions from, so
/// a pinned cell and an unpinned cell belonging to the same row always land
/// at the same y — they consult the identical [RowMetrics] instance rather
/// than each computing `row * rowHeight` independently.
///
/// [FixedRowMetrics] is today's only implementation (uniform row height);
/// an auto-measuring implementation can be added later without touching any
/// call site, since they all go through this interface.
abstract interface class RowMetrics {
  /// The height of [row], in logical pixels.
  double heightOf(int row);

  /// The content-space y offset of the top of [row].
  double offsetOf(int row);

  /// The index of the row occupying vertical content-space [offset].
  int indexAtOffset(double offset);

  /// The row window (including cache-extent buffer) that should be built for
  /// the given scroll position and viewport, out of [rowCount] total rows.
  VisibleRowRange visibleRowRange({
    required double scrollOffset,
    required double viewportExtent,
    required double cacheExtent,
    required int rowCount,
  });
}

/// Uniform row height. Every row is exactly [rowHeight] tall.
///
/// The row-range formula here is deliberately the literal arithmetic the
/// quadrants used inline before this abstraction existed — preserved exactly
/// (not simplified to `indexAtOffset`-based bounds) so behavior under fixed
/// height is provably unchanged; see the corresponding unit test.
class FixedRowMetrics implements RowMetrics {
  const FixedRowMetrics(this.rowHeight);

  final double rowHeight;

  @override
  double heightOf(int row) => rowHeight;

  @override
  double offsetOf(int row) => row * rowHeight;

  @override
  int indexAtOffset(double offset) => (offset / rowHeight).floor();

  @override
  VisibleRowRange visibleRowRange({
    required double scrollOffset,
    required double viewportExtent,
    required double cacheExtent,
    required int rowCount,
  }) {
    final effectiveCacheExtent = kDebugMode
        ? cacheExtent.clamp(0.0, 500.0)
        : cacheExtent;

    final firstVisibleRow = (scrollOffset / rowHeight).floor().clamp(
      0,
      rowCount,
    );
    final visibleRowCount = (viewportExtent / rowHeight).ceil() + 1;
    final lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(
      0,
      rowCount,
    );
    final bufferRows = (effectiveCacheExtent / rowHeight).ceil();

    final firstRow = (firstVisibleRow - bufferRows).clamp(0, rowCount);
    final lastRow = (lastVisibleRow + bufferRows).clamp(0, rowCount);

    return VisibleRowRange(firstRow, lastRow);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedRowMetrics && rowHeight == other.rowHeight;

  @override
  int get hashCode => rowHeight.hashCode;
}

/// Content-measured, per-row-variable height, backed by a [RowHeightDelegate].
///
/// A thin adapter: [CustomLayoutGridBody] owns the long-lived [delegate] and
/// creates a fresh [AutoRowMetrics] wrapping it on every build (equality is
/// delegate-identity-based, so `didUpdateWidget` change checks still work
/// correctly despite the new wrapper instance).
class AutoRowMetrics implements RowMetrics {
  const AutoRowMetrics(this.delegate);

  final RowHeightDelegate delegate;

  @override
  double heightOf(int row) => delegate.heightOf(row);

  @override
  double offsetOf(int row) => delegate.offsetOf(row);

  @override
  int indexAtOffset(double offset) => delegate.indexAtOffset(offset);

  @override
  VisibleRowRange visibleRowRange({
    required double scrollOffset,
    required double viewportExtent,
    required double cacheExtent,
    required int rowCount,
  }) {
    if (rowCount <= 0) return const VisibleRowRange(0, 0);
    final effectiveCacheExtent = kDebugMode
        ? cacheExtent.clamp(0.0, 500.0)
        : cacheExtent;

    final bufferedStart = (scrollOffset - effectiveCacheExtent).clamp(
      0.0,
      double.infinity,
    );
    final bufferedEnd = scrollOffset + viewportExtent + effectiveCacheExtent;

    final firstRow = delegate.indexAtOffset(bufferedStart).clamp(0, rowCount);
    final lastRow = (delegate.indexAtOffset(bufferedEnd) + 1).clamp(
      0,
      rowCount,
    );

    return VisibleRowRange(firstRow, lastRow);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoRowMetrics && identical(delegate, other.delegate);

  @override
  int get hashCode => identityHashCode(delegate);
}
