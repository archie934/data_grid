import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

class SomeRow implements DataGridRow {
  @override
  double id;
  String name;
  int quantity;
  double price;
  double total;
  Map<int, dynamic> extraData;

  SomeRow({required this.id, this.name = '', this.quantity = 0, this.price = 0.0, Map<int, dynamic>? extraData})
    : total = quantity * price,
      extraData = extraData ?? {};

  void updateTotal() {
    total = quantity * price;
  }
}

class RedCellRenderer extends CellRenderer<SomeRow> {
  const RedCellRenderer();

  @override
  Widget buildCell(
    BuildContext context,
    SomeRow row,
    DataGridColumn column,
    int rowIndex,
    CellRenderContext<SomeRow> renderContext,
  ) {
    final theme = DataGridTheme.of(context);
    return Container(
      color: Colors.red,
      padding: theme.padding.cellPadding,
      alignment: Alignment.centerLeft,
      child: Text(
        'Row ${row.id.toInt()}, Col ${column.id}',
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

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
  late List<SomeRow> _allRows;
  StreamSubscription? _pageSubscription;
  int _lastPage = 1;
  bool _paginationEnabled = true;
  bool _serverSidePagination = false;

  Future<List<SomeRow>> _loadPage(int page, int pageSize) async {
    controller.addEvent(SetLoadingEvent(isLoading: true, message: 'Loading page $page...'));
    await Future.delayed(const Duration(seconds: 2));
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, _allRows.length);
    final rows = _allRows.sublist(start, end);
    controller.addEvent(SetLoadingEvent(isLoading: false));
    return rows;
  }

  Future<int> _getTotalCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allRows.length;
  }

  @override
  void initState() {
    super.initState();

    final columns = [
      DataGridColumn<SomeRow>(
        id: 0,
        title: 'ID',
        width: 80,
        pinned: false,
        editable: false,
        valueAccessor: (row) => row.id.toInt().toString(),
      ),
      DataGridColumn<SomeRow>(
        id: 1,
        title: 'Name',
        width: 200,
        pinned: false,
        editable: true,
        valueAccessor: (row) => row.name.isEmpty ? 'Item ${row.id.toInt()}' : row.name,
        cellValueSetter: (row, value) {
          row.name = value.toString();
        },
      ),
      DataGridColumn<SomeRow>(
        id: 2,
        title: 'Quantity',
        width: 120,
        editable: true,
        valueAccessor: (row) => row.quantity.toString(),
        cellValueSetter: (row, value) {
          row.quantity = int.tryParse(value.toString()) ?? 0;
          row.updateTotal();
        },
        validator: (oldValue, newValue) {
          final parsed = int.tryParse(newValue.toString());
          return parsed != null && parsed >= 0;
        },
      ),
      DataGridColumn<SomeRow>(
        id: 3,
        title: 'Price',
        width: 120,
        editable: true,
        cellRenderer: const RedCellRenderer(),
        valueAccessor: (row) => '\$${row.price.toStringAsFixed(2)}',
        cellValueSetter: (row, value) {
          final cleanValue = value.toString().replaceAll('\$', '').trim();
          row.price = double.tryParse(cleanValue) ?? 0.0;
          row.updateTotal();
        },
        validator: (oldValue, newValue) {
          final cleanValue = newValue.toString().replaceAll('\$', '').trim();
          final parsed = double.tryParse(cleanValue);
          return parsed != null && parsed >= 0;
        },
      ),
      DataGridColumn<SomeRow>(
        id: 4,
        title: 'Total',
        width: 120,
        editable: false,
        valueAccessor: (row) => '\$${row.total.toStringAsFixed(2)}',
      ),
      ...List.generate(15, (index) {
        final columnId = index + 5;
        return DataGridColumn<SomeRow>(
          id: columnId,
          title: 'Extra ${index + 1}',
          width: 150,
          pinned: index % 5 == 0,
          editable: true,
          valueAccessor: (row) => row.extraData[columnId] ?? 'Data ${row.id}',
          cellValueSetter: (row, value) {
            row.extraData[columnId] = value;
          },
        );
      }),
    ];

    _allRows = List.generate(
      1000000,
      (index) => SomeRow(
        id: index.toDouble(),
        name: index % 10 == 0 ? 'Special Item $index' : '',
        quantity: (index % 20) + 1,
        price: (index % 10 + 1) * 9.99,
      ),
    );

    controller = DataGridController<SomeRow>(
      initialColumns: columns,
      initialRows: _allRows,
      rowHeight: 48.0,
      onLoadPage: _loadPage,
      onGetTotalCount: _getTotalCount,
    );

    controller.enablePagination(true);

    _pageSubscription = controller.state$.map((s) => s.pagination.currentPage).distinct().listen((page) async {
      if (_serverSidePagination && page != _lastPage) {
        _lastPage = page;
        final totalItems = controller.state.totalItems;
        final rows = await _loadPage(page, controller.state.pagination.pageSize);
        controller.setRows(rows);
        controller.setTotalItems(totalItems);
      }
    });
  }

  @override
  void dispose() {
    _pageSubscription?.cancel();
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
                final mode = snapshot.data!;
                return Row(
                  children: [
                    SegmentedButton<SelectionMode>(
                      segments: const [
                        ButtonSegment(value: SelectionMode.none, label: Text('None')),
                        ButtonSegment(value: SelectionMode.single, label: Text('Single')),
                        ButtonSegment(value: SelectionMode.multiple, label: Text('Multi')),
                      ],
                      selected: {mode},
                      onSelectionChanged: (Set<SelectionMode> newSelection) {
                        controller.setSelectionMode(newSelection.first);
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text('Pagination'),
                    Switch(
                      value: _paginationEnabled,
                      onChanged: (value) {
                        setState(() => _paginationEnabled = value);
                        controller.enablePagination(value);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Server'),
                    Switch(
                      value: _serverSidePagination,
                      onChanged: _paginationEnabled
                          ? (value) async {
                              setState(() => _serverSidePagination = value);
                              controller.setServerSidePagination(value);
                              if (value) {
                                _lastPage = 1;
                                final totalCount = await _getTotalCount();
                                final rows = await _loadPage(1, controller.state.pagination.pageSize);
                                controller.setRows(rows);
                                controller.setTotalItems(totalCount);
                              } else {
                                controller.setRows(_allRows);
                              }
                            }
                          : null,
                    ),
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
          // theme: customTheme,
        ),
      ),
    );
  }
}
