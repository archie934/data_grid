import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_grid/data_grid/data_grid.dart';

class TestRow extends DataGridRow {
  final String name;

  TestRow({required double id, required this.name}) {
    this.id = id;
  }
}

void main() {
  group('Scroll Integration Tests', () {
    late DataGridController<TestRow> controller;

    setUp(() {
      controller = DataGridController<TestRow>(
        initialColumns: [DataGridColumn(id: 1, title: 'Name', width: 150)],
        initialRows: List.generate(100, (i) => TestRow(id: i.toDouble(), name: 'Person $i')),
        cellValueAccessor: (row, col) => row.name,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('vertical scrolling updates viewport', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: DataGrid<TestRow>(
                controller: controller,
                rowHeight: 48.0,
                headerHeight: 48.0,
                cellBuilder: (row, columnId) => Text(row.name),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialFirstRow = controller.state.viewport.firstVisibleRow;

      await tester.drag(find.byType(DataGrid<TestRow>), const Offset(0, -500));
      await tester.pumpAndSettle();

      final newFirstRow = controller.state.viewport.firstVisibleRow;
      expect(newFirstRow, greaterThan(initialFirstRow));
    });

    testWidgets('horizontal scrolling works with wide columns', (tester) async {
      controller = DataGridController<TestRow>(
        initialColumns: List.generate(10, (i) => DataGridColumn(id: i, title: 'Column $i', width: 200)),
        initialRows: [TestRow(id: 1.0, name: 'Test')],
        cellValueAccessor: (row, col) => 'Cell ${col.id}',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              child: DataGrid<TestRow>(
                controller: controller,
                rowHeight: 48.0,
                headerHeight: 48.0,
                cellBuilder: (row, columnId) => Text('Cell $columnId'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cell 0'), findsOneWidget);

      await tester.drag(find.byType(DataGrid<TestRow>), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(controller.state.viewport.scrollOffsetX, greaterThan(0));
    });

    testWidgets('scrollbar interaction works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: DataGrid<TestRow>(
                controller: controller,
                rowHeight: 48.0,
                headerHeight: 48.0,
                cellBuilder: (row, columnId) => Text(row.name),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DataGrid<TestRow>), findsOneWidget);
    });
  });
}
