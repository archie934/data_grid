import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:data_grid/data_grid/models/data/column.dart';

/// Delegate that provides children (cells) for the 2D grid viewport.
/// This is responsible for building widgets at specific grid coordinates.
class DataGridChildDelegate extends TwoDimensionalChildDelegate {
  final List<DataGridColumn> columns;
  final int rowCount;
  final Widget Function(BuildContext context, int row, int column) cellBuilder;

  DataGridChildDelegate({required this.columns, required this.rowCount, required this.cellBuilder});

  /// Builds a child widget for a specific cell location (vicinity).
  /// Returns null if the coordinates are out of bounds.
  @override
  Widget? build(BuildContext context, covariant ChildVicinity vicinity) {
    final childVicinity = vicinity as _DataGridVicinity;

    // Validate that the requested cell is within grid bounds
    if (childVicinity.row < 0 ||
        childVicinity.row >= rowCount ||
        childVicinity.column < 0 ||
        childVicinity.column >= columns.length) {
      return null;
    }

    // Build and return the cell widget at this location
    return cellBuilder(context, childVicinity.row, childVicinity.column);
  }

  /// Determines if the delegate needs to rebuild children.
  /// Returns true if columns or row count has changed.
  @override
  bool shouldRebuild(covariant DataGridChildDelegate oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.rowCount != rowCount;
  }
}

/// Represents a cell's location in the 2D grid.
/// Maps row/column coordinates to xIndex/yIndex used by the viewport.
class _DataGridVicinity extends ChildVicinity {
  _DataGridVicinity(int row, int column) : super(xIndex: column, yIndex: row);

  /// Convenience getter to access the row index
  int get row => yIndex;

  /// Convenience getter to access the column index
  int get column => xIndex;
}

/// The viewport widget that displays a scrollable window into the 2D grid.
/// This widget creates and manages the render object that performs layout.
class DataGridViewport extends TwoDimensionalViewport {
  final List<DataGridColumn> columns;
  final int rowCount;
  final double rowHeight;

  const DataGridViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required this.columns,
    required this.rowCount,
    required this.rowHeight,
    super.cacheExtent,
    super.clipBehavior,
  });

  /// Creates the render object that performs the actual layout and rendering.
  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderDataGridViewport(
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      delegate: delegate as DataGridChildDelegate,
      mainAxis: mainAxis,
      childManager: context as TwoDimensionalChildManager,
      columns: columns,
      rowCount: rowCount,
      rowHeight: rowHeight,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  /// Updates the render object when widget properties change.
  @override
  void updateRenderObject(BuildContext context, RenderDataGridViewport renderObject) {
    renderObject
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..delegate = delegate
      ..mainAxis = mainAxis
      ..columns = columns
      ..rowCount = rowCount
      ..rowHeight = rowHeight
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

/// The render object that performs the actual layout of the 2D grid.
/// This implements the lazy rendering logic that only builds visible cells.
class RenderDataGridViewport extends RenderTwoDimensionalViewport {
  List<DataGridColumn> columns;
  int rowCount;
  double rowHeight;

  RenderDataGridViewport({
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required DataGridChildDelegate super.delegate,
    required super.mainAxis,
    required super.childManager,
    required this.columns,
    required this.rowCount,
    required this.rowHeight,
    super.cacheExtent,
    super.clipBehavior,
  });

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
    final int firstVisibleRow = (verticalScrollOffset / rowHeight).floor().clamp(0, rowCount);
    // Calculate how many rows fit in viewport, plus one extra for partial visibility
    final int visibleRowCount = (viewportHeight / rowHeight).ceil() + 1;
    // Calculate last visible row (but don't exceed total row count)
    final int lastVisibleRow = (firstVisibleRow + visibleRowCount).clamp(0, rowCount);

    // STEP 3: Calculate which COLUMNS are currently visible in the viewport
    double accumulatedWidth = 0;
    int firstVisibleColumn = -1; // -1 means "not found yet"
    int lastVisibleColumn = columns.length;
    double firstVisibleColumnOffset = 0; // How much of the first column is scrolled off-screen

    // Iterate through columns to find visible range
    for (int i = 0; i < columns.length; i++) {
      // Found the first column that extends past the left edge of viewport
      if (accumulatedWidth + columns[i].width > horizontalScrollOffset && firstVisibleColumn == -1) {
        firstVisibleColumn = i;
        // Calculate starting offset: how far into the viewport does this column start?
        // If part of it is scrolled off, this will be negative
        firstVisibleColumnOffset = accumulatedWidth - horizontalScrollOffset;
      }
      accumulatedWidth += columns[i].width;
      // Found where columns extend past the right edge of viewport
      if (accumulatedWidth >= horizontalScrollOffset + viewportWidth) {
        lastVisibleColumn = (i + 1).clamp(0, columns.length);
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
    final double startingYOffset = (firstVisibleRow * rowHeight) - verticalScrollOffset;
    
    double yOffset = startingYOffset; // Vertical position within viewport (can be negative)
    for (int row = firstVisibleRow; row < lastVisibleRow; row++) {
      double xOffset = firstVisibleColumnOffset; // Horizontal position within viewport (can be negative)

      for (int col = firstVisibleColumn; col < lastVisibleColumn; col++) {
        // Create a "vicinity" (location identifier) for this cell
        final vicinity = _DataGridVicinity(row, col);

        // Ask the framework to build or retrieve the cached child widget
        // Only widgets for visible cells are built, providing lazy rendering
        final child = buildOrObtainChildFor(vicinity);

        if (child != null) {
          // Layout the child with exact size constraints
          child.layout(BoxConstraints.tight(Size(columns[col].width, rowHeight)));

          // Position the child within the viewport at the calculated offset
          // The viewport automatically handles the coordinate system
          parentDataOf(child).layoutOffset = Offset(xOffset, yOffset);
        }

        // Move to next column position
        xOffset += columns[col].width;
      }
      // Move to next row position
      yOffset += rowHeight;
    }

    // STEP 5: Tell the scroll controllers the total scrollable dimensions
    // This enables the scrollbars to show correct proportions and limits
    final totalWidth = columns.fold<double>(0, (sum, col) => sum + col.width);
    final totalHeight = rowCount * rowHeight;

    // Apply content dimensions: min=0, max=(totalSize - viewportSize)
    // Clamped to 0 minimum to prevent negative scroll ranges
    verticalOffset.applyContentDimensions(0, (totalHeight - viewportHeight).clamp(0, double.infinity));
    horizontalOffset.applyContentDimensions(0, (totalWidth - viewportWidth).clamp(0, double.infinity));
  }
}
