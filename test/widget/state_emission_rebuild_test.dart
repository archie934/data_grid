import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';

/// Guards the identity contract the whole render path depends on.
///
/// The quadrants reuse cell widget instances out of `_cellCache`, and clear
/// that cache when `rows`/`rowsById`/`columns` change **identity**. So anything
/// that hands the body a fresh-but-equivalent list on every state emission
/// silently makes the cache cold and rebuilds every visible cell.
///
/// Regression target: `computeDisplayRows` allocated a new `List` of new
/// `GridDataRow`s per emission, and `DataGridState.effectiveColumns` allocated
/// a new list (plus a new selection column) per access under multi-select.
class _Row extends DataGridRow {
  final String name;
  _Row({required double id, required this.name}) {
    this.id = id;
  }
}

void main() {
  /// Builds a grid whose cells count their own builds via `valueAccessor`
  /// (which runs inside `DataGridCell.build`).
  ({DataGridController<_Row> controller, Map<String, int> counts}) makeGrid({
    int rowCount = 60,
    int colCount = 6,
  }) {
    final counts = <String, int>{};
    final controller = DataGridController<_Row>(
      initialColumns: [
        for (int c = 1; c <= colCount; c++)
          DataGridColumn<_Row>(
            id: c,
            title: 'C$c',
            width: 120,
            filterable: false,
            valueAccessor: (row) {
              final key = '${row.id}_$c';
              counts[key] = (counts[key] ?? 0) + 1;
              return row.name;
            },
          ),
      ],
      initialRows: List.generate(
        rowCount,
        (i) => _Row(id: i.toDouble(), name: 'R$i'),
      ),
      sortDebounce: Duration.zero,
      filterDebounce: Duration.zero,
    );
    return (controller: controller, counts: counts);
  }

  Widget wrap(DataGridController<_Row> controller) => MaterialApp(
    home: Scaffold(
      body: DataGrid<_Row>(
        controller: controller,
        showPagination: false,
        rowHeight: 40,
        cacheExtent: 0,
      ),
    ),
  );

  int totalBuilds(Map<String, int> before, Map<String, int> after) {
    int total = 0;
    for (final entry in after.entries) {
      final delta = entry.value - (before[entry.key] ?? 0);
      if (delta > 0) total += delta;
    }
    return total;
  }

  group('state emissions do not rebuild unaffected cells', () {
    testWidgets(
      'an emission that changes nothing visible rebuilds zero cells '
      '(regression: computeDisplayRows returned a fresh list per emission, so '
      'the quadrants\' identity check cleared _cellCache every time)',
      (tester) async {
        tester.view.physicalSize = const Size(900, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final g = makeGrid();
        addTearDown(g.controller.dispose);

        await tester.pumpWidget(wrap(g.controller));
        await tester.pumpAndSettle();

        final before = Map<String, int>.from(g.counts);

        // A state transition that touches no visible row and no column:
        // totalItems is metadata no cell reads. The grid must re-emit, but
        // nothing the cells depend on has changed.
        g.controller.setTotalItems(1234);
        await tester.pumpAndSettle();
        g.controller.setTotalItems(4321);
        await tester.pumpAndSettle();

        expect(
          totalBuilds(before, g.counts),
          0,
          reason:
              'No visible cell may rebuild for a state change it does not '
              'depend on. Got ${totalBuilds(before, g.counts)} rebuilds.',
        );
      },
    );

    testWidgets('selecting an off-screen row rebuilds no visible cell', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final g = makeGrid(rowCount: 400);
      addTearDown(g.controller.dispose);
      // Without this the event is a no-op and the test proves nothing.
      g.controller.setSelectionMode(SelectionMode.multiple);

      await tester.pumpWidget(wrap(g.controller));
      await tester.pumpAndSettle();

      final before = Map<String, int>.from(g.counts);

      // Row 399 is far outside the viewport (cacheExtent: 0).
      g.controller.addEvent(SelectRowEvent(rowId: 399.0));
      await tester.pumpAndSettle();
      expect(
        g.controller.state.selection.selectedRowIds,
        contains(399.0),
        reason: 'sanity: the selection actually happened',
      );

      expect(
        totalBuilds(before, g.counts),
        0,
        reason:
            'Selecting an off-screen row must not rebuild visible cells. Got '
            '${totalBuilds(before, g.counts)}.',
      );
    });

    testWidgets(
      'the same holds under multi-select '
      '(regression: effectiveColumns allocated a new list per access, so the '
      'columns identity check also failed every emission)',
      (tester) async {
        tester.view.physicalSize = const Size(900, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final g = makeGrid(rowCount: 400);
        addTearDown(g.controller.dispose);
        g.controller.setSelectionMode(SelectionMode.multiple);

        await tester.pumpWidget(wrap(g.controller));
        await tester.pumpAndSettle();

        final before = Map<String, int>.from(g.counts);

        g.controller.setTotalItems(1234);
        await tester.pumpAndSettle();
        g.controller.setTotalItems(4321);
        await tester.pumpAndSettle();

        expect(
          totalBuilds(before, g.counts),
          0,
          reason:
              'Multi-select must not make every emission rebuild the '
              'viewport. Got ${totalBuilds(before, g.counts)}.',
        );
      },
    );
  });
}
