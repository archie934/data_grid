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
  group('Editing Integration Tests', () {
    late DataGridController<TestRow> controller;

    setUp(() {
      controller = DataGridController<TestRow>(
        initialColumns: [
          DataGridColumn(id: 1, title: 'Name', width: 150, editable: true, filterable: false),
          DataGridColumn(id: 2, title: 'Age', width: 100, editable: true, filterable: false),
        ],
        initialRows: [
          TestRow(id: 1.0, name: 'Alice', age: 30),
          TestRow(id: 2.0, name: 'Bob', age: 25),
          TestRow(id: 3.0, name: 'Charlie', age: 35),
        ],
        cellValueAccessor: (row, col) {
          if (col.id == 1) return row.name;
          if (col.id == 2) return row.age.toString();
          return '';
        },
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('two taps on selected cell starts edit mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(
              controller: controller,
              rowHeight: 48.0,
              headerHeight: 48.0,
              cellBuilder: (row, columnId) {
                if (columnId == 1) return Text(row.name);
                if (columnId == 2) return Text(row.age.toString());
                return const Text('');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final aliceCell = find.text('Alice');
      expect(aliceCell, findsOneWidget);

      await tester.tap(aliceCell);
      await tester.pumpAndSettle();

      expect(controller.state.selection.isRowSelected(1.0), true);

      await tester.tap(aliceCell);
      await tester.pumpAndSettle();

      final editingTextField = find.byKey(const ValueKey('cell_editor_textfield'));
      expect(editingTextField, findsOneWidget);
      expect(controller.state.edit.isEditing, true);
    });

    testWidgets('Enter commits edit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(
              controller: controller,
              rowHeight: 48.0,
              headerHeight: 48.0,
              cellBuilder: (row, columnId) {
                if (columnId == 1) return Text(row.name);
                if (columnId == 2) return Text(row.age.toString());
                return const Text('');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1.0, 1);
      await tester.pumpAndSettle();

      final editingTextField = find.byKey(const ValueKey('cell_editor_textfield'));
      expect(editingTextField, findsOneWidget);

      await tester.enterText(editingTextField, 'NewName');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(editingTextField, findsNothing);
      expect(controller.state.edit.isEditing, false);
    });

    testWidgets('Escape cancels edit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(
              controller: controller,
              rowHeight: 48.0,
              headerHeight: 48.0,
              cellBuilder: (row, columnId) {
                if (columnId == 1) return Text(row.name);
                if (columnId == 2) return Text(row.age.toString());
                return const Text('');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1.0, 1);
      await tester.pumpAndSettle();

      final editingTextField = find.byKey(const ValueKey('cell_editor_textfield'));
      expect(editingTextField, findsOneWidget);

      await tester.enterText(editingTextField, 'NewName');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(editingTextField, findsNothing);
      expect(controller.state.edit.isEditing, false);
    });

    testWidgets('edit mode preserves focus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(
              controller: controller,
              rowHeight: 48.0,
              headerHeight: 48.0,
              cellBuilder: (row, columnId) {
                if (columnId == 1) return Text(row.name);
                if (columnId == 2) return Text(row.age.toString());
                return const Text('');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1.0, 1);
      await tester.pumpAndSettle();

      final editingTextField = find.byKey(const ValueKey('cell_editor_textfield'));
      expect(editingTextField, findsOneWidget);

      final textFieldWidget = tester.widget<TextField>(editingTextField);
      expect(textFieldWidget.autofocus, true);
    });

    testWidgets('starting edit on new cell auto-commits previous cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(
              controller: controller,
              rowHeight: 48.0,
              headerHeight: 48.0,
              cellBuilder: (row, columnId) {
                if (columnId == 1) return Text(row.name);
                if (columnId == 2) return Text(row.age.toString());
                return const Text('');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1.0, 1);
      await tester.pumpAndSettle();

      expect(controller.state.edit.isEditing, true);
      expect(controller.state.edit.isCellEditing(1.0, 1), true);

      final editingTextField = find.byKey(const ValueKey('cell_editor_textfield'));
      await tester.enterText(editingTextField, 'NewName');
      await tester.pumpAndSettle();

      controller.startEditCell(2.0, 1);
      await tester.pumpAndSettle();

      expect(controller.state.edit.isEditing, true);
      expect(controller.state.edit.isCellEditing(2.0, 1), true);
      expect(controller.state.edit.isCellEditing(1.0, 1), false);
    });

    testWidgets('only one cell can be in edit mode at a time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<TestRow>(
              controller: controller,
              rowHeight: 48.0,
              headerHeight: 48.0,
              cellBuilder: (row, columnId) {
                if (columnId == 1) return Text(row.name);
                if (columnId == 2) return Text(row.age.toString());
                return const Text('');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      controller.startEditCell(1.0, 1);
      await tester.pumpAndSettle();

      final editingTextField = find.byKey(const ValueKey('cell_editor_textfield'));
      expect(editingTextField, findsOneWidget);

      controller.startEditCell(1.0, 2);
      await tester.pumpAndSettle();

      expect(editingTextField, findsOneWidget);
      expect(controller.state.edit.isCellEditing(1.0, 2), true);
      expect(controller.state.edit.isCellEditing(1.0, 1), false);
    });
  });
}
