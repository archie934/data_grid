/// Opts the header row into content-measured height instead of a fixed
/// scalar. Headers aren't virtualized, so this is measured synchronously
/// every layout pass — no indexing/estimation machinery needed.
///
/// Header content is measured with a height that's loose but bounded by
/// [maxHeight] (not infinite) — the same constraint `Table`/`IntrinsicHeight`
/// users already live with in vanilla Flutter. Avoid `Expanded`/`Spacer`, and
/// avoid `Align`/`Container(alignment: ...)` without `heightFactor: 1.0` —
/// those widgets expand to fill any bounded incoming height by default, so an
/// unguarded one reports [maxHeight] as the "measured" height regardless of
/// actual content.
///
/// Known limitation: the filter row is not measured — it stays at the theme's
/// `filterRowHeight`.
class AutoHeaderHeight {
  const AutoHeaderHeight({
    this.estimatedHeight = 48.0,
    this.minHeight = 0.0,
    this.maxHeight = 300.0,
  });

  /// Seed height used for the very first layout, before the header has been
  /// measured once.
  final double estimatedHeight;

  final double minHeight;
  final double maxHeight;

  // Value equality so a consumer constructing this inline in `build()` doesn't
  // look like a change on every frame — the render object that consumes it
  // compares with `==` and relayouts when it differs.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoHeaderHeight &&
          estimatedHeight == other.estimatedHeight &&
          minHeight == other.minHeight &&
          maxHeight == other.maxHeight;

  @override
  int get hashCode => Object.hash(estimatedHeight, minHeight, maxHeight);
}
