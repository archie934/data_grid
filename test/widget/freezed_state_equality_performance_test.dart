// Observational benchmark for the cost of Freezed-generated `==`/`hashCode`/
// `copyWith` on `DataGridState` at scale, plus the full event-dispatch cost
// built on top of it. See AGENTS.md's "State management pattern" section for
// why most events keep `rowsById`/`displayOrder` reference-identical (shallow
// `copyWith`) while a few (load/insert/delete/update/sort/filter) replace
// them outright, which is exactly the split this file measures.
//
// No hard assertions — this mirrors the existing "layoutChildSequence
// benchmarks" precedent in data_grid_scroll_performance_test.dart, which is
// explicitly observational. Read the printed avg/min/max/p95 lines to judge
// whether Freezed equality is actually a hot-path cost at a given row count.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_data_grid/data_grid.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/models/enums/filter_operator.dart';

/// Row shape approximating the README/example "100k rows" live demo
/// (example/lib/models/product_row.dart), so per-row footprint is realistic
/// rather than a single-field stub.
class _BenchRow extends DataGridRow {
  String name;
  int quantity;
  double price;

  _BenchRow({
    required double id,
    required this.name,
    required this.quantity,
    required this.price,
  }) {
    this.id = id;
  }
}

List<_BenchRow> _generateRows(int count) => List.generate(
  count,
  (i) => _BenchRow(
    id: i.toDouble(),
    name: 'Row $i',
    quantity: i % 100,
    price: (i % 500) + 0.99,
  ),
);

/// Generates [count] columns, mirroring the example app's ~55-column shape
/// (example/lib/config/columns.dart) so `columns`/`rowsById` sizes match the
/// README's 100k-row live demo.
List<DataGridColumn<_BenchRow>> _generateColumns(int count) {
  final columns = <DataGridColumn<_BenchRow>>[
    DataGridColumn<_BenchRow>(
      id: 0,
      title: 'Name',
      width: 120,
      valueAccessor: (row) => row.name,
      cellValueSetter: (row, value) => row.name = value as String,
    ),
    DataGridColumn<_BenchRow>(
      id: 1,
      title: 'Quantity',
      width: 100,
      valueAccessor: (row) => row.quantity,
      cellValueSetter: (row, value) => row.quantity = value as int,
    ),
    DataGridColumn<_BenchRow>(
      id: 2,
      title: 'Price',
      width: 100,
      valueAccessor: (row) => row.price,
      cellValueSetter: (row, value) => row.price = value as double,
    ),
  ];
  for (var i = columns.length; i < count; i++) {
    columns.add(
      DataGridColumn<_BenchRow>(
        id: i,
        title: 'Extra $i',
        width: 80,
        valueAccessor: (row) => row.quantity + i,
      ),
    );
  }
  return columns;
}

/// Returns the p-th percentile (0-100) from a sorted microsecond list, in ms.
double _percentile(List<int> sortedUsecs, int p) {
  final idx = ((p / 100) * (sortedUsecs.length - 1)).round();
  return sortedUsecs[idx] / 1000.0;
}

void _printBench(String label, List<int> usecs) {
  final sorted = List<int>.from(usecs)..sort();
  final avg = usecs.fold<int>(0, (a, b) => a + b) / usecs.length / 1000;
  debugPrint(
    '[bench] $label\n'
    '  n=${usecs.length}  '
    'avg=${avg.toStringAsFixed(3)}ms  '
    'min=${(sorted.first / 1000).toStringAsFixed(3)}ms  '
    'max=${(sorted.last / 1000).toStringAsFixed(3)}ms  '
    'p95=${_percentile(sorted, 95).toStringAsFixed(3)}ms',
  );
}

/// Waits for the next `state$` emission for which [predicate] holds.
///
/// `BehaviorSubject.listen` replays the current value first; since that value
/// reflects state *before* the caller's about-to-be-dispatched event has been
/// processed, the predicate check on the replay is expected to be `false` and
/// is safely skipped without an explicit `.skip(1)`.
Future<void> _waitForState<T extends DataGridRow>(
  DataGridController<T> controller,
  bool Function(DataGridState<T> state) predicate,
) {
  final completer = Completer<void>();
  late final StreamSubscription<DataGridState<T>> sub;
  sub = controller.state$.listen((s) {
    if (predicate(s)) {
      completer.complete();
      sub.cancel();
    }
  });
  return completer.future;
}

