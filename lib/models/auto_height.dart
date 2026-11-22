import 'package:flutter_data_grid/delegates/row_height_delegate.dart';

/// Opts rows into content-measured height instead of a single fixed scalar.
///
/// Row height is the max intrinsic height across all cells in that row —
/// standard grid semantics, no per-column override. A column whose content
/// must never grow the row should constrain its own `cellWidget` (e.g. with
/// a `ConstrainedBox`) rather than relying on a grid-level knob.
///
/// Cell/header content used under auto mode is measured with a height that's
/// loose but bounded by [maxHeight] (not infinite) — the same constraint
/// `Table`/`IntrinsicHeight` users already live with in vanilla Flutter.
/// Avoid `Expanded`/`Spacer`, and avoid `Align`/`Container(alignment: ...)`
/// without `heightFactor: 1.0` — those widgets expand to fill any bounded
/// incoming height by default, so an unguarded one reports [maxHeight] as
/// the "measured" height for every row regardless of actual content.
///
/// Known v1 limitations: the filter row and group-header bands are not
/// measured — they stay at [estimatedHeight].
///
/// **Requires a non-trivial `DataGrid.cacheExtent`.** A row is measured the
/// first time its cells are laid out — which, for a row still in the
/// cache-extent buffer (built but scrolled just off-screen), happens before
/// the row is ever visible. That's what makes scrolling pop-free: by the
/// time a buffered row reaches the viewport it's already settled at its real
/// height. With `cacheExtent: 0` there is no buffer, so a row's first layout
/// happens exactly when it scrolls into view and the height visibly snaps
/// from [estimatedHeight] to its real size one frame after appearing. Use
/// the default `cacheExtent` (or something comparable to a typical fling
/// distance) whenever [AutoRowHeight] is enabled.
class AutoRowHeight {
  const AutoRowHeight({
    this.estimatedHeight = 48.0,
    this.minHeight = 0.0,
    this.maxHeight = 500.0,
    this.measureAheadExtent = 2000.0,
    this.delegate,
  });

  /// Seed height used for rows that haven't been measured yet, and the
  /// permanent height of non-measured slots (group header bands).
  final double estimatedHeight;

  final double minHeight;
  final double maxHeight;

  /// How far above and below the viewport, in pixels, rows are measured in
  /// the background while scrolling is idle, so they already have their real
  /// height when scrolled into view. Measuring pauses during any scroll
  /// (drag, fling, scrollbar thumb, wheel). Set to `0` to disable.
  final double measureAheadExtent;

  /// Swappable row-offset/height indexing strategy. Defaults to
  /// [IndexedRowHeightDelegate] (exact, Fenwick-tree-backed) when null.
  final RowHeightDelegate? delegate;
}
