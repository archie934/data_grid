import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';

class _Row extends DataGridRow {
  final String label;
  final double contentHeight;

  _Row({required double id, required this.label, required this.contentHeight}) {
    this.id = id;
  }
}

/// Reports [contentHeight] as its natural height — used to give specific
/// rows deterministic, different intrinsic heights.
class _FixedHeightCell extends StatelessWidget {
  const _FixedHeightCell();

  @override
  Widget build(BuildContext context) {
    final scope = CellScope.of<_Row>(context);
    return SizedBox(width: double.infinity, height: scope.row.contentHeight);
  }
}

DataGridController<_Row> _makeController({
  required List<_Row> rows,
  required double estimatedHeight,
  required double maxHeight,
}) {
  final columns = [
    DataGridColumn<_Row>(id: 1, title: 'Label', width: 100, valueAccessor: (r) => r.label),
    DataGridColumn<_Row>(
      id: 2,
      title: 'Content',
      width: 100,
      cellWidget: const _FixedHeightCell(),
    ),
  ];
  return DataGridController<_Row>(
    initialColumns: columns,
    initialRows: rows,
    sortDebounce: Duration.zero,
    filterDebounce: Duration.zero,
  );
}

void main() {
  group('autoRowHeight', () {
    testWidgets(
      'a short row is not sized to match a taller sibling row '
      '(regression: default/Center cell widgets reporting maxHeight '
      'as their measured height regardless of content)',
      (tester) async {
        final rows = [
          _Row(id: 0, label: 'tall', contentHeight: 200),
          _Row(id: 1, label: 'short', contentHeight: 20),
          _Row(id: 2, label: 'short2', contentHeight: 20),
        ];
        final controller = _makeController(
          rows: rows,
          estimatedHeight: 48,
          maxHeight: 300,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                showPagination: false,
                // Large enough to keep all three rows built/measured at once.
                cacheExtent: 1000,
                autoRowHeight: const AutoRowHeight(
                  estimatedHeight: 48,
                  minHeight: 10,
                  maxHeight: 300,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // One extra pump lets the post-frame measurement-correction callback
        // (which applies the just-measured heights via setState) land.
        await tester.pump();
        await tester.pumpAndSettle();

        Size cellSize(double rowId, int columnId) {
          final finder = find.byKey(ValueKey('cell_${rowId}_$columnId'));
          expect(finder, findsOneWidget, reason: 'cell $rowId/$columnId should be built');
          return tester.getSize(finder);
        }

        final tallRowHeight = cellSize(0, 2).height;
        final shortRowHeight = cellSize(1, 2).height;
        final shortRow2Height = cellSize(2, 2).height;

        expect(
          tallRowHeight,
          closeTo(200, 1.0),
          reason: 'the tall row should grow to fit its 200px content',
        );
        // The short rows' "Content" cell only needs 20px, but the "Label"
        // column's default text cell in that same row has its own (larger,
        // theme-dependent) natural height, and row height = max across a
        // row's cells — so assert well below the tall row / maxHeight clamp
        // rather than pinning to the exact default-cell height.
        expect(
          shortRowHeight,
          lessThan(tallRowHeight / 2),
          reason:
              'the short rows must size to their own content, not to the '
              'tall sibling row (200px) or the maxHeight clamp (300px)',
        );
        expect(
          shortRow2Height,
          closeTo(shortRowHeight, 0.5),
          reason: 'two rows with identical content should measure identically',
        );

        // Every cell in a row shares that row's height (standard grid
        // semantics: row height = max intrinsic height across its cells).
        expect(cellSize(1, 1).height, closeTo(shortRowHeight, 0.5));
      },
    );

    testWidgets(
      'default (fixed-height) mode is unaffected: rows stay at the fixed '
      'row height regardless of cellWidget content',
      (tester) async {
        final rows = [
          _Row(id: 0, label: 'tall', contentHeight: 200),
          _Row(id: 1, label: 'short', contentHeight: 20),
        ];
        final controller = _makeController(
          rows: rows,
          estimatedHeight: 48,
          maxHeight: 300,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                showPagination: false,
                rowHeight: 48,
                // autoRowHeight intentionally omitted (default: null).
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final tallRowSize = tester.getSize(find.byKey(const ValueKey('cell_0.0_2')));
        final shortRowSize = tester.getSize(find.byKey(const ValueKey('cell_1.0_2')));

        expect(tallRowSize.height, closeTo(48, 0.5));
        expect(shortRowSize.height, closeTo(48, 0.5));
      },
    );

    group('measure ahead', () {
      Future<IndexedRowHeightDelegate> pumpGrid(
        WidgetTester tester, {
        required double measureAheadExtent,
      }) async {
        final rows = List.generate(
          500,
          (i) => _Row(
            id: i.toDouble(),
            label: 'row $i',
            contentHeight: i == 30 ? 120 : 20,
          ),
        );
        final controller = _makeController(
          rows: rows,
          estimatedHeight: 48,
          maxHeight: 300,
        );
        addTearDown(controller.dispose);
        final delegate = IndexedRowHeightDelegate();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                showPagination: false,
                cacheExtent: 0,
                autoRowHeight: AutoRowHeight(
                  estimatedHeight: 48,
                  minHeight: 10,
                  maxHeight: 300,
                  measureAheadExtent: measureAheadExtent,
                  delegate: delegate,
                ),
              ),
            ),
          ),
        );

        for (int i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        return delegate;
      }

      testWidgets('measures rows below the viewport while idle', (
        tester,
      ) async {
        final delegate = await pumpGrid(tester, measureAheadExtent: 2000);

        expect(delegate.isMeasured(30), isTrue);
        expect(delegate.heightOf(30), closeTo(120, 1.0));
        // Far beyond the look-ahead window (>= 4990px down even at minHeight).
        expect(delegate.isMeasured(499), isFalse);
      });

      testWidgets('measureAheadExtent: 0 disables it', (tester) async {
        final delegate = await pumpGrid(tester, measureAheadExtent: 0);

        expect(delegate.isMeasured(30), isFalse);
      });
    });

    testWidgets(
      'toggling autoRowHeight off and on repeatedly keeps rows laid out '
      '(regression: re-enabled delegate was never rebuilt because the '
      'structural-change refs still matched)',
      (tester) async {
        final rows = [
          for (int i = 0; i < 5; i++)
            _Row(id: i.toDouble(), label: 'r$i', contentHeight: 20),
        ];
        final controller = _makeController(
          rows: rows,
          estimatedHeight: 48,
          maxHeight: 300,
        );
        addTearDown(controller.dispose);

        Widget build(bool auto) => MaterialApp(
          home: Scaffold(
            body: DataGrid<_Row>(
              controller: controller,
              showPagination: false,
              cacheExtent: 1000,
              autoRowHeight: auto
                  ? const AutoRowHeight(
                      estimatedHeight: 48,
                      minHeight: 10,
                      maxHeight: 300,
                    )
                  : null,
            ),
          ),
        );

        Future<void> pumpGrid(bool auto) async {
          await tester.pumpWidget(build(auto));
          await tester.pumpAndSettle();
          await tester.pump();
          await tester.pumpAndSettle();
        }

        for (final auto in [true, false, true, false, true]) {
          await pumpGrid(auto);
          double? lastBottom;
          for (int i = 0; i < rows.length; i++) {
            final finder = find.byKey(ValueKey('cell_${i.toDouble()}_1'));
            expect(finder, findsOneWidget,
                reason: 'row $i should be built (auto=$auto)');
            final rect = tester.getRect(finder);
            expect(rect.height, greaterThan(0),
                reason: 'row $i must have a height (auto=$auto)');
            if (lastBottom != null) {
              expect(rect.top, closeTo(lastBottom, 0.5),
                  reason: 'row $i must sit directly below row ${i - 1} '
                      '(auto=$auto)');
            }
            lastBottom = rect.bottom;
          }
        }
      },
    );

    for (final rapid in [false, true]) {
      testWidgets(
        'toggling autoRowHeight many times (rapid=$rapid, paginated, '
        'like the example app) always leaves rows on screen',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          final rows = [
            for (int i = 0; i < 3000; i++)
              _Row(id: i.toDouble(), label: 'r$i', contentHeight: 20.0 + (i % 4) * 40),
          ];
          // Columns wide enough for the pagination bar to fit.
          final controller = DataGridController<_Row>(
            initialColumns: [
              DataGridColumn<_Row>(
                id: 1,
                title: 'Label',
                width: 400,
                valueAccessor: (r) => r.label,
              ),
              DataGridColumn<_Row>(
                id: 2,
                title: 'Content',
                width: 400,
                cellWidget: const _FixedHeightCell(),
              ),
            ],
            initialRows: rows,
            sortDebounce: Duration.zero,
            filterDebounce: Duration.zero,
          );
          addTearDown(controller.dispose);
          controller.enablePagination(true);

          Widget build(bool auto) => MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                cacheExtent: auto ? 800 : 0,
                autoRowHeight: auto
                    ? const AutoRowHeight(
                        estimatedHeight: 48,
                        minHeight: 40,
                        maxHeight: 260,
                      )
                    : null,
                autoHeaderHeight: auto ? const AutoHeaderHeight() : null,
              ),
            ),
          );

          await tester.pumpWidget(build(true));
          await tester.pumpAndSettle();

          bool auto = true;
          for (int toggle = 0; toggle < 12; toggle++) {
            auto = !auto;
            await tester.pumpWidget(build(auto));
            if (rapid) {
              await tester.pump(const Duration(milliseconds: 16));
            } else {
              for (int i = 0; i < 5; i++) {
                await tester.pump(const Duration(milliseconds: 50));
              }
            }
          }
          await tester.pumpAndSettle();

          for (int i = 0; i < 5; i++) {
            final finder = find.byKey(ValueKey('cell_${i.toDouble()}_1'));
            expect(finder, findsOneWidget, reason: 'row $i must be built');
            expect(tester.getRect(finder).height, greaterThan(0));
          }
        },
      );
    }

    testWidgets(
      'changing the AutoRowHeight config while enabled repopulates the '
      'delegate instead of keeping the old one',
      (tester) async {
        final rows = [
          for (int i = 0; i < 20; i++)
            _Row(id: i.toDouble(), label: 'r$i', contentHeight: 20),
        ];
        final controller = _makeController(
          rows: rows,
          estimatedHeight: 48,
          maxHeight: 300,
        );
        addTearDown(controller.dispose);
        final first = IndexedRowHeightDelegate();
        final second = IndexedRowHeightDelegate();

        Widget build(RowHeightDelegate delegate, double minHeight) =>
            MaterialApp(
              home: Scaffold(
                body: DataGrid<_Row>(
                  controller: controller,
                  showPagination: false,
                  cacheExtent: 1000,
                  autoRowHeight: AutoRowHeight(
                    estimatedHeight: 48,
                    minHeight: minHeight,
                    maxHeight: 300,
                    delegate: delegate,
                  ),
                ),
              ),
            );

        await tester.pumpWidget(build(first, 10));
        await tester.pumpAndSettle();
        expect(first.totalExtent, greaterThan(0));

        // Swapped delegate: the new one must be populated.
        await tester.pumpWidget(build(second, 10));
        await tester.pumpAndSettle();
        expect(second.totalExtent, greaterThan(0));
        expect(find.byKey(const ValueKey('cell_0.0_1')), findsOneWidget);

        // Same delegate, new clamp: re-measured under the new minimum.
        await tester.pumpWidget(build(second, 90));
        await tester.pumpAndSettle();
        await tester.pump();
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byKey(const ValueKey('cell_0.0_1')));
        expect(rect.height, closeTo(90, 0.5));
      },
    );
  });
}
