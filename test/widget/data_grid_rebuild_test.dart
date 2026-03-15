import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

/// Minimal row type for rebuild tests.
class TestRow extends DataGridRow {
  final String name;
  final int value;

  TestRow({required double id, required this.name, required this.value}) {
    this.id = id;
  }
}

/// Stream subscriptions in DataGridCell fire synchronously (rxdart BehaviorSubject
/// is synchronous). setState is called before this helper is reached.
/// pump(1ms) advances the fake clock by 1 ms — enough to render dirty elements
/// without triggering the 16 ms StreamBuilder debounce.
Future<void> waitForAsync(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1));
}

/// Builds a column whose [valueAccessor] increments [counter] on each call.
/// Since [valueAccessor] is invoked inside [DataGridCell.build()], the counter
/// precisely counts how many times that column's cells rebuilt.
DataGridColumn<TestRow> _countingColumn({
  required int id,
  required String title,
  required double width,
  required void Function() onBuild,
  bool editable = false,
}) {
  return DataGridColumn<TestRow>(
    id: id,
    title: title,
    width: width,
    editable: editable,
    valueAccessor: (row) {
      onBuild();
      return row.name;
    },
  );
}

void main() {
  group('Cell rebuild performance', () {
    testWidgets(
      'selecting a row rebuilds only that row\'s cells, not all visible cells',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        int buildCount = 0;

        final rows = List.generate(
          20,
          (i) => TestRow(id: i.toDouble(), name: 'Row $i', value: i),
        );

        final controller = DataGridController<TestRow>(
          initialColumns: [
            _countingColumn(
              id: 1,
              title: 'Name',
              width: 200,
              onBuild: () => buildCount++,
            ),
            _countingColumn(
              id: 2,
              title: 'Value',
              width: 150,
              onBuild: () => buildCount++,
            ),
          ],
          initialRows: rows,
        );
        addTearDown(controller.dispose);
        controller.setSelectionMode(SelectionMode.multiple);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
          ),
        );
        await tester.pumpAndSettle();

        // How many data cells are visible depends on viewport, but must be > 2
        // (otherwise the test wouldn't prove anything).
        final visibleCellBuilds = buildCount;
        expect(
          visibleCellBuilds,
          greaterThan(2),
          reason: 'Sanity check: multiple rows must be visible initially',
        );

        buildCount = 0; // Reset after initial render

        // Select row whose id = 3
        controller.addEvent(SelectRowEvent(rowId: 3));
        await waitForAsync(tester);

        // With the fix: only the 2 data cells of row 3 rebuild (1 per column).
        // Without the fix: all visible cells rebuild (visibleCellBuilds total).
        expect(
          buildCount,
          equals(2),
          reason:
              'Only the selected row\'s cells should rebuild (1 per data column), '
              'not all $visibleCellBuilds visible cells',
        );
      },
    );

    testWidgets('deselecting a row rebuilds only that row\'s cells', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      int buildCount = 0;

      final rows = List.generate(
        20,
        (i) => TestRow(id: i.toDouble(), name: 'Row $i', value: i),
      );

      final controller = DataGridController<TestRow>(
        initialColumns: [
          _countingColumn(
            id: 1,
            title: 'Name',
            width: 300,
            onBuild: () => buildCount++,
          ),
        ],
        initialRows: rows,
      );
      addTearDown(controller.dispose);
      controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DataGrid<TestRow>(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      // Select row 5
      controller.addEvent(SelectRowEvent(rowId: 5));
      await waitForAsync(tester);

      buildCount = 0; // Reset — we only care about the deselection rebuild

      controller.addEvent(ClearSelectionEvent());
      await waitForAsync(tester);

      // Only row 5's 1 cell (1 column) should rebuild to clear the highlight.
      expect(
        buildCount,
        equals(1),
        reason: 'Only the deselected row\'s cells should rebuild',
      );
    });
  });
}
