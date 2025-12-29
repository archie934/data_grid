class ViewportCalculator {
  final double rowHeight;
  final int overscanCount;

  ViewportCalculator({required this.rowHeight, this.overscanCount = 5});

  VisibleRange calculateVisibleRows(double scrollOffset, double viewportHeight, int totalRows) {
    if (totalRows == 0 || viewportHeight <= 0) {
      return VisibleRange(0, 0);
    }

    final firstVisibleRow = (scrollOffset / rowHeight).floor();
    final visibleRowCount = (viewportHeight / rowHeight).ceil();
    final lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(0, totalRows);

    final startWithOverscan = (firstVisibleRow - overscanCount).clamp(0, totalRows);
    final endWithOverscan = (lastVisibleRow + overscanCount).clamp(0, totalRows);

    return VisibleRange(startWithOverscan, endWithOverscan);
  }

  VisibleRange calculateVisibleColumns(double scrollOffset, List<double> columnWidths, double viewportWidth) {
    if (columnWidths.isEmpty || viewportWidth <= 0) {
      return VisibleRange(0, 0);
    }

    int firstVisibleColumn = 0;
    int lastVisibleColumn = 0;
    double accumulatedWidth = 0;
    bool foundFirst = false;

    for (var i = 0; i < columnWidths.length; i++) {
      final columnWidth = columnWidths[i];

      if (!foundFirst && accumulatedWidth + columnWidth > scrollOffset) {
        firstVisibleColumn = i;
        foundFirst = true;
      }

      accumulatedWidth += columnWidth;

      if (foundFirst && accumulatedWidth >= scrollOffset + viewportWidth) {
        lastVisibleColumn = i + 1;
        break;
      }
    }

    if (!foundFirst) {
      return VisibleRange(columnWidths.length, columnWidths.length);
    }

    if (lastVisibleColumn == 0) {
      lastVisibleColumn = columnWidths.length;
    }

    final startWithOverscan = (firstVisibleColumn - overscanCount).clamp(0, columnWidths.length);
    final endWithOverscan = (lastVisibleColumn + overscanCount).clamp(0, columnWidths.length);

    return VisibleRange(startWithOverscan, endWithOverscan);
  }

  double calculateScrollExtent(int totalRows) {
    return totalRows * rowHeight;
  }

  double calculateRowOffset(int rowIndex) {
    return rowIndex * rowHeight;
  }

  int getRowAtPosition(double yPosition) {
    return (yPosition / rowHeight).floor();
  }
}

class VisibleRange {
  final int start;
  final int end;

  VisibleRange(this.start, this.end);

  int get length => end - start;
  bool get isEmpty => length <= 0;

  bool contains(int index) => index >= start && index < end;

  @override
  String toString() => 'VisibleRange($start, $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisibleRange && runtimeType == other.runtimeType && start == other.start && end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
