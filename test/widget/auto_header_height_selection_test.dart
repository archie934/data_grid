import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_header_viewport.dart';

class _Row extends DataGridRow {
  final String name;
  _Row({required double id, required this.name}) {
    this.id = id;
  }
}

void main() {
  group('autoHeaderHeight with the multi-select column', () {
    testWidgets(
      'switching to multi-select does not change the header height '
      '(regression: the selection column\'s header was SizedBox.expand, which '
      'resolves to AutoHeaderHeight.maxHeight under the loose measurement '
      'pass, and _measureAutoHeight takes the max across cells)',
      (tester) async {
        tester.view.physicalSize = const Size(900, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = DataGridController<_Row>(
          initialColumns: [
            DataGridColumn<_Row>(
              id: 1,
              title: 'Name',
              width: 200,
              // No filter row: it renders a second DataGridHeaderViewport,
              // and this test measures the header row specifically.
              filterable: false,
              valueAccessor: (r) => r.name,
            ),
            DataGridColumn<_Row>(
              id: 2,
              title: 'Other',
              width: 200,
              // No filter row: it renders a second DataGridHeaderViewport,
              // and this test measures the header row specifically.
              filterable: false,
              valueAccessor: (r) => r.name,
            ),
          ],
          initialRows: List.generate(
            20,
            (i) => _Row(id: i.toDouble(), name: 'R$i'),
          ),
          sortDebounce: Duration.zero,
          filterDebounce: Duration.zero,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                showPagination: false,
                cacheExtent: 400,
                autoHeaderHeight: const AutoHeaderHeight(
                  estimatedHeight: 48,
                  minHeight: 20,
                  maxHeight: 300,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        double headerHeight() => tester
            .getSize(find.byType(DataGridHeaderViewport<_Row>))
            .height;

        final single = headerHeight();
        expect(
          single,
          lessThan(100),
          reason: 'sanity: a one-line header measures to roughly a text line',
        );

        controller.setSelectionMode(SelectionMode.multiple);
        await tester.pumpAndSettle();

        expect(
          headerHeight(),
          closeTo(single, 0.5),
          reason:
              'The auto-generated selection column carries no header content, '
              'so it must not contribute to the measured header height. Got '
              '${headerHeight()} after switching to multi-select vs $single '
              'before.',
        );

        // And back again.
        controller.setSelectionMode(SelectionMode.none);
        await tester.pumpAndSettle();
        expect(headerHeight(), closeTo(single, 0.5));
      },
    );

    testWidgets(
      'the selection header cell still fills the resolved header height',
      (tester) async {
        tester.view.physicalSize = const Size(900, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = DataGridController<_Row>(
          initialColumns: [
            DataGridColumn<_Row>(
              id: 1,
              title: 'Name',
              width: 200,
              // No filter row: it renders a second DataGridHeaderViewport,
              // and this test measures the header row specifically.
              filterable: false,
              valueAccessor: (r) => r.name,
            ),
          ],
          initialRows: [_Row(id: 0, name: 'a')],
          sortDebounce: Duration.zero,
          filterDebounce: Duration.zero,
        );
        addTearDown(controller.dispose);
        controller.setSelectionMode(SelectionMode.multiple);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DataGrid<_Row>(
                controller: controller,
                showPagination: false,
                autoHeaderHeight: const AutoHeaderHeight(
                  estimatedHeight: 48,
                  minHeight: 20,
                  maxHeight: 300,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final headerHeight = tester
            .getSize(find.byType(DataGridHeaderViewport<_Row>))
            .height;

        // The pinned selection header is laid out tight in the second pass, so
        // its background/border still covers the full header row.
        final selectionCell = tester.getSize(
          find.byKey(const ValueKey('header_$kSelectionColumnId')),
        );
        expect(selectionCell.height, closeTo(headerHeight, 0.5));
        expect(selectionCell.width, closeTo(kSelectionColumnWidth, 0.5));
      },
    );

    testWidgets('fixed header height is unaffected by multi-select', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = DataGridController<_Row>(
        initialColumns: [
          DataGridColumn<_Row>(
            id: 1,
            title: 'Name',
            width: 200,
            filterable: false,
            valueAccessor: (r) => r.name,
          ),
        ],
        initialRows: [_Row(id: 0, name: 'a')],
        sortDebounce: Duration.zero,
        filterDebounce: Duration.zero,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataGrid<_Row>(
              controller: controller,
              showPagination: false,
              headerHeight: 56,
              // autoHeaderHeight intentionally omitted.
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      double headerHeight() => tester
          .getSize(find.byType(DataGridHeaderViewport<_Row>))
          .height;

      expect(headerHeight(), closeTo(56, 0.5));
      controller.setSelectionMode(SelectionMode.multiple);
      await tester.pumpAndSettle();
      expect(headerHeight(), closeTo(56, 0.5));
    });
  });
}
