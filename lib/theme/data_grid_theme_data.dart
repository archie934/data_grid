import 'package:flutter/material.dart';

/// Theme configuration for customizing the appearance of a [DataGrid].
///
/// Provides control over dimensions, padding, colors, borders, and overlays.
class DataGridThemeData {
  /// Dimension settings (row height, column widths, scrollbar sizes).
  final DataGridDimensions dimensions;

  /// Padding settings for cells, headers, and other elements.
  final DataGridPadding padding;

  /// Color settings for rows, headers, selection, and other elements.
  final DataGridColors colors;

  /// Border settings for cells, headers, and pinned columns.
  final DataGridBorders borders;

  /// Theme settings for loading overlays.
  final DataGridOverlayTheme overlay;

  /// Pre-computed cell decorations to avoid per-cell allocation.
  late final DataGridCellDecorations cellDecorations;

  /// Creates a [DataGridThemeData] with optional custom configurations.
  DataGridThemeData({
    DataGridDimensions? dimensions,
    DataGridPadding? padding,
    DataGridColors? colors,
    DataGridBorders? borders,
    DataGridOverlayTheme? overlay,
  }) : dimensions = dimensions ?? DataGridDimensions.defaults(),
       padding = padding ?? DataGridPadding.defaults(),
       colors = colors ?? DataGridColors.defaults(),
       borders = borders ?? DataGridBorders.defaults(),
       overlay = overlay ?? DataGridOverlayTheme.defaults() {
    cellDecorations = DataGridCellDecorations._(this.colors, this.borders);
  }

  /// Creates a default theme with standard settings.
  factory DataGridThemeData.defaultTheme() {
    return DataGridThemeData();
  }

  DataGridThemeData copyWith({
    DataGridDimensions? dimensions,
    DataGridPadding? padding,
    DataGridColors? colors,
    DataGridBorders? borders,
    DataGridOverlayTheme? overlay,
  }) {
    return DataGridThemeData(
      dimensions: dimensions ?? this.dimensions,
      padding: padding ?? this.padding,
      colors: colors ?? this.colors,
      borders: borders ?? this.borders,
      overlay: overlay ?? this.overlay,
    );
  }
}

/// Pre-computed [BoxDecoration] instances for all common cell variants.
/// Avoids allocating new decorations on every cell build.
class DataGridCellDecorations {
  final BoxDecoration evenRow;
  final BoxDecoration oddRow;
  final BoxDecoration evenRowSelected;
  final BoxDecoration oddRowSelected;
  final BoxDecoration evenRowPinned;
  final BoxDecoration oddRowPinned;
  final BoxDecoration evenRowPinnedSelected;
  final BoxDecoration oddRowPinnedSelected;
  final BoxDecoration checkboxEven;
  final BoxDecoration checkboxOdd;

  DataGridCellDecorations._(DataGridColors colors, DataGridBorders borders)
      : evenRow = BoxDecoration(
          color: colors.evenRowColor,
          border: borders.cellBorder,
        ),
        oddRow = BoxDecoration(
          color: colors.oddRowColor,
          border: borders.cellBorder,
        ),
        evenRowSelected = BoxDecoration(
          color: colors.selectionColor,
          border: borders.cellBorder,
        ),
        oddRowSelected = BoxDecoration(
          color: colors.selectionColor,
          border: borders.cellBorder,
        ),
        evenRowPinned = BoxDecoration(
          color: colors.evenRowColor,
          border: borders.pinnedBorder,
          boxShadow: borders.pinnedShadow,
        ),
        oddRowPinned = BoxDecoration(
          color: colors.oddRowColor,
          border: borders.pinnedBorder,
          boxShadow: borders.pinnedShadow,
        ),
        evenRowPinnedSelected = BoxDecoration(
          color: colors.selectionColor,
          border: borders.pinnedBorder,
          boxShadow: borders.pinnedShadow,
        ),
        oddRowPinnedSelected = BoxDecoration(
          color: colors.selectionColor,
          border: borders.pinnedBorder,
          boxShadow: borders.pinnedShadow,
        ),
        checkboxEven = BoxDecoration(
          color: colors.evenRowColor,
          border: borders.checkboxCellBorder,
        ),
        checkboxOdd = BoxDecoration(
          color: colors.oddRowColor,
          border: borders.checkboxCellBorder,
        );

