import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

/// Cells must always show what their `valueAccessor` returns *now*. Two ways
/// that can silently break, both covered here:
///
///  1. **Derived columns after an edit.** The edit fast path mutates the row in
///     place and notifies by callback instead of replacing `rowsById` (see
///     AGENTS.md). It used to notify only the *edited cell*, so a column
///     reading a field the setter had recalculated — `total`, below, from
///     `quantity` — kept showing its previous value until something unrelated
///     rebuilt it.
///  2. **Cells whose element was reused across a scroll jump.** Jump frames key
///     cells by viewport slot so elements are updated rather than re-inflated;
///     an update that failed to re-read the row would show the old row's text.
class _Product extends DataGridRow {
  int quantity;
  double price;
  double total;

  _Product({required double id, required this.quantity, required this.price})
    : total = quantity * price {
    this.id = id;
  }

  void updateTotal() => total = quantity * price;
}

void main() {
  DataGridController<_Product> makeController(int rows) =>
      DataGridController<_Product>(
        initialColumns: [
          DataGridColumn<_Product>(
            id: 0,
            title: 'ID',
            width: 100,
            editable: false,
            filterable: false,
            valueAccessor: (row) => 'ID${row.id.toInt()}',
          ),
          DataGridColumn<_Product>(
            id: 1,
            title: 'Quantity',
            width: 120,
            editable: true,
            filterable: false,
            valueAccessor: (row) => row.quantity.toString(),
            cellValueSetter: (row, value) {
              row.quantity = int.tryParse(value.toString()) ?? 0;
              // The setter recalculates a field a *different* column reads.
              row.updateTotal();
            },
          ),
          DataGridColumn<_Product>(
            id: 2,
            title: 'Total',
            width: 120,
            editable: false,
            filterable: false,
            valueAccessor: (row) => row.total.toStringAsFixed(2),
          ),
        ],
        initialRows: List.generate(
          rows,
          (i) => _Product(id: i.toDouble(), quantity: 2, price: 10.0),
        ),
        sortDebounce: Duration.zero,
        filterDebounce: Duration.zero,
      );

  Widget grid(DataGridController<_Product> c) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 600,
        height: 600,
        child: DataGrid<_Product>(
          controller: c,
          showPagination: false,
          rowHeight: 48,
          cacheExtent: 400,
        ),
      ),
    ),
  );

  testWidgets('a derived column refreshes when another column is edited', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = makeController(50);
    addTearDown(controller.dispose);
    await tester.pumpWidget(grid(controller));
    await tester.pumpAndSettle();

    // quantity 2 × price 10 = 20.00
    expect(find.text('20.00'), findsWidgets);

    await tester.runAsync(() async {
      controller.updateCell(0.0, 1, '7');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    // The Total cell for row 0 must have re-read row.total (7 × 10 = 70.00)
    // without anything else forcing it to rebuild.
    expect(
      find.text('70.00'),
      findsOneWidget,
      reason:
          'the Total column reads a field the Quantity setter recalculated, so '
          'it must be told to re-read when that row is mutated',
    );
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('an unrelated column in the edited row does not rebuild', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = makeController(50);
    addTearDown(controller.dispose);
    await tester.pumpWidget(grid(controller));
    await tester.pumpAndSettle();

    // The ID column reads nothing the Quantity setter touches, so widening the
    // notification to the row must not cost it a rebuild — the per-cell value
    // diff is what keeps an edit from rebuilding every column of the row.
    // Widget instance, not element: an Element survives a rebuild, so only the
    // widget it holds can prove whether build() ran again.
    expect(find.text('ID0'), findsOneWidget);
    final idTextBefore = tester.widget<Text>(find.text('ID0'));

    await tester.runAsync(() async {
      controller.updateCell(0.0, 1, '9');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(find.text('ID0')), same(idTextBefore));
    expect(find.text('90.00'), findsOneWidget);
  });

  testWidgets('refreshCells re-reads values the grid cannot diff', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = makeController(50);
    addTearDown(controller.dispose);
    await tester.pumpWidget(grid(controller));
    await tester.pumpAndSettle();

    expect(find.text('20.00'), findsWidgets);

    // Mutate the row directly, the way application code outside the grid's
    // edit path would. Nothing is emitted, so nothing can know to re-read.
    final row = controller.state.rowsById[0.0]!;
    row.quantity = 5;
    row.updateTotal();
    await tester.pumpAndSettle();

    expect(
      find.text('50.00'),
      findsNothing,
      reason: 'an unannounced mutation is invisible to the grid by design',
    );

    await tester.runAsync(() async {
      controller.refreshCells(rowIds: [0.0]);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('50.00'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('cells show the right row after a scroll jump reuses elements', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = makeController(100000);
    addTearDown(controller.dispose);
    await tester.pumpWidget(grid(controller));
    await tester.pumpAndSettle();

    expect(find.text('ID0'), findsOneWidget);

    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(
      pointer.hover(tester.getCenter(find.byType(DataGrid<_Product>))),
    );
    await tester.pump();

    // Two consecutive jumps: the first switches the quadrants into slot-keyed
    // mode, the second actually reuses the elements it created.
    for (final target in [20000, 40000]) {
      await tester.sendEventToBinding(
        pointer.scroll(Offset(0, target * 48.0 - controllerOffset(tester))),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.text('ID0'),
        findsNothing,
        reason: 'a reused element must not keep showing its previous row',
      );
      // The row at the top of the viewport must be the one the offset says.
      expect(find.text('ID$target'), findsOneWidget);
    }
  });
}

/// Current vertical offset of the grid under test, read off its scrollbar's
/// controller so the test can express jumps in absolute row terms.
double controllerOffset(WidgetTester tester) {
  final scrollbar = tester.widget<VerticalDataGridScrollbar>(
    find.byType(VerticalDataGridScrollbar),
  );
  return scrollbar.controller.hasClients ? scrollbar.controller.offset : 0.0;
}
