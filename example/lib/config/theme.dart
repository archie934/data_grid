import 'package:flutter/material.dart';
import 'package:flutter_data_grid/data_grid.dart';

final purpleTheme = DataGridThemeData(
  dimensions: DataGridDimensions.defaults().copyWith(
    scrollbarWidth: 16.0,
    rowHeight: 100.0,
    headerHeight: 56.0,
  ),
  padding: DataGridPadding.defaults().copyWith(
    cellPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  colors: DataGridColors.defaults().copyWith(
    selectionColor: Colors.purple.withValues(alpha: 0.15),
    evenRowColor: Colors.white,
    oddRowColor: Colors.grey[100]!,
    headerColor: Colors.purple[50]!,
    editIndicatorColor: Colors.purple,
  ),
  borders: DataGridBorders.defaults().copyWith(
    cellBorder: Border(
      bottom: BorderSide(color: Colors.purple[200]!, width: 2.0),
      right: BorderSide(
        color: const Color.fromARGB(255, 29, 21, 31),
        width: 2.0,
      ),
    ),
    headerBorder: Border(
      bottom: BorderSide(color: Colors.purple[300]!, width: 2.0),
      right: BorderSide(color: Colors.purple[300]!, width: 2.0),
    ),
    filterBorder: Border(
      bottom: BorderSide(color: Colors.purple[300]!, width: 2.0),
      right: BorderSide(color: Colors.purple[300]!, width: 2.0),
    ),
    pinnedBorder: Border(
      right: BorderSide(color: Colors.purple[400]!, width: 3.0),
    ),
    editingBorder: Border.all(color: Colors.purple, width: 3.0),
    pinnedShadow: [
      BoxShadow(
        color: Colors.purple.withValues(alpha: 0.2),
        blurRadius: 6.0,
        offset: const Offset(2, 0),
      ),
    ],
  ),
);
