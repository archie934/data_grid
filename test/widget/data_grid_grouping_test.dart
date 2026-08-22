import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      expect(result.map((r) => (r as GridDataRow<TestRow>).rowId).toList(), [
        1,
        2,
        3,
        4,
      ]);
    });

    test(
      'buckets by value preserving first-appearance order regardless of current sort',
      () {
        final result = computeDisplayRows<TestRow>(
          displayOrder: displayOrder,
          rowsById: rowsById,
          columns: columns,
          group: const GroupState(
            groupedColumnIds: [1],
            expandedGroups: {'1:Fruit': true, '1:Vegetable': true},
          ),
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
            expandedGroups: {groupKey: false, '1:Vegetable': true},
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

    test('groups default to collapsed when never explicitly toggled', () {
      final result = computeDisplayRows<TestRow>(
        displayOrder: displayOrder,
        rowsById: rowsById,
        columns: columns,
        group: const GroupState(groupedColumnIds: [1], expandedGroups: {}),
      );

      expect(result.length, 2); // Headers only, no data rows.
      expect(result.every((r) => r is GridGroupHeaderRow<TestRow>), true);
      expect(
        result.every((r) => !(r as GridGroupHeaderRow<TestRow>).isExpanded),
        true,
      );
    });

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
      'toggling an unknown groupKey expands it on the first toggle (was implicitly collapsed)',
      (tester) async {
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: 'g1'));
        await tester.pump();
        expect(controller.state.group.isGroupExpanded('g1'), true);

        controller.addEvent(ToggleGroupExpansionEvent(groupKey: 'g1'));
        await tester.pump();
        expect(controller.state.group.isGroupExpanded('g1'), false);
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
      'groups start collapsed — no data rows visible until expanded',
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

        expect(find.text('Apple'), findsNothing);
        expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
      },
    );

    testWidgets(
      'tapping the chevron expands and collapses a group, changing visible rows',
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

        expect(find.text('Apple'), findsNothing);

        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsOneWidget);
        expect(find.textContaining('Category: Fruit'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.expand_more).first);
        await tester.pumpAndSettle();

        expect(find.text('Apple'), findsNothing);
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
      expect(find.text('Pin Column'), findsOneWidget);
      expect(find.text('Hide Column'), findsOneWidget);

      await tester.tap(find.text('Group by This Column'));
      await tester.pumpAndSettle();

      expect(controller.state.group.groupedColumnIds, [1]);
    });

    testWidgets('pin/unpin toggles the column and menu label', (tester) async {
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

      Future<void> openMenu() async {
        final headerCell = find.text('Category').first;
        final gesture = await tester.startGesture(
          tester.getCenter(headerCell),
          kind: PointerDeviceKind.mouse,
          buttons: kSecondaryMouseButton,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }

      await openMenu();
      expect(find.text('Pin Column'), findsOneWidget);

      await tester.tap(find.text('Pin Column'));
      await tester.pumpAndSettle();

      expect(
        controller.state.columns.firstWhere((c) => c.id == 1).pinned,
        true,
      );

      await openMenu();
      expect(find.text('Unpin Column'), findsOneWidget);

      await tester.tap(find.text('Unpin Column'));
      await tester.pumpAndSettle();

      expect(
        controller.state.columns.firstWhere((c) => c.id == 1).pinned,
        false,
      );
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
        // Groups start collapsed by default — expand "Fruit" so its data
        // rows are actually on screen for the drag below.
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Fruit'));
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

  group('Cell navigation with grouping active', () {
    // Regression coverage: NavigateCellEvent used to index straight into
    // `state.displayOrder` (raw row order), which is wrong once grouping is
    // active — group header bands aren't real rows, and grouping buckets
    // rows by value rather than preserving `displayOrder`'s sequence. That
    // made arrow/shift-arrow navigation jump to the wrong row (or into a
    // hidden, collapsed one) as soon as grouping was active.
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

    testWidgets(
      'arrow-down follows the visual grouped order, not raw displayOrder',
      (tester) async {
        controller.addEvent(GroupByColumnEvent(columnId: 1));
        await tester.pump();
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Fruit'));
        await tester.pump();
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Vegetable'));
        await tester.pump();

        // Visual order: [Fruit header, 1 (Apple), 3 (Banana), Vegetable
        // header, 2 (Carrot), 4 (Pea)] — not raw displayOrder [1, 2, 3, 4].
        controller.addEvent(FocusCellEvent(rowId: 1, columnId: 2));
        await tester.pump();

        controller.addEvent(NavigateCellEvent(CellNavDirection.down));
        await tester.pump();
        // Banana (id 3) is visually next, NOT Carrot (id 2 — which is
        // `displayOrder[1]` in raw insertion order).
        expect(controller.state.selection.activeCellId, '3.0_2');

        controller.addEvent(NavigateCellEvent(CellNavDirection.down));
        await tester.pump();
        // Falls through the (non-navigable) Vegetable header band straight
        // to its first row.
        expect(controller.state.selection.activeCellId, '2.0_2');

        controller.addEvent(NavigateCellEvent(CellNavDirection.down));
        await tester.pump();
        expect(controller.state.selection.activeCellId, '4.0_2');

        // Last visible row — nothing further down.
        controller.addEvent(NavigateCellEvent(CellNavDirection.down));
        await tester.pump();
        expect(controller.state.selection.activeCellId, '4.0_2');
      },
    );

    testWidgets(
      'shift+arrow-down range selection only includes visible rows in visual order',
      (tester) async {
        controller.addEvent(GroupByColumnEvent(columnId: 1));
        await tester.pump();
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Fruit'));
        await tester.pump();
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Vegetable'));
        await tester.pump();

        controller.addEvent(FocusCellEvent(rowId: 1, columnId: 2));
        await tester.pump();

        controller.addEvent(
          NavigateCellEvent(CellNavDirection.down, extend: true),
        );
        await tester.pump();
        controller.addEvent(
          NavigateCellEvent(CellNavDirection.down, extend: true),
        );
        await tester.pump();

        expect(controller.state.selection.focusedCells, [
          '1.0_2',
          '3.0_2',
          '2.0_2',
        ]);
      },
    );

    testWidgets('rows inside a collapsed group are skipped entirely', (
      tester,
    ) async {
      controller.addEvent(GroupByColumnEvent(columnId: 1));
      await tester.pump();
      // Only expand Vegetable — Fruit stays collapsed (the new default).
      controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Vegetable'));
      await tester.pump();

      controller.addEvent(FocusCellEvent(rowId: 2, columnId: 2));
      await tester.pump();

      // Nothing above id 2: Fruit's rows are all hidden, so there's no
      // navigable row above it.
      controller.addEvent(NavigateCellEvent(CellNavDirection.up));
      await tester.pump();
      expect(controller.state.selection.activeCellId, '2.0_2');

      controller.addEvent(NavigateCellEvent(CellNavDirection.down));
      await tester.pump();
      expect(controller.state.selection.activeCellId, '4.0_2');
    });
  });

  group('Copy with grouping active', () {
    // Regression coverage: CopyCellsEvent sorted rows by their index in raw
    // `state.displayOrder`, same bug class as navigation — with grouping
    // active that doesn't match the visual (grouped-bucket) row order, so
    // copying scrambled-order focused cells produced CSV rows in the wrong
    // order even though the on-screen selection looked correct.
    testWidgets(
      'pasted rows follow visual grouped order, not raw displayOrder',
      (tester) async {
        final controller = DataGridController<TestRow>(
          initialColumns: _buildColumns(),
          initialRows: _buildRows(),
          sortDebounce: Duration.zero,
          filterDebounce: Duration.zero,
        );
        addTearDown(controller.dispose);

        final clipboardData = <String, dynamic>{};
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall call) async {
            if (call.method == 'Clipboard.setData') {
              clipboardData.addAll(
                Map<String, dynamic>.from(call.arguments as Map),
              );
            }
            return null;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
          ),
        );
        await tester.pumpAndSettle();

        controller.addEvent(GroupByColumnEvent(columnId: 1));
        await tester.pumpAndSettle();
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Fruit'));
        await tester.pumpAndSettle();
        controller.addEvent(ToggleGroupExpansionEvent(groupKey: '1:Vegetable'));
        await tester.pumpAndSettle();

        // Deliberately out of visual order (and out of raw displayOrder
        // too): row 2 (Carrot) is visually last among these three.
        controller.addEvent(SetFocusedCellsEvent(['3.0_2', '1.0_2', '2.0_2']));
        await tester.pumpAndSettle();

        controller.addEvent(CopyCellsEvent());
        await tester.pumpAndSettle();

        // Visual order is Apple (1), Banana (3), then Carrot (2) — not the
        // raw displayOrder sequence [1, 2, 3].
        expect(clipboardData['text'], 'Apple\nBanana\nCarrot');
      },
    );
  });
}
