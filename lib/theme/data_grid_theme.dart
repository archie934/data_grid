import 'package:flutter/material.dart';
import 'package:flutter_data_grid/theme/data_grid_theme_data.dart';

/// An inherited widget that provides [DataGridThemeData] to descendant widgets.
///
/// Use [DataGridTheme.of] to access the theme data from any widget in the tree.
class DataGridTheme extends InheritedWidget {
  /// The theme data for the data grid.
  final DataGridThemeData data;

  /// Creates a [DataGridTheme] that provides the given [data] to descendants.
  const DataGridTheme({super.key, required this.data, required super.child});

  /// Returns the [DataGridThemeData] from the closest ancestor, or defaults.
  static DataGridThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<DataGridTheme>();
    return theme?.data ?? DataGridThemeData.defaultTheme();
  }

  @override
  bool updateShouldNotify(DataGridTheme oldWidget) {
    return true;
  }
}
