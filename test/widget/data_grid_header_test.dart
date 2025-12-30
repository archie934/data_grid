import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';

class TestRow extends DataGridRow {
  final String name;

  TestRow({required double id, required this.name}) {
    this.id = id;
  }
}

void main() {
  group('DataGridHeaderCell', () {
    testWidgets('renders column title', (tester) async {
      final column = DataGridColumn<TestRow>(id: 1, title: 'Test Column', width: 150, valueAccessor: (row) => row.name);
      final sortState = SortState.initial();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(column: column, sortState: sortState, onSort: (_) {}, onResize: (_) {}),
          ),
        ),
      );

      expect(find.text('Test Column'), findsOneWidget);
    });

    testWidgets('shows ascending sort icon when sorted ascending', (tester) async {
      final column = DataGridColumn<TestRow>(id: 1, title: 'Test Column', width: 150, valueAccessor: (row) => row.name);
      final sortState = SortState(sortColumn: SortColumn(columnId: 1, direction: SortDirection.ascending));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(column: column, sortState: sortState, onSort: (_) {}, onResize: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('shows descending sort icon when sorted descending', (tester) async {
      final column = DataGridColumn<TestRow>(id: 1, title: 'Test Column', width: 150, valueAccessor: (row) => row.name);
      final sortState = SortState(sortColumn: SortColumn(columnId: 1, direction: SortDirection.descending));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(column: column, sortState: sortState, onSort: (_) {}, onResize: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('cycles through sort states on tap', (tester) async {
      final column = DataGridColumn<TestRow>(id: 1, title: 'Test Column', width: 150, valueAccessor: (row) => row.name);
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
              sortState: SortState(sortColumn: SortColumn(columnId: 1, direction: SortDirection.ascending)),
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
              sortState: SortState(sortColumn: SortColumn(columnId: 1, direction: SortDirection.descending)),
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
      final column = DataGridColumn<TestRow>(id: 1, title: 'Test Column', width: 150, valueAccessor: (row) => row.name);
      final sortState = SortState(sortColumn: SortColumn(columnId: 2, direction: SortDirection.ascending));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(column: column, sortState: sortState, onSort: (_) {}, onResize: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('triggers resize on drag', (tester) async {
      final column = DataGridColumn<TestRow>(id: 1, title: 'Test Column', width: 150, valueAccessor: (row) => row.name);
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

      final resizeHandle = find.descendant(of: find.byType(GestureDetector), matching: find.byType(MouseRegion));

      expect(resizeHandle, findsOneWidget);

      await tester.drag(resizeHandle, const Offset(50, 0));
      await tester.pump();

      expect(resizeDelta, isNotNull);
    });

    testWidgets('shows resize cursor on hover', (tester) async {
      final column = DataGridColumn<TestRow>(id: 1, title: 'Test Column', width: 150, valueAccessor: (row) => row.name);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGridHeaderCell(column: column, sortState: SortState.initial(), onSort: (_) {}, onResize: (_) {}),
          ),
        ),
      );

      final mouseRegion = tester.widget<MouseRegion>(
        find.descendant(of: find.byType(GestureDetector), matching: find.byType(MouseRegion)),
      );

      expect(mouseRegion.cursor, SystemMouseCursors.resizeColumn);
    });
  });
}