  BoxDecoration forCell({
    required bool isEven,
    required bool isSelected,
    required bool isPinned,
  }) {
    if (isPinned) {
      if (isSelected) return isEven ? evenRowPinnedSelected : oddRowPinnedSelected;
      return isEven ? evenRowPinned : oddRowPinned;
    }
    if (isSelected) return isEven ? evenRowSelected : oddRowSelected;
    return isEven ? evenRow : oddRow;
  }

  BoxDecoration forCheckbox({required bool isEven}) {
    return isEven ? checkboxEven : checkboxOdd;
  }
}

/// Dimension settings for [DataGrid] layout.
class DataGridDimensions {
  /// Width of the vertical scrollbar.
  final double scrollbarWidth;

  /// Height of the horizontal scrollbar.
  final double scrollbarHeight;

  /// Height of the header row.
  final double headerHeight;

  /// Height of each data row.
  final double rowHeight;

  /// Height of the filter row.
  final double filterRowHeight;

  /// Width of the selection checkbox column.
  final double selectionColumnWidth;

  /// Minimum width when resizing columns.
  final double columnMinWidth;

  /// Maximum width when resizing columns.
  final double columnMaxWidth;

  /// Minimum size of the scrollbar thumb.
  final double scrollbarThumbMinSize;

  /// Width of the column resize handle.
  final double resizeHandleWidth;

  DataGridDimensions({
    double? scrollbarWidth,
    double? scrollbarHeight,
    double? headerHeight,
    double? rowHeight,
    double? filterRowHeight,
    double? selectionColumnWidth,
    double? columnMinWidth,
    double? columnMaxWidth,
    double? scrollbarThumbMinSize,
    double? resizeHandleWidth,
  }) : scrollbarWidth = scrollbarWidth ?? 12.0,
       scrollbarHeight = scrollbarHeight ?? 12.0,
       headerHeight = headerHeight ?? 48.0,
       rowHeight = rowHeight ?? 48.0,
       filterRowHeight = filterRowHeight ?? 40.0,
       selectionColumnWidth = selectionColumnWidth ?? 50.0,
       columnMinWidth = columnMinWidth ?? 50.0,
       columnMaxWidth = columnMaxWidth ?? 1000.0,
       scrollbarThumbMinSize = scrollbarThumbMinSize ?? 30.0,
       resizeHandleWidth = resizeHandleWidth ?? 8.0;

  factory DataGridDimensions.defaults() {
    return DataGridDimensions();
  }

  DataGridDimensions copyWith({
    double? scrollbarWidth,
    double? scrollbarHeight,
    double? headerHeight,
    double? rowHeight,
    double? filterRowHeight,
    double? selectionColumnWidth,
    double? columnMinWidth,
    double? columnMaxWidth,
    double? scrollbarThumbMinSize,
    double? resizeHandleWidth,
  }) {
    return DataGridDimensions(
      scrollbarWidth: scrollbarWidth ?? this.scrollbarWidth,
      scrollbarHeight: scrollbarHeight ?? this.scrollbarHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      filterRowHeight: filterRowHeight ?? this.filterRowHeight,
      selectionColumnWidth: selectionColumnWidth ?? this.selectionColumnWidth,
      columnMinWidth: columnMinWidth ?? this.columnMinWidth,
      columnMaxWidth: columnMaxWidth ?? this.columnMaxWidth,
      scrollbarThumbMinSize:
          scrollbarThumbMinSize ?? this.scrollbarThumbMinSize,
      resizeHandleWidth: resizeHandleWidth ?? this.resizeHandleWidth,
    );
  }
}

