import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_viewport_delegate.dart';

/// The render object that performs the actual layout of the 2D grid.
/// This implements the lazy rendering logic that only builds visible cells.
class RenderDataGridViewport<T extends DataGridRow>
    extends RenderTwoDimensionalViewport {
  // Track children separately for layered painting
  final List<RenderBox> _unpinnedChildren = [];
  final List<RenderBox> _pinnedChildren = [];
  double _pinnedWidth = 0;

  // Cached column separation results
  List<int>? _cachedPinnedIndices;
  List<int>? _cachedUnpinnedIndices;
  double _cachedPinnedWidth = 0;
  double _cachedUnpinnedWidth = 0;

  RenderDataGridViewport({
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required DataGridChildDelegate<T> super.delegate,
    required super.mainAxis,
    required super.childManager,
    required List<DataGridColumn<T>> columns,
    required int rowCount,
    required double rowHeight,
    required Color pinnedMaskColor,
    super.cacheExtent,
    super.clipBehavior,
  }) : _columns = columns,
       _rowCount = rowCount,
       _rowHeight = rowHeight,
       _pinnedMaskColor = pinnedMaskColor;

  Color _pinnedMaskColor;
  Color get pinnedMaskColor => _pinnedMaskColor;
  set pinnedMaskColor(Color value) {
    if (_pinnedMaskColor == value) return;
    _pinnedMaskColor = value;
    markNeedsPaint();
  }

  List<DataGridColumn<T>> _columns;
  List<DataGridColumn<T>> get columns => _columns;
  set columns(List<DataGridColumn<T>> value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsLayout();
  }

  void _ensureColumnCache() {
    if (_cachedPinnedIndices != null) return;

    _cachedPinnedIndices = [];
    _cachedUnpinnedIndices = [];
    _cachedPinnedWidth = 0;
    _cachedUnpinnedWidth = 0;

    for (int i = 0; i < _columns.length; i++) {
      if (_columns[i].pinned) {
        _cachedPinnedIndices!.add(i);
        _cachedPinnedWidth += _columns[i].width;
      } else {
        _cachedUnpinnedIndices!.add(i);
        _cachedUnpinnedWidth += _columns[i].width;
      }
    }
  }

  int _rowCount;
  int get rowCount => _rowCount;
  set rowCount(int value) {
    if (_rowCount == value) return;
    _rowCount = value;
    markNeedsLayout();
  }

  double _rowHeight;
  double get rowHeight => _rowHeight;
  set rowHeight(double value) {
    if (_rowHeight == value) return;
    _rowHeight = value;
    markNeedsLayout();
  }

  @override
  void layoutChildSequence() {
    // Handle empty grid
    if (_columns.isEmpty || _rowCount == 0) {
      verticalOffset.applyContentDimensions(0, 0);
      horizontalOffset.applyContentDimensions(0, 0);
      return;
    }

    // STEP 1: Get viewport dimensions and current scroll positions
    final double viewportWidth = viewportDimension.width;
    final double viewportHeight = viewportDimension.height;
    final double verticalScrollOffset = verticalOffset.pixels;
    final double horizontalScrollOffset = horizontalOffset.pixels;

    // STEP 2: Use cached column separation
    _ensureColumnCache();
    final pinnedIndices = _cachedPinnedIndices!;
    final unpinnedIndices = _cachedUnpinnedIndices!;
    final pinnedWidth = _cachedPinnedWidth;
    final unpinnedWidth = _cachedUnpinnedWidth;

    // STEP 3: Calculate which ROWS are currently visible in the viewport
    final int firstVisibleRow = (verticalScrollOffset / _rowHeight)
        .floor()
        .clamp(0, _rowCount);
    final int visibleRowCount = (viewportHeight / _rowHeight).ceil() + 1;
    final int lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(
      0,
      _rowCount,
    );

    // Calculate starting Y offset accounting for partially scrolled rows
    final double startingYOffset =
        (firstVisibleRow * _rowHeight) - verticalScrollOffset;

    // STEP 4: Calculate which UNPINNED columns are visible
    // The scrollable area starts after pinned columns
    final double scrollableViewportWidth = viewportWidth - pinnedWidth;

    int firstVisibleUnpinnedIdx = -1;
    int lastVisibleUnpinnedIdx = unpinnedIndices.length;
    double firstUnpinnedColumnOffset = 0;
    double accumulatedUnpinnedWidth = 0;

    for (int i = 0; i < unpinnedIndices.length; i++) {
      final colWidth = _columns[unpinnedIndices[i]].width;

      if (accumulatedUnpinnedWidth + colWidth > horizontalScrollOffset &&
          firstVisibleUnpinnedIdx == -1) {
        firstVisibleUnpinnedIdx = i;
        firstUnpinnedColumnOffset =
            accumulatedUnpinnedWidth - horizontalScrollOffset;
      }
      accumulatedUnpinnedWidth += colWidth;

      if (accumulatedUnpinnedWidth >=
          horizontalScrollOffset + scrollableViewportWidth) {
        lastVisibleUnpinnedIdx = (i + 1).clamp(0, unpinnedIndices.length);
        break;
      }
    }

    if (firstVisibleUnpinnedIdx == -1) {
      firstVisibleUnpinnedIdx = 0;
      firstUnpinnedColumnOffset = 0;
    }

    // Clear child tracking for this layout pass
    _unpinnedChildren.clear();
    _pinnedChildren.clear();
    _pinnedWidth = pinnedWidth;

    // STEP 5: Layout cells for each visible row
    double yOffset = startingYOffset;
    for (int row = firstVisibleRow; row < lastVisibleRow; row++) {
      // Layout UNPINNED columns
      double xOffset = pinnedWidth + firstUnpinnedColumnOffset;
      for (int i = firstVisibleUnpinnedIdx; i < lastVisibleUnpinnedIdx; i++) {
        final colIndex = unpinnedIndices[i];
        final colWidth = _columns[colIndex].width;

        if (xOffset + colWidth <= pinnedWidth) {
          xOffset += colWidth;
          continue;
        }

        final vicinity = DataGridVicinity(row, colIndex);
        final child = buildOrObtainChildFor(vicinity);

        if (child != null) {
          child.layout(BoxConstraints.tight(Size(colWidth, _rowHeight)));
          parentDataOf(child).layoutOffset = Offset(xOffset, yOffset);
          _unpinnedChildren.add(child);
        }
        xOffset += colWidth;
      }

      // Layout PINNED columns at fixed positions
      xOffset = 0;
      for (final colIndex in pinnedIndices) {
        final vicinity = DataGridVicinity(row, colIndex);
        final child = buildOrObtainChildFor(vicinity);

        if (child != null) {
          child.layout(
            BoxConstraints.tight(Size(_columns[colIndex].width, _rowHeight)),
          );
          parentDataOf(child).layoutOffset = Offset(xOffset, yOffset);
          _pinnedChildren.add(child);
        }
        xOffset += _columns[colIndex].width;
      }

      yOffset += _rowHeight;
    }

    // STEP 6: Apply content dimensions
    // Vertical: total height minus viewport height
    final totalHeight = _rowCount * _rowHeight;
    verticalOffset.applyContentDimensions(
      0,
      (totalHeight - viewportHeight).clamp(0, double.infinity),
    );

    // Horizontal: only unpinned width is scrollable (pinned columns are always visible)
    final horizontalMaxScroll = (unpinnedWidth - scrollableViewportWidth).clamp(
      0.0,
      double.infinity,
    );
    horizontalOffset.applyContentDimensions(0, horizontalMaxScroll);
  }

  // Cache paint object to avoid allocation per frame
  Paint? _maskPaint;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_columns.isEmpty || _rowCount == 0) return;

    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      context,
      offset,
    ) {
      // Layer 1: Paint unpinned cells
      for (final child in _unpinnedChildren) {
        context.paintChild(child, offset + parentDataOf(child).layoutOffset!);
      }

      // Layer 2: Paint opaque mask over pinned column area (blocks any bleeding content)
      if (_pinnedWidth > 0) {
        _maskPaint ??= Paint();
        _maskPaint!.color = _pinnedMaskColor;
        context.canvas.drawRect(
          Rect.fromLTWH(offset.dx, offset.dy, _pinnedWidth, size.height),
          _maskPaint!,
        );
      }

      // Layer 3: Paint pinned cells on top
      for (final child in _pinnedChildren) {
        context.paintChild(child, offset + parentDataOf(child).layoutOffset!);
      }
    });
  }
}
