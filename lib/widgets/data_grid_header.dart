import 'package:flutter/material.dart';
import 'package:flutter_data_grid/models/auto_header_height.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/enums/sort_direction.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/widgets/cells/data_grid_header_cell.dart';
import 'package:flutter_data_grid/widgets/data_grid_filter_row.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/widgets/overlays/column_header_context_menu.dart';
import 'package:flutter_data_grid/widgets/viewport/data_grid_header_viewport.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';

class DataGridHeader<T extends DataGridRow> extends StatefulWidget {
  final Widget defaultFilterWidget;
  final double headerHeight;

  /// When non-null, the header row measures its content and sizes itself
  /// (clamped to its min/max) instead of using the fixed [headerHeight].
  final AutoHeaderHeight? autoHeaderHeight;

  /// Called when the auto-measured header height changes. Ignored when
  /// [autoHeaderHeight] is null.
  final ValueChanged<double>? onHeightChanged;

  const DataGridHeader({
    super.key,
    required this.defaultFilterWidget,
    required this.headerHeight,
    this.autoHeaderHeight,
    this.onHeightChanged,
  });

  @override
  State<DataGridHeader<T>> createState() => _DataGridHeaderState<T>();
}

class _DataGridHeaderState<T extends DataGridRow>
    extends State<DataGridHeader<T>> {
  // The header row is cached rather than rebuilt, so that when this widget is
  // rebuilt by its parent (which happens on every state emission) Flutter's
  // `child.widget == newWidget` check short-circuits and skips `_HeaderRow` and
  // all of its `_HeaderCellWrapper` children. `_HeaderRow` declares its own
  // InheritedModel aspect dependencies, so it still rebuilds when the columns,
  // sort or group state actually change — just not for everything else.
  Widget? _headerRow;
  AutoHeaderHeight? _cachedAutoHeaderHeight;
  ValueChanged<double>? _cachedOnHeightChanged;

  Widget _resolveHeaderRow() {
    final auto = widget.autoHeaderHeight;
    final cached = _headerRow;
    if (cached != null &&
        _cachedAutoHeaderHeight == auto &&
        _cachedOnHeightChanged == widget.onHeightChanged) {
      return cached;
    }
    _cachedAutoHeaderHeight = auto;
    _cachedOnHeightChanged = widget.onHeightChanged;
    return _headerRow = auto != null
        ? _HeaderRow<T>(
            autoHeaderHeight: auto,
            onHeightChanged: widget.onHeightChanged,
          )
        : _HeaderRow<T>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final state = context.dataGridState<T>({DataGridAspect.columns})!;
    final hasFilterableColumns = state.columns.any(
      (col) => col.filterable && col.visible,
    );

    final autoHeaderHeight = widget.autoHeaderHeight;
    final headerRowChild = _resolveHeaderRow();
    final headerRow = autoHeaderHeight != null
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: autoHeaderHeight.minHeight,
              maxHeight: autoHeaderHeight.maxHeight,
            ),
            child: headerRowChild,
          )
        : SizedBox(height: widget.headerHeight, child: headerRowChild);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        headerRow,
        if (hasFilterableColumns)
          SizedBox(
            height: theme.dimensions.filterRowHeight,
            child: DataGridFilterRow<T>(
              defaultFilterWidget: widget.defaultFilterWidget,
            ),
          ),
      ],
    );
  }
}

class _HeaderRow<T extends DataGridRow> extends StatelessWidget {
  final AutoHeaderHeight? autoHeaderHeight;
  final ValueChanged<double>? onHeightChanged;

  const _HeaderRow({this.autoHeaderHeight, this.onHeightChanged});

