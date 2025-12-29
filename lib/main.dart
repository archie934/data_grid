import 'package:flutter/material.dart';
import 'package:data_grid/data_grid/data_grid.dart';

// Example: Customizing DataGrid theme
// Using Border objects for complete control over cell borders
final customTheme = DataGridThemeData(
  dimensions: DataGridDimensions.defaults().copyWith(scrollbarWidth: 16.0, rowHeight: 100.0, headerHeight: 56.0),
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
      right: BorderSide(color: const Color.fromARGB(255, 29, 21, 31), width: 2.0),
    ),
    headerBorder: Border(
      bottom: BorderSide(color: Colors.purple[300]!, width: 2.0),
      right: BorderSide(color: Colors.purple[300]!, width: 2.0),
    ),
    filterBorder: Border(
      bottom: BorderSide(color: Colors.purple[300]!, width: 2.0),
      right: BorderSide(color: Colors.purple[300]!, width: 2.0),
    ),
    pinnedBorder: Border(right: BorderSide(color: Colors.purple[400]!, width: 3.0)),
    editingBorder: Border.all(color: Colors.purple, width: 3.0),
    pinnedShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.2), blurRadius: 6.0, offset: const Offset(2, 0))],
  ),
);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late DataGridController<SomeRow> controller;

  @override
  void initState() {
    super.initState();

    final columns = List.generate(
      20,
      (index) => DataGridColumn(id: index, title: 'Column $index', width: 150, pinned: index % 4 == 0, editable: true),
    );

    final rows = List.generate(1000000, (index) => SomeRow(id: index.toDouble()));

    controller = DataGridController<SomeRow>(
      initialColumns: columns,
      initialRows: rows,
      rowHeight: 48.0,
      cellValueAccessor: (row, column) {
        return 'Row ${row.id.toInt()}, Col ${column.id}';
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Grid Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Data Grid'),
          actions: [
            StreamBuilder<SelectionMode>(
              stream: controller.selection$.map((s) => s.mode),
              initialData: controller.state.selection.mode,
              builder: (context, snapshot) {
                final isMultiSelect = snapshot.data == SelectionMode.multiple;
                return Row(
                  children: [
                    Text(isMultiSelect ? 'Multi-Select' : 'Single-Select'),
                    Switch(
                      value: isMultiSelect,
                      onChanged: (value) {
                        controller.setSelectionMode(value ? SelectionMode.multiple : SelectionMode.single);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              },
            ),
          ],
        ),
        body: DataGrid<SomeRow>(
          controller: controller,
          // When using a custom theme, remove rowHeight and headerHeight
          // to let the theme control these dimensions
          theme: customTheme,
          cellBuilder: (row, columnId) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Text('Row ${row.id.toInt()}, Col $columnId'),
            );
          },
        ),
      ),
    );
  }
}
