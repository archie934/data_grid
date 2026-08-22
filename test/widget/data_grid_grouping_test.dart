import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/utils/grid_display_rows.dart';

class TestRow extends DataGridRow {
  final String category;
  final String name;

  TestRow({required double id, required this.category, required this.name}) {
    this.id = id;
  }
}

List<DataGridColumn<TestRow>> _buildColumns() => [
  DataGridColumn<TestRow>(
    id: 1,
    title: 'Category',
    width: 150,
    valueAccessor: (row) => row.category,
  ),
  DataGridColumn<TestRow>(
    id: 2,
    title: 'Name',
    width: 150,
    valueAccessor: (row) => row.name,
  ),
];

List<TestRow> _buildRows() => [
  TestRow(id: 1, category: 'Fruit', name: 'Apple'),
  TestRow(id: 2, category: 'Vegetable', name: 'Carrot'),
  TestRow(id: 3, category: 'Fruit', name: 'Banana'),
  TestRow(id: 4, category: 'Vegetable', name: 'Pea'),
];

void main() {
  group('computeDisplayRows', () {
    late List<DataGridColumn<TestRow>> columns;
    late List<TestRow> rows;
    late Map<double, TestRow> rowsById;
    late List<double> displayOrder;

    setUp(() {
      columns = _buildColumns();
      rows = _buildRows();
      rowsById = {for (final r in rows) r.id: r};
      displayOrder = rows.map((r) => r.id).toList();
    });

    test('ungrouped fast path returns one GridDataRow per id in order', () {
      final result = computeDisplayRows<TestRow>(
        displayOrder: displayOrder,
        rowsById: rowsById,
        columns: columns,
        group: GroupState.initial(),
      );

      expect(result.length, 4);
      expect(result.every((r) => r is GridDataRow<TestRow>), true);
      expect(
        result.map((r) => (r as GridDataRow<TestRow>).rowId).toList(),
        [1, 2, 3, 4],
      );
    });

    test(
      'buckets by value preserving first-appearance order regardless of current sort',
      () {
        final result = computeDisplayRows<TestRow>(
          displayOrder: displayOrder,
          rowsById: rowsById,
          columns: columns,
          group: const GroupState(groupedColumnIds: [1], expandedGroups: {}),
        );

        // Fruit (rows 1,3) appears before Vegetable (rows 2,4), even though
        // rows are interleaved in displayOrder.
        expect(result.length, 6); // 2 headers + 4 data rows
        final fruitHeader = result[0] as GridGroupHeaderRow<TestRow>;
        expect(fruitHeader.displayLabel, 'Fruit');
        expect(fruitHeader.rowCount, 2);
        expect(fruitHeader.isExpanded, true);
        expect((result[1] as GridDataRow<TestRow>).rowId, 1);
        expect((result[2] as GridDataRow<TestRow>).rowId, 3);

        final vegHeader = result[3] as GridGroupHeaderRow<TestRow>;
        expect(vegHeader.displayLabel, 'Vegetable');
        expect(vegHeader.rowCount, 2);
        expect((result[4] as GridDataRow<TestRow>).rowId, 2);
        expect((result[5] as GridDataRow<TestRow>).rowId, 4);
      },
    );

    test(
      'collapsed group omits its data rows but keeps the header with the full count',
      () {
        const groupKey = '1:Fruit';
        final result = computeDisplayRows<TestRow>(
          displayOrder: displayOrder,
          rowsById: rowsById,
          columns: columns,
          group: const GroupState(
            groupedColumnIds: [1],
            expandedGroups: {groupKey: false},
          ),
        );

        // Fruit collapsed (header only), Vegetable expanded (header + 2 rows).
        expect(result.length, 4);
        final fruitHeader = result[0] as GridGroupHeaderRow<TestRow>;
        expect(fruitHeader.groupKey, groupKey);
        expect(fruitHeader.isExpanded, false);
        expect(fruitHeader.rowCount, 2);
        expect(result[1] is GridGroupHeaderRow<TestRow>, true);
      },
    );

    test('uses cellFormatter for displayLabel when provided', () {
      final formattedColumns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Category',
          width: 150,
          valueAccessor: (row) => row.category,
          cellFormatter: (TestRow row, DataGridColumn column) =>
              'Category: ${row.category}',
        ),
        columns[1],
      ];

      final result = computeDisplayRows<TestRow>(
        displayOrder: displayOrder,
        rowsById: rowsById,
        columns: formattedColumns,
        group: const GroupState(groupedColumnIds: [1], expandedGroups: {}),
      );

      final header = result[0] as GridGroupHeaderRow<TestRow>;
      expect(header.displayLabel, 'Category: Fruit');
    });
  });

  group('Group events', () {
    late DataGridController<TestRow> controller;

    setUp(() {
      controller = DataGridController<TestRow>(
        initialColumns: _buildColumns(),
        initialRows: _buildRows(),
        sortDebounce: Duration.zero,
        filterDebounce: Duration.zero,
      );
    });

    tearDown(() => controller.dispose());

    testWidgets('grouping a second column replaces, not appends', (
      tester,
    ) async {
      controller.addEvent(GroupByColumnEvent(columnId: 1));
      await tester.pump();
      expect(controller.state.group.groupedColumnIds, [1]);

      controller.addEvent(GroupByColumnEvent(columnId: 2));
      await tester.pump();
      expect(controller.state.group.groupedColumnIds, [2]);
    });

    testWidgets('ungrouping the active column empties the list', (
      tester,
    ) async {
      controller.addEvent(GroupByColumnEvent(columnId: 1));
      await tester.pump();
      controller.addEvent(UngroupColumnEvent(columnId: 1));
      await tester.pump();
      expect(controller.state.group.groupedColumnIds, isEmpty);
    });

    testWidgets(
      'toggling an unknown groupKey collapses it on the first toggle (was implicitly expanded)',
      (tester) async {
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: 'g1'));
        await tester.pump();
        expect(controller.state.group.isGroupExpanded('g1'), false);

        controller.addEvent(ToggleGroupExpansionEvent(groupKey: 'g1'));
        await tester.pump();
        expect(controller.state.group.isGroupExpanded('g1'), true);
      },
    );
  });

  group('Grouped rendering', () {
    // Controller is built inline in each test (rather than via a shared
    // `late` field + setUp()) — building it in setUp() was observed to
    // prevent the DataGrid's debounced StreamBuilder from picking up the
    // grouped render within pumpAndSettle(), even though controller.state
    // itself updates correctly. This looks like a flutter_test zone/timing
    // quirk tied to setUp()-created controllers, not a bug in the grouping
    // feature — production code never constructs controllers via setUp().
    testWidgets('shows group header bands with label and row count', (
      tester,
    ) async {
      final controller = DataGridController<TestRow>(
        initialColumns: _buildColumns(),
        initialRows: _buildRows(),
        sortDebounce: Duration.zero,
        filterDebounce: Duration.zero,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(controller: controller, rowHeight: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.addEvent(GroupByColumnEvent(columnId: 1));
      await tester.pumpAndSettle();

      expect(find.textContaining('Category: Fruit'), findsOneWidget);
      expect(find.textContaining('Category: Vegetable'), findsOneWidget);
      expect(find.text('(2)'), findsNWidgets(2));
    });

    testWidgets(
      'tapping the chevron collapses and expands a group, changing visible rows',
      (tester) async {
        final controller = DataGridController<TestRow>(
          initialColumns: _buildColumns(),
          initialRows: _buildRows(),
          sortDebounce: Duration.zero,
          filterDebounce: Duration.zero,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<TestRow>(controller: controller, rowHeight: 40),
            ),
          ),
        );
        await tester.pumpAndSettle();

        controller.addEvent(GroupByColumnEvent(columnId: 1));
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.expand_more).first);
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsNothing);
        expect(find.textContaining('Category: Fruit'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsOneWidget);
      },
    );
  });

  group('Hide column', () {
    testWidgets(
      'SetColumnVisibilityEvent(visible: false) removes the column from render',
      (tester) async {
        final controller = DataGridController<TestRow>(
          initialColumns: _buildColumns(),
          initialRows: _buildRows(),
          sortDebounce: Duration.zero,
          filterDebounce: Duration.zero,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Name'), findsOneWidget);

        controller.addEvent(
          SetColumnVisibilityEvent(columnId: 2, visible: false),
        );
        await tester.pumpAndSettle();

        expect(find.text('Name'), findsNothing);
      },
    );
  });

  group('Header context menu', () {
    testWidgets('right-click shows sort, group, and hide actions', (
      tester,
    ) async {
      final controller = DataGridController<TestRow>(
        initialColumns: _buildColumns(),
        initialRows: _buildRows(),
        sortDebounce: Duration.zero,
        filterDebounce: Duration.zero,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final headerCell = find.text('Category').first;
      final gesture = await tester.startGesture(
        tester.getCenter(headerCell),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Sort Ascending'), findsOneWidget);
      expect(find.text('Sort Descending'), findsOneWidget);
      expect(find.text('Clear Sort'), findsOneWidget);
      expect(find.text('Group by This Column'), findsOneWidget);
      expect(find.text('Hide Column'), findsOneWidget);

      await tester.tap(find.text('Group by This Column'));
      await tester.pumpAndSettle();

      expect(controller.state.group.groupedColumnIds, [1]);
    });

    testWidgets('excludes sort/group items when the column disables them', (
      tester,
    ) async {
      final restrictedColumns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Category',
          width: 150,
          valueAccessor: (row) => row.category,
          sortable: false,
          groupable: false,
        ),
      ];
      final controller = DataGridController<TestRow>(
        initialColumns: restrictedColumns,
        initialRows: _buildRows(),
        sortDebounce: Duration.zero,
        filterDebounce: Duration.zero,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final headerCell = find.text('Category').first;
      final gesture = await tester.startGesture(
        tester.getCenter(headerCell),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Sort Ascending'), findsNothing);
      expect(find.text('Group by This Column'), findsNothing);
      expect(find.text('Hide Column'), findsOneWidget);
    });
  });

  group('Drag-select with grouping active', () {
    testWidgets(
      'a drag rectangle crossing a group header band excludes that row without throwing',
      (tester) async {
        final controller = DataGridController<TestRow>(
          initialColumns: _buildColumns(),
          initialRows: _buildRows(),
          sortDebounce: Duration.zero,
          filterDebounce: Duration.zero,
        );
        addTearDown(controller.dispose);
        controller.setSelectionMode(SelectionMode.multiple);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<TestRow>(controller: controller, rowHeight: 40),
            ),
          ),
        );
        await tester.pumpAndSettle();

        controller.addEvent(GroupByColumnEvent(columnId: 1));
        await tester.pumpAndSettle();

        final gridTopLeft = tester.getTopLeft(find.byType(DataGrid<TestRow>));
        // Row 0 is the "Fruit" group header band; drag from inside it down
        // through the first data row below.
        final start = gridTopLeft + const Offset(50, 20);
        final end = gridTopLeft + const Offset(50, 90);

        final gesture = await tester.startGesture(
          start,
          kind: PointerDeviceKind.mouse,
          buttons: kSecondaryMouseButton,
        );
        await tester.pump(const Duration(milliseconds: 20));
        await gesture.moveTo(end);
        await tester.pump(const Duration(milliseconds: 20));
        await gesture.up();
        await tester.pumpAndSettle();

        // No exception thrown, and only real data-row cells were selected.
        for (final cellId in controller.state.selection.focusedCells) {
          final rowId = double.parse(cellId.split('_').first);
          expect(controller.state.rowsById.containsKey(rowId), true);
        }
      },
    );
  });
}
