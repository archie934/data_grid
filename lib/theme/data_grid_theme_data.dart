import 'package:flutter/material.dart';

class DataGridThemeData {
  final DataGridDimensions dimensions;
  final DataGridPadding padding;
  final DataGridColors colors;
  final DataGridBorders borders;

  const DataGridThemeData({
    required this.dimensions,
    required this.padding,
    required this.colors,
    required this.borders,
  });

  factory DataGridThemeData.defaultTheme() {
    return DataGridThemeData(
      dimensions: DataGridDimensions.defaults(),
      padding: DataGridPadding.defaults(),
      colors: DataGridColors.defaults(),
      borders: DataGridBorders.defaults(),
    );
  }

  DataGridThemeData copyWith({
    DataGridDimensions? dimensions,
    DataGridPadding? padding,
    DataGridColors? colors,
    DataGridBorders? borders,
  }) {
    return DataGridThemeData(
      dimensions: dimensions ?? this.dimensions,
      padding: padding ?? this.padding,
      colors: colors ?? this.colors,
      borders: borders ?? this.borders,
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

  const DataGridDimensions({
    required this.scrollbarWidth,
    required this.scrollbarHeight,
    required this.headerHeight,
    required this.rowHeight,
    required this.filterRowHeight,
    required this.selectionColumnWidth,
    required this.columnMinWidth,
    required this.columnMaxWidth,
    required this.scrollbarThumbMinSize,
    required this.resizeHandleWidth,
  });

  factory DataGridDimensions.defaults() {
    return const DataGridDimensions(
      scrollbarWidth: 12.0,
      scrollbarHeight: 12.0,
      headerHeight: 48.0,
      rowHeight: 48.0,
      filterRowHeight: 40.0,
      selectionColumnWidth: 50.0,
      columnMinWidth: 50.0,
      columnMaxWidth: 1000.0,
      scrollbarThumbMinSize: 30.0,
      resizeHandleWidth: 8.0,
    );
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

  const DataGridPadding({
    required this.cellPadding,
    required this.editorPadding,
    required this.checkboxPadding,
    required this.headerPadding,
    required this.filterPadding,
    required this.filterInputPadding,
    required this.iconSpacing,
    required this.scrollbarThumbInset,
  });

  factory DataGridPadding.defaults() {
    return const DataGridPadding(
      cellPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      editorPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      checkboxPadding: EdgeInsets.all(8),
      headerPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      filterPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      filterInputPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      iconSpacing: 4.0,
      scrollbarThumbInset: 2.0,
    );
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

  const DataGridColors({
    required this.selectionColor,
    required this.evenRowColor,
    required this.oddRowColor,
    required this.headerColor,
    required this.filterBackgroundColor,
    required this.editIndicatorColor,
    required this.resizeHandleActiveColor,
    required this.scrollbarTrackColor,
    required this.scrollbarThumbColor,
  });

  factory DataGridColors.defaults() {
    return DataGridColors(
      selectionColor: Colors.blue.withValues(alpha: 0.1),
      evenRowColor: Colors.white,
      oddRowColor: Colors.grey[50]!,
      headerColor: Colors.grey[200]!,
      filterBackgroundColor: Colors.grey[100]!,
      editIndicatorColor: Colors.blue,
      resizeHandleActiveColor: Colors.blue.withValues(alpha: 0.3),
      scrollbarTrackColor: Colors.grey.withValues(alpha: 0.1),
      scrollbarThumbColor: const Color(0xFF757575).withValues(alpha: 0.7),
    );
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

  const DataGridBorders({
    required this.cellBorder,
    required this.headerBorder,
    required this.checkboxCellBorder,
    required this.filterBorder,
    required this.rowBorder,
    required this.pinnedBorder,
    required this.editingBorder,
    required this.scrollbarBorder,
    required this.pinnedShadow,
  });

  factory DataGridBorders.defaults() {
    const standardBorderColor = Color(0xFFE0E0E0);
    const strongBorderColor = Color(0xFFBDBDBD);

    return DataGridBorders(
      cellBorder: Border(
        bottom: BorderSide(color: standardBorderColor, width: 1.0),
        right: BorderSide(color: standardBorderColor, width: 1.0),
      ),
      headerBorder: Border(
        bottom: BorderSide(color: strongBorderColor, width: 1.0),
        right: BorderSide(color: strongBorderColor, width: 1.0),
      ),
      checkboxCellBorder: Border(
        bottom: BorderSide(color: standardBorderColor, width: 1.0),
        right: BorderSide(color: standardBorderColor, width: 1.0),
      ),
      filterBorder: Border(
        bottom: BorderSide(color: strongBorderColor, width: 1.0),
        right: BorderSide(color: strongBorderColor, width: 1.0),
      ),
      rowBorder: Border(bottom: BorderSide(color: standardBorderColor, width: 1.0)),
      pinnedBorder: Border(right: BorderSide(color: strongBorderColor, width: 2.0)),
      editingBorder: Border.all(color: Colors.blue, width: 2.0),
      scrollbarBorder: Border(
        left: BorderSide(color: standardBorderColor, width: 1.0),
        top: BorderSide(color: standardBorderColor, width: 1.0),
      ),
      pinnedShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.0, offset: const Offset(2, 0)),
      ],
    );
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
