import 'package:flutter/material.dart';
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
  group('Selection Integration Tests', () {
    late DataGridController<TestRow> controller;

    setUp(() {
      controller = DataGridController<TestRow>(
        initialColumns: [
          DataGridColumn(id: 1, title: 'Name', width: 150),
          DataGridColumn(id: 2, title: 'Age', width: 100),
        ],
        initialRows: List.generate(20, (i) => TestRow(id: i.toDouble(), name: 'Person $i', age: 20 + i)),
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

    testWidgets('maintains selection while scrolling', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

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

      controller.addEvent(SelectRowEvent(rowId: 1.0, multiSelect: true));
      controller.addEvent(SelectRowEvent(rowId: 2.0, multiSelect: true));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.contains(1.0), true);
      expect(controller.state.selection.selectedRowIds.contains(2.0), true);

      await tester.drag(find.byType(DataGrid<TestRow>), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.contains(1.0), true);
      expect(controller.state.selection.selectedRowIds.contains(2.0), true);
    });

    testWidgets('select all works with checkbox header', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

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

      final headerCheckboxes = find.byType(Checkbox);
      expect(headerCheckboxes, findsWidgets);

      await tester.tap(headerCheckboxes.first);
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.isNotEmpty, true);
    });

    testWidgets('individual row selection in multi-select mode', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);

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

      final checkboxes = find.byType(Checkbox);
      final rowCheckboxes = checkboxes.evaluate().skip(1).take(3).toList();

      for (var element in rowCheckboxes) {
        await tester.tap(find.byWidget(element.widget));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.length, greaterThanOrEqualTo(3));
    });

    testWidgets('clear selection works', (tester) async {
      controller.setSelectionMode(SelectionMode.multiple);
      controller.addEvent(SelectRowEvent(rowId: 1.0, multiSelect: true));
      controller.addEvent(SelectRowEvent(rowId: 2.0, multiSelect: true));

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

      expect(controller.state.selection.selectedRowIds.isNotEmpty, true);

      controller.addEvent(ClearSelectionEvent());
      await tester.pumpAndSettle();

      expect(controller.state.selection.selectedRowIds.isEmpty, true);
    });
  });
}