const _rowCounts = [1000, 10000, 50000, 100000];
const _columnCount = 55; // matches example app's ~55-column shape
const _iterations = 20; // kept modest so `flutter test` runtime stays bounded
const _heavyIterations = 5; // for full-dataset sort/filter/isolate spawns

void main() {
  group('Freezed state equality/copyWith cost (observational)', () {
    for (final rowCount in _rowCounts) {
      test('raw equality/copyWith cost @ $rowCount rows', () async {
        final controller = DataGridController<_BenchRow>(
          initialColumns: _generateColumns(_columnCount),
          initialRows: _generateRows(rowCount),
        );
        addTearDown(controller.dispose);
        final state = controller.state;
        var sink = 0; // forces evaluation; prevents dead-code elimination

        // 1. Identical reference — expect ~0 (DeepCollectionEquality's
        //    identical() fast path in package:collection's MapEquality/ListEquality).
        final identicalUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final sw = Stopwatch()..start();
          if (state == state) sink++;
          sw.stop();
          identicalUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('identical ==', identicalUsecs);

        // 2. Shallow copyWith (same rowsById/displayOrder instance) — what
        //    selection/edit events do on every dispatch.
        final shallowUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final other = state.copyWith(
            selection: state.selection.copyWith(focusedRowId: i.toDouble()),
          );
          final sw = Stopwatch()..start();
          if (state == other) sink++;
          sw.stop();
          shallowUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('shallow-copy ==', shallowUsecs);

        // 3. Fresh-but-content-identical rowsById/displayOrder — the true
        //    worst case, no identical()/early-exit possible. Simulates what
        //    sort/filter produce even when the resulting order is unchanged.
        final deepUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final other = state.copyWith(
            rowsById: Map<double, _BenchRow>.from(state.rowsById),
            displayOrder: List<double>.from(state.displayOrder),
          );
          final sw = Stopwatch()..start();
          if (state == other) sink++;
          sw.stop();
          deepUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('fresh-equal-collections ==', deepUsecs);

        // 4. copyWith() construction cost alone, isolated from any equality check.
        final copyWithUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final sw = Stopwatch()..start();
          final copy = state.copyWith(totalItems: i);
          sw.stop();
          if (identical(copy, state)) sink++; // never true; keeps `copy` used
          copyWithUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('copyWith() construction', copyWithUsecs);

        // 5. hashCode — not exercised anywhere in shipped code today
        //    (LoggingInterceptor only compares .length/small sub-states, see
        //    AGENTS.md); included for completeness.
        final hashUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final sw = Stopwatch()..start();
          sink ^= state.hashCode;
          sw.stop();
          hashUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('hashCode', hashUsecs);

        debugPrint('  (sink=$sink — unused-value guard, ignore)');
      });
    }
  });

  group('Full event-pipeline cost at scale (observational)', () {
    for (final rowCount in _rowCounts) {
      test('event dispatch cost @ $rowCount rows', () async {
        final controller = DataGridController<_BenchRow>(
          initialColumns: _generateColumns(_columnCount),
          initialRows: _generateRows(rowCount),
          sortDebounce: Duration.zero,
          filterDebounce: Duration.zero,
          sortIsolateThreshold: rowCount + 1, // force the synchronous path
          filterIsolateThreshold: rowCount + 1, // force the synchronous path
        );
        addTearDown(controller.dispose);

        controller.setSelectionMode(SelectionMode.multiple);
        await _waitForState(
          controller,
          (s) => s.selection.mode == SelectionMode.multiple,
        );

        // Shallow path: row selection toggle.
        final selectUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final rowId = (i % rowCount).toDouble();
          final sw = Stopwatch()..start();
          controller.addEvent(SelectRowEvent(rowId: rowId, multiSelect: true));
          await _waitForState(
            controller,
            (s) => s.selection.selectedRowIds.contains(rowId),
          );
          sw.stop();
          selectUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('SelectRowEvent (shallow)', selectUsecs);

        // Shallow path: start + cancel cell edit (edit slice only).
        final editUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final rowId = (i % rowCount).toDouble();
          final sw = Stopwatch()..start();
          controller.startEditCell(rowId, 0);
          await _waitForState(
            controller,
            (s) => s.edit.isCellEditing(rowId, 0),
          );
          controller.cancelCellEdit();
          await _waitForState(controller, (s) => !s.edit.isEditing);
          sw.stop();
          editUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('StartCellEdit+Cancel (shallow)', editUsecs);

        // Deep path: updateRow replaces rowsById with a new Map instance.
        final updateRowUsecs = <int>[];
        for (var i = 0; i < _iterations; i++) {
          final rowId = (i % rowCount).toDouble();
          final prevRowsById = controller.state.rowsById;
          final sw = Stopwatch()..start();
          controller.updateRow(
            rowId,
            _BenchRow(
              id: rowId,
              name: 'Updated $i',
              quantity: i,
              price: i + 0.5,
            ),
          );
          await _waitForState(
            controller,
            (s) => !identical(s.rowsById, prevRowsById),
          );
          sw.stop();
          updateRowUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('updateRow (deep)', updateRowUsecs);

        // Deep path: sort direction toggle, forced synchronous (isolate
        // threshold set above rowCount in the controller above).
        final sortUsecs = <int>[];
        for (var i = 0; i < _heavyIterations; i++) {
          final direction = i.isEven
              ? SortDirection.ascending
              : SortDirection.descending;
          final prevDisplayOrder = controller.state.displayOrder;
          final sw = Stopwatch()..start();
          controller.addEvent(SortEvent(columnId: 1, direction: direction));
          await _waitForState(
            controller,
            (s) => !identical(s.displayOrder, prevDisplayOrder),
          );
          sw.stop();
          sortUsecs.add(sw.elapsedMicroseconds);
        }
        _printBench('SortEvent sync path (deep)', sortUsecs);

        // Deep path: filter apply + clear, forced synchronous.
        final filterUsecs = <int>[];
        for (var i = 0; i < _heavyIterations; i++) {
          final prevDisplayOrder = controller.state.displayOrder;
          final sw = Stopwatch()..start();
          controller.addEvent(
            FilterEvent(
              columnId: 1,
              operator: FilterOperator.greaterThanOrEqual,
              value: i * 10,
            ),
          );
          await _waitForState(
            controller,
            (s) => !identical(s.displayOrder, prevDisplayOrder),
          );
          sw.stop();
          filterUsecs.add(sw.elapsedMicroseconds);

          controller.addEvent(ClearFilterEvent(columnId: 1));
          await _waitForState(controller, (s) => !s.filter.hasFilters);
        }
        _printBench('FilterEvent sync path (deep)', filterUsecs);
      });

      if (rowCount >= 10000) {
        test(
          'sort/filter isolate path @ $rowCount rows',
          () async {
            final controller = DataGridController<_BenchRow>(
              initialColumns: _generateColumns(_columnCount),
              initialRows: _generateRows(rowCount),
              sortDebounce: Duration.zero,
              filterDebounce: Duration.zero,
              sortIsolateThreshold: 1, // force the isolate path
              filterIsolateThreshold: 1, // force the isolate path
            );
            addTearDown(controller.dispose);

            final sortUsecs = <int>[];
            for (var i = 0; i < _heavyIterations; i++) {
              final direction = i.isEven
                  ? SortDirection.ascending
                  : SortDirection.descending;
              final prevDisplayOrder = controller.state.displayOrder;
              final sw = Stopwatch()..start();
              controller.addEvent(SortEvent(columnId: 1, direction: direction));
              await _waitForState(
                controller,
                (s) => !identical(s.displayOrder, prevDisplayOrder),
              );
              sw.stop();
              sortUsecs.add(sw.elapsedMicroseconds);
            }
            _printBench('SortEvent isolate path (deep)', sortUsecs);

            final filterUsecs = <int>[];
            for (var i = 0; i < _heavyIterations; i++) {
              final prevDisplayOrder = controller.state.displayOrder;
              final sw = Stopwatch()..start();
              controller.addEvent(
                FilterEvent(
                  columnId: 1,
                  operator: FilterOperator.greaterThanOrEqual,
                  value: i * 10,
                ),
              );
              await _waitForState(
                controller,
                (s) => !identical(s.displayOrder, prevDisplayOrder),
              );
              sw.stop();
              filterUsecs.add(sw.elapsedMicroseconds);

              controller.addEvent(ClearFilterEvent(columnId: 1));
              await _waitForState(controller, (s) => !s.filter.hasFilters);
            }
            _printBench('FilterEvent isolate path (deep)', filterUsecs);
          },
          timeout: const Timeout(Duration(minutes: 2)),
        );
      }
    }
  });
}