/// Padding settings for [DataGrid] elements.
class DataGridPadding {
  /// Padding inside data cells.
  final EdgeInsets cellPadding;

  /// Padding inside cell editors.
  final EdgeInsets editorPadding;

  /// Padding around checkbox cells.
  final EdgeInsets checkboxPadding;

  /// Padding inside header cells.
  final EdgeInsets headerPadding;

  /// Padding around filter cells.
  final EdgeInsets filterPadding;

  /// Padding inside filter input fields.
  final EdgeInsets filterInputPadding;

  /// Spacing between icons.
  final double iconSpacing;

  /// Inset of the scrollbar thumb from the track.
  final double scrollbarThumbInset;

  DataGridPadding({
    EdgeInsets? cellPadding,
    EdgeInsets? editorPadding,
    EdgeInsets? checkboxPadding,
    EdgeInsets? headerPadding,
    EdgeInsets? filterPadding,
    EdgeInsets? filterInputPadding,
    double? iconSpacing,
    double? scrollbarThumbInset,
  }) : cellPadding =
           cellPadding ??
           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       editorPadding =
           editorPadding ??
           const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       checkboxPadding = checkboxPadding ?? const EdgeInsets.all(8),
       headerPadding =
           headerPadding ??
           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       filterPadding =
           filterPadding ??
           const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       filterInputPadding =
           filterInputPadding ??
           const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
       iconSpacing = iconSpacing ?? 4.0,
       scrollbarThumbInset = scrollbarThumbInset ?? 2.0;

  factory DataGridPadding.defaults() {
    return DataGridPadding();
  }

  DataGridPadding copyWith({
    EdgeInsets? cellPadding,
    EdgeInsets? editorPadding,
    EdgeInsets? checkboxPadding,
    EdgeInsets? headerPadding,
    EdgeInsets? filterPadding,
    EdgeInsets? filterInputPadding,
    double? iconSpacing,
    double? scrollbarThumbInset,
  }) {
    return DataGridPadding(
      cellPadding: cellPadding ?? this.cellPadding,
      editorPadding: editorPadding ?? this.editorPadding,
      checkboxPadding: checkboxPadding ?? this.checkboxPadding,
      headerPadding: headerPadding ?? this.headerPadding,
      filterPadding: filterPadding ?? this.filterPadding,
      filterInputPadding: filterInputPadding ?? this.filterInputPadding,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      scrollbarThumbInset: scrollbarThumbInset ?? this.scrollbarThumbInset,
    );
  }
}

/// Color settings for [DataGrid] elements.
class DataGridColors {
  /// Background color for selected rows.
  final Color selectionColor;

  /// Background color for even rows.
  final Color evenRowColor;

  /// Background color for odd rows.
  final Color oddRowColor;

  /// Background color for the header row.
  final Color headerColor;

  /// Background color for the filter row.
  final Color filterBackgroundColor;

  /// Color of the editing indicator.
  final Color editIndicatorColor;

  /// Color of the resize handle when active.
  final Color resizeHandleActiveColor;

  /// Background color of the scrollbar track.
  final Color scrollbarTrackColor;

  /// Color of the scrollbar thumb.
  final Color scrollbarThumbColor;

  DataGridColors({
    Color? selectionColor,
    Color? evenRowColor,
    Color? oddRowColor,
    Color? headerColor,
    Color? filterBackgroundColor,
    Color? editIndicatorColor,
    Color? resizeHandleActiveColor,
    Color? scrollbarTrackColor,
    Color? scrollbarThumbColor,
  }) : selectionColor = selectionColor ?? Colors.blue.withValues(alpha: 0.1),
       evenRowColor = evenRowColor ?? Colors.white,
       oddRowColor = oddRowColor ?? Colors.grey[50]!,
       headerColor = headerColor ?? Colors.grey[200]!,
       filterBackgroundColor = filterBackgroundColor ?? Colors.grey[100]!,
       editIndicatorColor = editIndicatorColor ?? Colors.blue,
       resizeHandleActiveColor =
           resizeHandleActiveColor ?? Colors.blue.withValues(alpha: 0.3),
       scrollbarTrackColor =
           scrollbarTrackColor ?? Colors.grey.withValues(alpha: 0.1),
       scrollbarThumbColor =
           scrollbarThumbColor ??
           const Color(0xFF757575).withValues(alpha: 0.7);

