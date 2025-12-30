import 'package:flutter/material.dart';

class DataGridThemeData {
  final DataGridDimensions dimensions;
  final DataGridPadding padding;
  final DataGridColors colors;
  final DataGridBorders borders;
  final DataGridOverlayTheme overlay;

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
       overlay = overlay ?? DataGridOverlayTheme.defaults();

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

class DataGridDimensions {
  final double scrollbarWidth;
  final double scrollbarHeight;
  final double headerHeight;
  final double rowHeight;
  final double filterRowHeight;
  final double selectionColumnWidth;
  final double columnMinWidth;
  final double columnMaxWidth;
  final double scrollbarThumbMinSize;
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
      scrollbarThumbMinSize: scrollbarThumbMinSize ?? this.scrollbarThumbMinSize,
      resizeHandleWidth: resizeHandleWidth ?? this.resizeHandleWidth,
    );
  }
}

class DataGridPadding {
  final EdgeInsets cellPadding;
  final EdgeInsets editorPadding;
  final EdgeInsets checkboxPadding;
  final EdgeInsets headerPadding;
  final EdgeInsets filterPadding;
  final EdgeInsets filterInputPadding;
  final double iconSpacing;
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
  }) : cellPadding = cellPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       editorPadding = editorPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       checkboxPadding = checkboxPadding ?? const EdgeInsets.all(8),
       headerPadding = headerPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       filterPadding = filterPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       filterInputPadding = filterInputPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

class DataGridColors {
  final Color selectionColor;
  final Color evenRowColor;
  final Color oddRowColor;
  final Color headerColor;
  final Color filterBackgroundColor;
  final Color editIndicatorColor;
  final Color resizeHandleActiveColor;
  final Color scrollbarTrackColor;
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
       resizeHandleActiveColor = resizeHandleActiveColor ?? Colors.blue.withValues(alpha: 0.3),
       scrollbarTrackColor = scrollbarTrackColor ?? Colors.grey.withValues(alpha: 0.1),
       scrollbarThumbColor = scrollbarThumbColor ?? const Color(0xFF757575).withValues(alpha: 0.7);

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
      filterBackgroundColor: filterBackgroundColor ?? this.filterBackgroundColor,
      editIndicatorColor: editIndicatorColor ?? this.editIndicatorColor,
      resizeHandleActiveColor: resizeHandleActiveColor ?? this.resizeHandleActiveColor,
      scrollbarTrackColor: scrollbarTrackColor ?? this.scrollbarTrackColor,
      scrollbarThumbColor: scrollbarThumbColor ?? this.scrollbarThumbColor,
    );
  }
}

class DataGridBorders {
  final Border cellBorder;
  final Border headerBorder;
  final Border checkboxCellBorder;
  final Border filterBorder;
  final Border rowBorder;
  final Border pinnedBorder;
  final Border editingBorder;
  final Border scrollbarBorder;
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
       rowBorder = rowBorder ?? const Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0)),
       pinnedBorder = pinnedBorder ?? const Border(right: BorderSide(color: Color(0xFFBDBDBD), width: 2.0)),
       editingBorder = editingBorder ?? Border.all(color: Colors.blue, width: 2.0),
       scrollbarBorder =
           scrollbarBorder ??
           const Border(
             left: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
             top: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
           ),
       pinnedShadow =
           pinnedShadow ??
           [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.0, offset: const Offset(2, 0))];

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

class DataGridOverlayTheme {
  final Color backdropColor;
  final Color cardBackgroundColor;
  final Color shadowColor;
  final EdgeInsets cardPadding;
  final double borderRadius;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final double indicatorSize;
  final double indicatorStrokeWidth;
  final double indicatorTextSpacing;
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
