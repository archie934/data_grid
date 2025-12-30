import 'package:flutter/material.dart';
import 'package:flutter_data_grid/theme/data_grid_theme_data.dart';

class DataGridTheme extends InheritedWidget {
  final DataGridThemeData data;

  const DataGridTheme({super.key, required this.data, required super.child});

  static DataGridThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<DataGridTheme>();
    return theme?.data ?? DataGridThemeData.defaultTheme();
  }

  @override
  bool updateShouldNotify(DataGridTheme oldWidget) {
    return true;
  }
}
