import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_grid/data_grid/data_grid.dart';

class TestRow extends DataGridRow {
  final String name;
  final int age;

  TestRow({required double id, required this.name, required this.age}) {
    this.id = id;
  }
}

void main() {
  group('DataGridCell', () {
    late DataGridController<TestRow> controller;
    late DataGridColumn column;

    setUp(() {
      column = DataGridColumn(id: 1, title: 'Name', width: 150);
      controller = DataGridController<TestRow>(
        initialColumns: [column],
        initialRows: [
          TestRow(id: 1.0, name: 'Alice', age: 30),
          TestRow(id: 2.0, name: 'Bob', age: 25),
        ],
        cellValueAccessor: (row, col) {
          if (col.id == 1) return row.name;
          return '';
        },
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders cell with custom builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice', age: 30),
              rowId: 1.0,
              column: column,
              rowIndex: 0,
              controller: controller,
              cellBuilder: (row, columnId) => Text(row.name),
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('shows selected state when row is selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice', age: 30),
              rowId: 1.0,
              column: column,
              rowIndex: 0,
              controller: controller,
              cellBuilder: (row, columnId) => Text(row.name),
            ),
          ),
        ),
      );

      controller.addEvent(SelectRowEvent(rowId: 1.0));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.ancestor(of: find.text('Alice'), matching: find.byType(Container)).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('enters edit mode on double tap for editable column', (tester) async {
      final editableColumn = DataGridColumn(id: 1, title: 'Name', width: 150, editable: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice', age: 30),
              rowId: 1.0,
              column: editableColumn,
              rowIndex: 0,
              controller: controller,
              cellBuilder: (row, columnId) => Text(row.name),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('commits edit on Enter key', (tester) async {
      final editableColumn = DataGridColumn(id: 1, title: 'Name', width: 150, editable: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice', age: 30),
              rowId: 1.0,
              column: editableColumn,
              rowIndex: 0,
              controller: controller,
              cellBuilder: (row, columnId) => Text(row.name),
            ),
          ),
        ),
      );

      controller.startEditCell(1.0, 1);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('cancels edit on Escape key', (tester) async {
      final editableColumn = DataGridColumn(id: 1, title: 'Name', width: 150, editable: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice', age: 30),
              rowId: 1.0,
              column: editableColumn,
              rowIndex: 0,
              controller: controller,
              cellBuilder: (row, columnId) => Text(row.name),
            ),
          ),
        ),
      );

      controller.startEditCell(1.0, 1);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('selects row on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridCell<TestRow>(
              row: TestRow(id: 1.0, name: 'Alice', age: 30),
              rowId: 1.0,
              column: column,
              rowIndex: 0,
              controller: controller,
              cellBuilder: (row, columnId) => Text(row.name),
            ),
          ),
        ),
      );

      expect(controller.state.selection.isRowSelected(1.0), false);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1.0), true);
    });

    testWidgets('alternates row background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DataGridCell<TestRow>(
                  row: TestRow(id: 1.0, name: 'Alice', age: 30),
                  rowId: 1.0,
                  column: column,
                  rowIndex: 0,
                  controller: controller,
                  cellBuilder: (row, columnId) => Text(row.name),
                ),
                DataGridCell<TestRow>(
                  row: TestRow(id: 2.0, name: 'Bob', age: 25),
                  rowId: 2.0,
                  column: column,
                  rowIndex: 1,
                  controller: controller,
                  cellBuilder: (row, columnId) => Text(row.name),
                ),
              ],
            ),
          ),
        ),
      );

      final containers = tester
          .widgetList<Container>(find.ancestor(of: find.byType(Text), matching: find.byType(Container)))
          .toList();

      expect(containers.length, greaterThanOrEqualTo(2));
    });
  });
}
