import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_header_viewport.dart';

class TestRow extends DataGridRow {
  final String name;

  TestRow({required double id, required this.name}) {
    this.id = id;
  }
}

void main() {
  group('DataGridHeaderCell', () {
    testWidgets('renders column title', (tester) async {
      final column = DataGridColumn<TestRow>(
        id: 1,
        title: 'Test Column',
        width: 150,
        valueAccessor: (row) => row.name,
      );
      final sortState = SortState.initial();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: sortState,
              onSort: (_) {},
              onResize: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Column'), findsOneWidget);
    });

    testWidgets('shows ascending sort icon when sorted ascending', (
      tester,
    ) async {
      final column = DataGridColumn<TestRow>(
        id: 1,
        title: 'Test Column',
        width: 150,
        valueAccessor: (row) => row.name,
      );
      final sortState = SortState(
        sortColumn: SortColumn(columnId: 1, direction: SortDirection.ascending),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: sortState,
              onSort: (_) {},
              onResize: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('shows descending sort icon when sorted descending', (
      tester,
    ) async {
      final column = DataGridColumn<TestRow>(
        id: 1,
        title: 'Test Column',
        width: 150,
        valueAccessor: (row) => row.name,
      );
      final sortState = SortState(
        sortColumn: SortColumn(
          columnId: 1,
          direction: SortDirection.descending,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: sortState,
              onSort: (_) {},
              onResize: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('cycles through sort states on tap', (tester) async {
      final column = DataGridColumn<TestRow>(
        id: 1,
        title: 'Test Column',
        width: 150,
        valueAccessor: (row) => row.name,
      );
      SortDirection? lastDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: SortState.initial(),
              onSort: (direction) {
                lastDirection = direction;
              },
              onResize: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(lastDirection, SortDirection.ascending);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: SortState(
                sortColumn: SortColumn(
                  columnId: 1,
                  direction: SortDirection.ascending,
                ),
              ),
              onSort: (direction) {
                lastDirection = direction;
              },
              onResize: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(lastDirection, SortDirection.descending);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: SortState(
                sortColumn: SortColumn(
                  columnId: 1,
                  direction: SortDirection.descending,
                ),
              ),
              onSort: (direction) {
                lastDirection = direction;
              },
              onResize: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(lastDirection, null);
    });

    testWidgets('does not show sort icon for different column', (tester) async {
      final column = DataGridColumn<TestRow>(
        id: 1,
        title: 'Test Column',
        width: 150,
        valueAccessor: (row) => row.name,
      );
      final sortState = SortState(
        sortColumn: SortColumn(columnId: 2, direction: SortDirection.ascending),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: sortState,
              onSort: (_) {},
              onResize: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('triggers resize on drag', (tester) async {
      final column = DataGridColumn<TestRow>(
        id: 1,
        title: 'Test Column',
        width: 150,
        valueAccessor: (row) => row.name,
      );
      double? resizeDelta;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: SortState.initial(),
              onSort: (_) {},
              onResize: (delta) {
                resizeDelta = delta;
              },
            ),
          ),
        ),
      );

      final resizeHandle = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(MouseRegion),
      );

      expect(resizeHandle, findsOneWidget);

      await tester.drag(resizeHandle, const Offset(50, 0));
      await tester.pump();

      expect(resizeDelta, isNotNull);
    });

    testWidgets('shows resize cursor on hover', (tester) async {
      final column = DataGridColumn<TestRow>(
        id: 1,
        title: 'Test Column',
        width: 150,
        valueAccessor: (row) => row.name,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(
              column: column,
              sortState: SortState.initial(),
              onSort: (_) {},
              onResize: (_) {},
            ),
          ),
        ),
      );

      final mouseRegion = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(MouseRegion),
        ),
      );

      expect(mouseRegion.cursor, SystemMouseCursors.resizeColumn);
    });
  });

  group('DataGridHeaderViewport', () {
    testWidgets('renders all unpinned columns', (tester) async {
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Col1',
          width: 100,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Col2',
          width: 100,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 3,
          title: 'Col3',
          width: 100,
          valueAccessor: (r) => r.name,
        ),
      ];
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 50,
              child: DataGridHeaderViewport<TestRow>(
                columns: columns,
                horizontalController: scrollController,
                pinnedBackgroundColor: Colors.white,
                childColumnIds: [1, 2, 3],
                children: [
                  for (var col in columns)
                    Container(key: ValueKey(col.id), child: Text(col.title)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Col1'), findsOneWidget);
      expect(find.text('Col2'), findsOneWidget);
      expect(find.text('Col3'), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets('renders pinned columns at fixed position', (tester) async {
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Pinned',
          width: 100,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Unpinned1',
          width: 100,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 3,
          title: 'Unpinned2',
          width: 100,
          valueAccessor: (r) => r.name,
        ),
      ];
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 50,
              child: DataGridHeaderViewport<TestRow>(
                columns: columns,
                horizontalController: scrollController,
                pinnedBackgroundColor: Colors.white,
                childColumnIds: [2, 3, 1],
                children: [
                  Container(
                    key: const ValueKey(2),
                    child: const Text('Unpinned1'),
                  ),
                  Container(
                    key: const ValueKey(3),
                    child: const Text('Unpinned2'),
                  ),
                  Container(
                    key: const ValueKey(1),
                    child: const Text('Pinned'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('Unpinned1'), findsOneWidget);
      expect(find.text('Unpinned2'), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets('pinned column remains visible after horizontal scroll', (
      tester,
    ) async {
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Pinned',
          width: 100,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Unpinned1',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 3,
          title: 'Unpinned2',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
      ];
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 50,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 500,
                  child: DataGridHeaderViewport<TestRow>(
                    columns: columns,
                    horizontalController: scrollController,
                    pinnedBackgroundColor: Colors.white,
                    childColumnIds: [2, 3, 1],
                    children: [
                      Container(
                        key: const ValueKey(2),
                        child: const Text('Unpinned1'),
                      ),
                      Container(
                        key: const ValueKey(3),
                        child: const Text('Unpinned2'),
                      ),
                      Container(
                        key: const ValueKey(1),
                        child: const Text('Pinned'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pinned'), findsOneWidget);

      scrollController.jumpTo(100);
      await tester.pump();

      expect(find.text('Pinned'), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets('handles multiple pinned columns', (tester) async {
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Pinned1',
          width: 80,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Pinned2',
          width: 80,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 3,
          title: 'Unpinned',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
      ];
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 50,
              child: DataGridHeaderViewport<TestRow>(
                columns: columns,
                horizontalController: scrollController,
                pinnedBackgroundColor: Colors.white,
                childColumnIds: [3, 1, 2],
                children: [
                  Container(
                    key: const ValueKey(3),
                    child: const Text('Unpinned'),
                  ),
                  Container(
                    key: const ValueKey(1),
                    child: const Text('Pinned1'),
                  ),
                  Container(
                    key: const ValueKey(2),
                    child: const Text('Pinned2'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pinned1'), findsOneWidget);
      expect(find.text('Pinned2'), findsOneWidget);
      expect(find.text('Unpinned'), findsOneWidget);

      scrollController.dispose();
    });

    testWidgets('hit test works on pinned columns', (tester) async {
      var tapped = false;
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Pinned',
          width: 100,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Unpinned',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
      ];
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 50,
              child: DataGridHeaderViewport<TestRow>(
                columns: columns,
                horizontalController: scrollController,
                pinnedBackgroundColor: Colors.white,
                childColumnIds: [2, 1],
                children: [
                  Container(
                    key: const ValueKey(2),
                    child: const Text('Unpinned'),
                  ),
                  GestureDetector(
                    key: const ValueKey(1),
                    onTap: () => tapped = true,
                    child: const Text('Pinned'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pinned'));
      await tester.pump();

      expect(tapped, isTrue);

      scrollController.dispose();
    });

    testWidgets('hit test works on unpinned columns', (tester) async {
      var tapped = false;
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Pinned',
          width: 100,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Unpinned',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
      ];
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 50,
              child: DataGridHeaderViewport<TestRow>(
                columns: columns,
                horizontalController: scrollController,
                pinnedBackgroundColor: Colors.white,
                childColumnIds: [2, 1],
                children: [
                  GestureDetector(
                    key: const ValueKey(2),
                    onTap: () => tapped = true,
                    child: const Text('Unpinned'),
                  ),
                  Container(
                    key: const ValueKey(1),
                    child: const Text('Pinned'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Unpinned'));
      await tester.pump();

      expect(tapped, isTrue);

      scrollController.dispose();
    });
  });

  group('DataGrid with pinned columns', () {
    testWidgets('header displays pinned and unpinned columns correctly', (
      tester,
    ) async {
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Pinned',
          width: 100,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Name',
          width: 150,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 3,
          title: 'Other',
          width: 150,
          valueAccessor: (r) => r.name,
        ),
      ];
      final rows = [TestRow(id: 1, name: 'Alice'), TestRow(id: 2, name: 'Bob')];
      final controller = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 300,
              child: DataGrid<TestRow>(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('pinned column header stays visible after scroll', (
      tester,
    ) async {
      final columns = [
        DataGridColumn<TestRow>(
          id: 1,
          title: 'Pinned',
          width: 100,
          pinned: true,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 2,
          title: 'Col2',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 3,
          title: 'Col3',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
        DataGridColumn<TestRow>(
          id: 4,
          title: 'Col4',
          width: 200,
          valueAccessor: (r) => r.name,
        ),
      ];
      final rows = [TestRow(id: 1, name: 'Test')];
      final controller = DataGridController<TestRow>(
        initialColumns: columns,
        initialRows: rows,
      );
      final scrollController = GridScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: DataGrid<TestRow>(
                controller: controller,
                scrollController: scrollController,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pinned'), findsOneWidget);

      scrollController.horizontalController.jumpTo(200);
      await tester.pump();

      expect(find.text('Pinned'), findsOneWidget);

      controller.dispose();
      scrollController.dispose();
    });
  });
}