  @override
  Widget build(BuildContext context) {
    final state = context.dataGridState<T>({
      DataGridAspect.columns,
      DataGridAspect.sort,
      DataGridAspect.group,
    })!;
    final scrollController = context.gridScrollController<T>()!;
    final theme = DataGridTheme.of(context);

    final columns = context.dataGridEffectiveColumns<T>()!;
    final visibleColumns = columns.where((c) => c.visible).toList();
    final unpinnedFirst = [
      ...visibleColumns.where((c) => !c.pinned),
      ...visibleColumns.where((c) => c.pinned),
    ];

    return DataGridHeaderViewport<T>(
      columns: columns,
      horizontalController: scrollController.horizontalController,
      pinnedBackgroundColor: theme.colors.headerColor,
      childColumnIds: unpinnedFirst.map((c) => c.id).toList(),
      autoHeaderHeight: autoHeaderHeight,
      onHeightChanged: onHeightChanged,
      // Read here (not in the render object, which has no MediaQuery) so a
      // text-scale change rebuilds this row and invalidates the header's
      // measured-height memo.
      textScaler: MediaQuery.textScalerOf(context),
      children: [
        for (var column in unpinnedFirst)
          _HeaderCellWrapper<T>(
            key: ValueKey('header_${column.id}'),
            column: column,
            sortState: state.sort,
            groupState: state.group,
          ),
      ],
    );
  }
}

/// Wraps one header cell, adding the right-click context menu and pinned-column
/// styling.
///
/// Stateful purely so the three callbacks handed to [DataGridHeaderCell] are
/// method tear-offs on a stable `State` rather than closure literals. A closure
/// literal is a new object on every build, which makes the header cell's
/// constructor arguments differ every time and defeats any equality-based
/// short-circuit downstream.
class _HeaderCellWrapper<T extends DataGridRow> extends StatefulWidget {
  final DataGridColumn column;
  final SortState sortState;
  final GroupState groupState;

  const _HeaderCellWrapper({
    super.key,
    required this.column,
    required this.sortState,
    required this.groupState,
  });

  @override
  State<_HeaderCellWrapper<T>> createState() => _HeaderCellWrapperState<T>();
}

class _HeaderCellWrapperState<T extends DataGridRow>
    extends State<_HeaderCellWrapper<T>> {
  void _handleSort(SortDirection? direction) {
    context.dataGridController<T>()!.addEvent(
      SortEvent(columnId: widget.column.id, direction: direction),
    );
  }

  /// newWidth is already clamped by the cell — just dispatch the event.
  void _handleResize(double newWidth) {
    context.dataGridController<T>()!.addEvent(
      ColumnResizeEvent(columnId: widget.column.id, newWidth: newWidth),
    );
  }

  void _handleSecondaryTap(TapDownDetails details) {
    showColumnHeaderContextMenu<T>(
      context: context,
      globalPosition: details.globalPosition,
      column: widget.column as DataGridColumn<T>,
      sortState: widget.sortState,
      groupState: widget.groupState,
      controller: context.dataGridController<T>()!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DataGridTheme.of(context);
    final column = widget.column;

    Widget cell;
    if (column.id == kSelectionColumnId) {
      // The auto-generated selection column has no header content, so it must
      // contribute nothing to the measured header height.
      //
      // Deliberately `shrink`, not `expand`: under `autoHeaderHeight` the
      // header is laid out twice (see [RenderDataGridHeader.performLayout]) —
      // a loose pass that takes the max resolved height across cells, then a
      // tight pass at that height. `SizedBox.expand` fills whatever it's
      // given, so in the loose pass it reported `AutoHeaderHeight.maxHeight`
      // and dragged the whole header to its clamp the moment multi-select
      // added this column. `SizedBox.shrink` enforces a tight-zero constraint
      // *within* the incoming one, so it measures 0 in the loose pass and
      // still fills the resolved height in the tight pass — which keeps the
      // pinned background and border covering the full header row.
      cell = const SizedBox.shrink();
    } else {
      // For pinned columns suppress the inner right border — the outer
      // wrapper Container already draws pinnedBorder on the right edge.
      final effectiveBorder = column.pinned
          ? Border(bottom: theme.borders.headerBorder.bottom)
          : null;

      cell = GestureDetector(
        onSecondaryTapDown: _handleSecondaryTap,
        child: DataGridHeaderCell(
          column: column,
          sortState: widget.sortState,
          borderOverride: effectiveBorder,
          onSort: _handleSort,
          onResize: _handleResize,
        ),
      );
    }

    // Add pinned column styling
    if (column.pinned) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colors.headerColor,
          border: theme.borders.pinnedBorder,
          boxShadow: theme.borders.pinnedShadow,
        ),
        child: cell,
      );
    }

    return cell;
  }
}
