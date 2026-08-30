import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_data_grid/widgets/custom_layout/row_metrics.dart';

/// The exact formula every quadrant used inline before [RowMetrics] existed.
/// Kept here, independent of [FixedRowMetrics], as the ground truth
/// [FixedRowMetrics.visibleRowRange] must reproduce bit-for-bit.
VisibleRowRange _legacyVisibleRowRange({
  required double rowHeight,
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

void main() {
  group('FixedRowMetrics', () {
    test('heightOf returns the uniform row height for any index', () {
      const metrics = FixedRowMetrics(48.0);
      expect(metrics.heightOf(0), 48.0);
      expect(metrics.heightOf(999), 48.0);
    });

    test('offsetOf is row * rowHeight', () {
      const metrics = FixedRowMetrics(40.0);
      expect(metrics.offsetOf(0), 0.0);
      expect(metrics.offsetOf(5), 200.0);
      expect(metrics.offsetOf(1000), 40000.0);
    });

    test('indexAtOffset is the inverse of offsetOf (floor division)', () {
      const metrics = FixedRowMetrics(40.0);
      expect(metrics.indexAtOffset(0.0), 0);
      expect(metrics.indexAtOffset(39.9), 0);
      expect(metrics.indexAtOffset(40.0), 1);
      expect(metrics.indexAtOffset(200.0), 5);
    });

    test('== and hashCode are value-based on rowHeight', () {
      expect(const FixedRowMetrics(48.0), const FixedRowMetrics(48.0));
      expect(
        const FixedRowMetrics(48.0).hashCode,
        const FixedRowMetrics(48.0).hashCode,
      );
      expect(
        const FixedRowMetrics(48.0),
        isNot(const FixedRowMetrics(40.0)),
      );
    });

    test(
      'visibleRowRange matches the legacy inline formula bit-for-bit '
      'across a range of scroll positions, viewport sizes, cache extents '
      'and row heights',
      () {
        const rowHeights = [24.0, 36.0, 40.0, 48.0, 52.5];
        const viewportExtents = [0.0, 300.0, 600.0, 833.0];
        const cacheExtents = [0.0, 100.0, 250.0, 500.0, 1000.0];
        const rowCounts = [0, 1, 10, 100, 100000];

        for (final rowHeight in rowHeights) {
          final metrics = FixedRowMetrics(rowHeight);
          for (final viewportExtent in viewportExtents) {
            for (final cacheExtent in cacheExtents) {
              for (final rowCount in rowCounts) {
                // Sample scroll offsets across the full scrollable range,
                // including the exact top/bottom and odd fractional values.
                final maxOffset = (rowCount * rowHeight).clamp(
                  0.0,
                  double.infinity,
                );
                final scrollOffsets = <double>{
                  0.0,
                  1.0,
                  rowHeight - 0.01,
                  rowHeight,
                  rowHeight + 0.01,
                  maxOffset / 2,
                  maxOffset,
                }..removeWhere((o) => o < 0 || o > maxOffset);

                for (final scrollOffset in scrollOffsets) {
                  final actual = metrics.visibleRowRange(
                    scrollOffset: scrollOffset,
                    viewportExtent: viewportExtent,
                    cacheExtent: cacheExtent,
                    rowCount: rowCount,
                  );
                  final expected = _legacyVisibleRowRange(
                    rowHeight: rowHeight,
                    scrollOffset: scrollOffset,
                    viewportExtent: viewportExtent,
                    cacheExtent: cacheExtent,
                    rowCount: rowCount,
                  );

                  expect(
                    actual.firstRow,
                    expected.firstRow,
                    reason:
                        'firstRow mismatch for rowHeight=$rowHeight '
                        'viewportExtent=$viewportExtent '
                        'cacheExtent=$cacheExtent rowCount=$rowCount '
                        'scrollOffset=$scrollOffset',
                  );
                  expect(
                    actual.lastRow,
                    expected.lastRow,
                    reason:
                        'lastRow mismatch for rowHeight=$rowHeight '
                        'viewportExtent=$viewportExtent '
                        'cacheExtent=$cacheExtent rowCount=$rowCount '
                        'scrollOffset=$scrollOffset',
                  );
                }
              }
            }
          }
        }
      },
    );
  });

  group('VisibleRowRange', () {
    test('== and hashCode are value-based', () {
      expect(const VisibleRowRange(2, 10), const VisibleRowRange(2, 10));
      expect(
        const VisibleRowRange(2, 10).hashCode,
        const VisibleRowRange(2, 10).hashCode,
      );
      expect(
        const VisibleRowRange(2, 10),
        isNot(const VisibleRowRange(2, 11)),
      );
    });
  });
}
