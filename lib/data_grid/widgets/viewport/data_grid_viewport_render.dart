import 'package:flutter/widgets.dart';
import 'package:data_grid/data_grid/models/data/column.dart';
import 'package:data_grid/data_grid/widgets/viewport/data_grid_viewport_delegate.dart';

/// The render object that performs the actual layout of the 2D grid.
/// This implements the lazy rendering logic that only builds visible cells.
class RenderDataGridViewport extends RenderTwoDimensionalViewport {
  RenderDataGridViewport({
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required DataGridChildDelegate super.delegate,
    required super.mainAxis,
    required super.childManager,
    required List<DataGridColumn> columns,
    required int rowCount,
    required double rowHeight,
    super.cacheExtent,
    super.clipBehavior,
  })  : _columns = columns,
        _rowCount = rowCount,
        _rowHeight = rowHeight;

  List<DataGridColumn> _columns;
  List<DataGridColumn> get columns => _columns;
  set columns(List<DataGridColumn> value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsLayout();
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

  /// Core layout method called by Flutter to arrange children in the viewport.
  /// This is where the lazy rendering magic happens - only visible cells are built and positioned.
  @override
  void layoutChildSequence() {
    // STEP 1: Get viewport dimensions and current scroll positions
    final double viewportWidth = viewportDimension.width;
    final double viewportHeight = viewportDimension.height;
    final double verticalScrollOffset = verticalOffset.pixels;
    final double horizontalScrollOffset = horizontalOffset.pixels;

    // STEP 2: Calculate which ROWS are currently visible in the viewport
    // Divide scroll offset by row height to find first visible row index
    final int firstVisibleRow = (verticalScrollOffset / _rowHeight).floor().clamp(0, _rowCount);
    // Calculate how many rows fit in viewport, plus one extra for partial visibility
    final int visibleRowCount = (viewportHeight / _rowHeight).ceil() + 1;
    // Calculate last visible row (but don't exceed total row count)
    final int lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(0, _rowCount);

    // STEP 3: Calculate which COLUMNS are currently visible in the viewport
    double accumulatedWidth = 0;
    int firstVisibleColumn = -1; // -1 means "not found yet"
    int lastVisibleColumn = _columns.length;
    double firstVisibleColumnOffset = 0; // How much of the first column is scrolled off-screen

    // Iterate through columns to find visible range
    for (int i = 0; i < _columns.length; i++) {
      // Found the first column that extends past the left edge of viewport
      if (accumulatedWidth + _columns[i].width > horizontalScrollOffset && firstVisibleColumn == -1) {
        firstVisibleColumn = i;
        // Calculate starting offset: how far into the viewport does this column start?
        // If part of it is scrolled off, this will be negative
        firstVisibleColumnOffset = accumulatedWidth - horizontalScrollOffset;
      }
      accumulatedWidth += _columns[i].width;
      // Found where columns extend past the right edge of viewport
      if (accumulatedWidth >= horizontalScrollOffset + viewportWidth) {
        lastVisibleColumn = (i + 1).clamp(0, _columns.length);
        break;
      }
    }

    // If no column was found (e.g., scrolled past all content), default to first column
    if (firstVisibleColumn == -1) {
      firstVisibleColumn = 0;
      firstVisibleColumnOffset = 0;
    }

    // STEP 4: Layout all visible cells
    // Calculate starting Y offset accounting for partially scrolled rows
    final double startingYOffset = (firstVisibleRow * _rowHeight) - verticalScrollOffset;
    
    double yOffset = startingYOffset; // Vertical position within viewport (can be negative)
    for (int row = firstVisibleRow; row < lastVisibleRow; row++) {
      double xOffset = firstVisibleColumnOffset; // Horizontal position within viewport (can be negative)

      for (int col = firstVisibleColumn; col < lastVisibleColumn; col++) {
        // Create a "vicinity" (location identifier) for this cell
        final vicinity = DataGridVicinity(row, col);

        // Ask the framework to build or retrieve the cached child widget
        // Only widgets for visible cells are built, providing lazy rendering
        final child = buildOrObtainChildFor(vicinity);

        if (child != null) {
          // Layout the child with exact size constraints
          child.layout(BoxConstraints.tight(Size(_columns[col].width, _rowHeight)));

          // Position the child within the viewport at the calculated offset
          // The viewport automatically handles the coordinate system
          parentDataOf(child).layoutOffset = Offset(xOffset, yOffset);
        }

        // Move to next column position
        xOffset += _columns[col].width;
      }
      // Move to next row position
      yOffset += _rowHeight;
    }

    // STEP 5: Tell the scroll controllers the total scrollable dimensions
    // This enables the scrollbars to show correct proportions and limits
    final totalWidth = _columns.fold<double>(0, (sum, col) => sum + col.width);
    final totalHeight = _rowCount * _rowHeight;

    // Apply content dimensions: min=0, max=(totalSize - viewportSize)
    // Clamped to 0 minimum to prevent negative scroll ranges
    verticalOffset.applyContentDimensions(0, (totalHeight - viewportHeight).clamp(0, double.infinity));
    horizontalOffset.applyContentDimensions(0, (totalWidth - viewportWidth).clamp(0, double.infinity));
  }
}

