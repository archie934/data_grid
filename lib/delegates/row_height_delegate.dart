/// Pluggable row-offset/height indexing strategy for `autoRowHeight`.
///
/// Follows the same swappable-algorithm convention as [SortDelegate]/
/// [FilterDelegate]: consumers can supply their own implementation via
/// `AutoRowHeight.delegate` for domain-specific cases. [IndexedRowHeightDelegate]
/// is the default (exact, Fenwick-tree-backed).
///
/// Row positions are addressed by index (position in the current display-row
/// list, which may include non-data slots such as group header bands); rows
/// are addressed by a stable `rowId` (or `null` for non-data slots) so
/// measured heights survive sort/filter/group reorders.
abstract interface class RowHeightDelegate {
  /// Reseeds the position → height mapping from [rowIds] (one entry per
  /// display-row slot, `null` for non-data slots like group header bands,
  /// which always report [estimatedHeight] and are never measured). Recovers
  /// previously-measured heights by matching `rowId`.
  void rebuild(List<double?> rowIds, {required double estimatedHeight});

  /// The current height of the row at [index].
  double heightOf(int index);

  /// The content-space y offset of the top of the row at [index].
  double offsetOf(int index);

  /// The index of the row occupying vertical content-space [offset].
  int indexAtOffset(double offset);

  /// Total content height across all rows.
  double get totalExtent;

  /// Whether the row at [index] has an actual measured height (vs. still
  /// carrying the estimate).
  bool isMeasured(int index);

  /// Records a real measured height for the row at [index]. Returns `true`
  /// iff the recorded height changed by more than a sub-pixel epsilon.
  bool reportMeasured(int index, double measuredHeight);
}

/// Exact, Fenwick-tree-backed [RowHeightDelegate]. O(1) [heightOf], O(log n)
/// [offsetOf]/[indexAtOffset]/[reportMeasured], O(n) [rebuild].
///
/// A plain prefix-sum array would give O(1) [offsetOf] but O(n) per single-row
/// patch — scrolling through a large grid triggers one patch per newly-seen
/// row, making that workload O(n²). The Fenwick tree makes it O(n log n).
class IndexedRowHeightDelegate implements RowHeightDelegate {
  final Map<double, double> _measuredByRowId = {};

  List<double?> _order = const [];
  List<double> _heights = const [];
  List<bool> _measuredFlags = const [];
  List<double> _fenwick = const [];
  double _estimatedHeight = 48.0;

  @override
  void rebuild(List<double?> rowIds, {required double estimatedHeight}) {
    _estimatedHeight = estimatedHeight;
    _order = List<double?>.of(rowIds);
    final n = _order.length;

    _heights = List<double>.generate(n, (i) {
      final id = _order[i];
      if (id == null) return estimatedHeight;
      return _measuredByRowId[id] ?? estimatedHeight;
    });
    _measuredFlags = List<bool>.generate(n, (i) {
      final id = _order[i];
      return id != null && _measuredByRowId.containsKey(id);
    });

    _fenwick = List<double>.filled(n + 1, 0.0);
    for (int i = 0; i < n; i++) {
      _add(i, _heights[i]);
    }
  }

  void _add(int index, double delta) {
    if (delta == 0) return;
    int i = index + 1;
    final n = _heights.length;
    while (i <= n) {
      _fenwick[i] += delta;
      i += i & (-i);
    }
  }

  /// Sum of `heights[0..count)`.
  double _prefixSum(int count) {
    double sum = 0;
    int i = count;
    while (i > 0) {
      sum += _fenwick[i];
      i -= i & (-i);
    }
    return sum;
  }

  @override
  double heightOf(int index) {
    if (index < 0 || index >= _heights.length) return _estimatedHeight;
    return _heights[index];
  }

  @override
  bool isMeasured(int index) {
    if (index < 0 || index >= _measuredFlags.length) return false;
    return _measuredFlags[index];
  }

  @override
  double offsetOf(int index) => _prefixSum(index.clamp(0, _heights.length));

  @override
  int indexAtOffset(double offset) {
    final n = _heights.length;
    if (n == 0 || offset <= 0) return 0;

    int pos = 0;
    double remaining = offset;
    int step = 1;
    while (step * 2 <= n) {
      step *= 2;
    }
    for (; step > 0; step >>= 1) {
      final next = pos + step;
      if (next <= n && _fenwick[next] <= remaining) {
        pos = next;
        remaining -= _fenwick[next];
      }
    }
    return pos.clamp(0, n - 1);
  }

  @override
  double get totalExtent => _prefixSum(_heights.length);

  @override
  bool reportMeasured(int index, double measuredHeight) {
    if (index < 0 || index >= _heights.length) return false;
    final current = _heights[index];
    if ((measuredHeight - current).abs() < 0.5) return false;

    _add(index, measuredHeight - current);
    _heights[index] = measuredHeight;
    _measuredFlags[index] = true;

    final id = _order[index];
    if (id != null) _measuredByRowId[id] = measuredHeight;
    return true;
  }
}