  factory DataGridColors.defaults() {
    return DataGridColors();
  }

  DataGridColors copyWith({
    Color? selectionColor,
    Color? evenRowColor,
    Color? oddRowColor,
    Color? headerColor,
    Color? filterBackgroundColor,
    Color? editIndicatorColor,
    Color? resizeHandleActiveColor,
    Color? scrollbarTrackColor,
    Color? scrollbarThumbColor,
  }) {
    return DataGridColors(
      selectionColor: selectionColor ?? this.selectionColor,
      evenRowColor: evenRowColor ?? this.evenRowColor,
      oddRowColor: oddRowColor ?? this.oddRowColor,
      headerColor: headerColor ?? this.headerColor,
      filterBackgroundColor:
          filterBackgroundColor ?? this.filterBackgroundColor,
      editIndicatorColor: editIndicatorColor ?? this.editIndicatorColor,
      resizeHandleActiveColor:
          resizeHandleActiveColor ?? this.resizeHandleActiveColor,
      scrollbarTrackColor: scrollbarTrackColor ?? this.scrollbarTrackColor,
      scrollbarThumbColor: scrollbarThumbColor ?? this.scrollbarThumbColor,
    );
  }
}

/// Border settings for [DataGrid] elements.
class DataGridBorders {
  /// Border for data cells.
  final Border cellBorder;

  /// Border for header cells.
  final Border headerBorder;

  /// Border for checkbox cells.
  final Border checkboxCellBorder;

  /// Border for filter cells.
  final Border filterBorder;

  /// Border for rows.
  final Border rowBorder;

  /// Border for pinned columns.
  final Border pinnedBorder;

  /// Border shown around cells being edited.
  final Border editingBorder;

  /// Border for scrollbar elements.
  final Border scrollbarBorder;

  /// Shadow applied to pinned columns.
  final List<BoxShadow> pinnedShadow;

  DataGridBorders({
    Border? cellBorder,
    Border? headerBorder,
    Border? checkboxCellBorder,
    Border? filterBorder,
    Border? rowBorder,
    Border? pinnedBorder,
    Border? editingBorder,
    Border? scrollbarBorder,
    List<BoxShadow>? pinnedShadow,
  }) : cellBorder =
           cellBorder ??
           const Border(
             bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
             right: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
           ),
       headerBorder =
           headerBorder ??
           const Border(
             bottom: BorderSide(color: Color(0xFFBDBDBD), width: 1.0),
             right: BorderSide(color: Color(0xFFBDBDBD), width: 1.0),
           ),
       checkboxCellBorder =
           checkboxCellBorder ??
           const Border(
             bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
             right: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
           ),
       filterBorder =
           filterBorder ??
           const Border(
             bottom: BorderSide(color: Color(0xFFBDBDBD), width: 1.0),
             right: BorderSide(color: Color(0xFFBDBDBD), width: 1.0),
           ),
       rowBorder =
           rowBorder ??
           const Border(
             bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
           ),
       pinnedBorder =
           pinnedBorder ??
           const Border(
             right: BorderSide(color: Color(0xFFBDBDBD), width: 2.0),
           ),
       editingBorder =
           editingBorder ?? Border.all(color: Colors.blue, width: 2.0),
       scrollbarBorder =
           scrollbarBorder ??
           const Border(
             left: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
             top: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
           ),
       pinnedShadow =
           pinnedShadow ??
           [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.1),
               blurRadius: 4.0,
               offset: const Offset(2, 0),
             ),
           ];

  factory DataGridBorders.defaults() {
    return DataGridBorders();
  }

  DataGridBorders copyWith({
    Border? cellBorder,
    Border? headerBorder,
    Border? checkboxCellBorder,
    Border? filterBorder,
    Border? rowBorder,
    Border? pinnedBorder,
    Border? editingBorder,
    Border? scrollbarBorder,
    List<BoxShadow>? pinnedShadow,
  }) {
    return DataGridBorders(
      cellBorder: cellBorder ?? this.cellBorder,
      headerBorder: headerBorder ?? this.headerBorder,
      checkboxCellBorder: checkboxCellBorder ?? this.checkboxCellBorder,
      filterBorder: filterBorder ?? this.filterBorder,
      rowBorder: rowBorder ?? this.rowBorder,
      pinnedBorder: pinnedBorder ?? this.pinnedBorder,
      editingBorder: editingBorder ?? this.editingBorder,
      scrollbarBorder: scrollbarBorder ?? this.scrollbarBorder,
      pinnedShadow: pinnedShadow ?? this.pinnedShadow,
    );
  }
}

