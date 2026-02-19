import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

import 'models/product_row.dart';
import 'config/columns.dart';
import 'renderers/cell_renderers.dart';

const exampleRows = 1000000;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late DataGridController<ProductRow> controller;
  late List<ProductRow> _allRows;
  StreamSubscription? _pageSubscription;

  bool _paginationEnabled = true;
  bool _serverSidePagination = false;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    _allRows = ProductRow.generateSampleData(exampleRows);

    final actionsRenderer = ActionsCellRenderer(onDelete: _deleteRow);
    final columns = createColumns(actionsRenderer);

    controller = DataGridController<ProductRow>(
      initialColumns: columns,
      initialRows: _allRows,
      rowHeight: 48.0,
      onLoadPage: _loadPage,
      onGetTotalCount: _getTotalCount,
    );

    controller.enablePagination(true);
    _setupPageListener();
  }

  void _setupPageListener() {
    _pageSubscription = controller.state$
        .map((s) => s.pagination.currentPage)
        .distinct()
        .listen(_onPageChange);
  }

  Future<void> _onPageChange(int page) async {
    if (!_serverSidePagination || page == _lastPage) return;

    _lastPage = page;
    final totalItems = controller.state.totalItems;
    final rows = await _loadPage(page, controller.state.pagination.pageSize);
    controller.setRows(rows);
    controller.setTotalItems(totalItems);
  }

  Future<List<ProductRow>> _loadPage(int page, int pageSize) async {
    controller.addEvent(
      SetLoadingEvent(isLoading: true, message: 'Loading page $page...'),
    );
    await Future.delayed(const Duration(seconds: 1));

    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, _allRows.length);
    final rows = _allRows.sublist(start, end);

    controller.addEvent(SetLoadingEvent(isLoading: false));
    return rows;
  }

  Future<int> _getTotalCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _allRows.length;
  }

  void _deleteRow(double rowId) => controller.deleteRow(rowId);

  void _togglePagination(bool value) {
    setState(() => _paginationEnabled = value);
    controller.enablePagination(value);
  }

  Future<void> _toggleServerSide(bool value) async {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Data Grid'),
          actions: [_buildToolbar()],
        ),
        body: DataGrid<ProductRow>(controller: controller, cacheExtent: 960),
      ),
    );
  }

  Widget _buildToolbar() {
    return StreamBuilder<SelectionMode>(
      stream: controller.selection$.map((s) => s.mode),
      initialData: controller.state.selection.mode,
      builder: (context, snapshot) {
        return Row(
          children: [
            _buildSelectionModeSelector(snapshot.data!),
            const SizedBox(width: 16),
            _buildPaginationToggle(),
            const SizedBox(width: 8),
            _buildServerSideToggle(),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }

  Widget _buildSelectionModeSelector(SelectionMode mode) {
    return SegmentedButton<SelectionMode>(
      segments: const [
        ButtonSegment(value: SelectionMode.none, label: Text('None')),
        ButtonSegment(value: SelectionMode.single, label: Text('Single')),
        ButtonSegment(value: SelectionMode.multiple, label: Text('Multi')),
      ],
      selected: {mode},
      onSelectionChanged: (s) => controller.setSelectionMode(s.first),
    );
  }

  Widget _buildPaginationToggle() {
    return Row(
      children: [
        const Text('Pagination'),
        Switch(value: _paginationEnabled, onChanged: _togglePagination),
      ],
    );
  }

  Widget _buildServerSideToggle() {
    return Row(
      children: [
        const Text('Server'),
        Switch(
          value: _serverSidePagination,
          onChanged: _paginationEnabled ? _toggleServerSide : null,
        ),
      ],
    );
  }
}