/// Theme settings for loading overlays in [DataGrid].
class DataGridOverlayTheme {
  /// Color of the backdrop behind the overlay.
  final Color backdropColor;

  /// Background color of the overlay card.
  final Color cardBackgroundColor;

  /// Shadow color for the overlay card.
  final Color shadowColor;

  /// Padding inside the overlay card.
  final EdgeInsets cardPadding;

  /// Border radius of the overlay card.
  final double borderRadius;

  /// Blur radius of the overlay shadow.
  final double shadowBlurRadius;

  /// Offset of the overlay shadow.
  final Offset shadowOffset;

  /// Size of the loading indicator.
  final double indicatorSize;

  /// Stroke width of the loading indicator.
  final double indicatorStrokeWidth;

  /// Spacing between indicator and text.
  final double indicatorTextSpacing;

  /// Default loading message text.
  final String defaultMessage;

  DataGridOverlayTheme({
    Color? backdropColor,
    Color? cardBackgroundColor,
    Color? shadowColor,
    EdgeInsets? cardPadding,
    double? borderRadius,
    double? shadowBlurRadius,
    Offset? shadowOffset,
    double? indicatorSize,
    double? indicatorStrokeWidth,
    double? indicatorTextSpacing,
    String? defaultMessage,
  }) : backdropColor = backdropColor ?? Colors.black.withValues(alpha: 0.3),
       cardBackgroundColor = cardBackgroundColor ?? Colors.white,
       shadowColor = shadowColor ?? Colors.black.withValues(alpha: 0.2),
       cardPadding = cardPadding ?? const EdgeInsets.all(24),
       borderRadius = borderRadius ?? 12.0,
       shadowBlurRadius = shadowBlurRadius ?? 10.0,
       shadowOffset = shadowOffset ?? const Offset(0, 4),
       indicatorSize = indicatorSize ?? 40.0,
       indicatorStrokeWidth = indicatorStrokeWidth ?? 3.0,
       indicatorTextSpacing = indicatorTextSpacing ?? 16.0,
       defaultMessage = defaultMessage ?? 'Processing...';

  factory DataGridOverlayTheme.defaults() {
    return DataGridOverlayTheme();
  }

  DataGridOverlayTheme copyWith({
    Color? backdropColor,
    Color? cardBackgroundColor,
    Color? shadowColor,
    EdgeInsets? cardPadding,
    double? borderRadius,
    double? shadowBlurRadius,
    Offset? shadowOffset,
    double? indicatorSize,
    double? indicatorStrokeWidth,
    double? indicatorTextSpacing,
    String? defaultMessage,
  }) {
    return DataGridOverlayTheme(
      backdropColor: backdropColor ?? this.backdropColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      cardPadding: cardPadding ?? this.cardPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      indicatorStrokeWidth: indicatorStrokeWidth ?? this.indicatorStrokeWidth,
      indicatorTextSpacing: indicatorTextSpacing ?? this.indicatorTextSpacing,
      defaultMessage: defaultMessage ?? this.defaultMessage,
    );
  }
}
