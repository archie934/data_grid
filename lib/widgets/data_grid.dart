import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_data_grid/controllers/data_grid_controller.dart';
import 'package:flutter_data_grid/controllers/grid_scroll_controller.dart';
import 'package:flutter_data_grid/models/auto_header_height.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/grid_display_row.dart';
import 'package:flutter_data_grid/models/data/row.dart';
import 'package:flutter_data_grid/models/enums/selection_mode.dart';
import 'package:flutter_data_grid/models/state/grid_state.dart';
import 'package:flutter_data_grid/models/events/grid_events.dart';
import 'package:flutter_data_grid/utils/grid_display_rows.dart';
import 'package:flutter_data_grid/widgets/data_grid_header.dart';
import 'package:flutter_data_grid/widgets/custom_layout/custom_layout_grid_body.dart';
import 'package:flutter_data_grid/widgets/data_grid_inherited.dart';
import 'package:flutter_data_grid/widgets/data_grid_pagination.dart';
import 'package:flutter_data_grid/widgets/overlays/loading_overlay.dart';
import 'package:flutter_data_grid/widgets/filters/default_filter_widget.dart';
import 'package:flutter_data_grid/theme/data_grid_theme.dart';
import 'package:flutter_data_grid/theme/data_grid_theme_data.dart';
import 'package:rxdart/rxdart.dart';

/// A high-performance, virtualized data grid widget for displaying tabular data.
///
/// The [DataGrid] supports sorting, filtering, cell editing, row selection,
/// column pinning, and keyboard navigation. It uses virtualization to render
/// only visible rows for smooth scrolling with large datasets.
///
/// Example:
/// ```dart
/// DataGrid<MyRow>(
///   controller: controller,
///   headerHeight: 48.0,
///   rowHeight: 48.0,
/// )
/// ```
class DataGrid<T extends DataGridRow> extends StatefulWidget {
  /// The controller that manages the grid's state and data.
  final DataGridController<T> controller;

  /// Optional scroll controller for external scroll synchronization.
  final GridScrollController? scrollController;

  /// Height of the header row. Defaults to theme value if not specified.
  final double? headerHeight;

  /// Height of each data row. Defaults to theme value if not specified.
  final double? rowHeight;

  /// Opts the header row into content-measured height instead of the fixed
  /// [headerHeight] scalar. See [AutoHeaderHeight] for details.
  final AutoHeaderHeight? autoHeaderHeight;

  /// Default filter widget used for all filterable columns.
  ///
  /// Per-column overrides can be set via [DataGridColumn.filterWidget].
  /// If null, [DefaultFilterWidget] is used.
  final Widget? filterWidget;

  /// Whether to show the loading overlay (default: true)
  final bool showLoadingOverlay;

  /// Custom loading overlay builder. If null, uses default overlay.
  final Widget Function(BuildContext context, String? message)? loadingOverlayBuilder;

  /// Backdrop color for the loading overlay (default: black with 30% opacity)
  final Color? loadingBackdropColor;

  /// Color of the loading indicator (default: theme primary color)
  final Color? loadingIndicatorColor;

  /// Optional theme data to customize the appearance of the data grid.
  /// If not provided, uses the default theme.
  final DataGridThemeData? theme;

  /// Whether to show pagination controls (default: true)
  final bool showPagination;

  /// Custom pagination widget builder. If null, uses default pagination widget.
  final Widget Function(BuildContext context, DataGridState<T> state)? paginationBuilder;

  /// Cache extent for the scroll view. Controls how many pixels of content
  /// are pre-rendered beyond the visible viewport in each direction.
  /// Defaults to 1000.0 (~40 extra rows at default row height).
  /// Automatically capped to 500.0 in debug mode to keep debug builds usable.
  final double cacheExtent;

  /// Creates a [DataGrid] widget.
  const DataGrid({
    super.key,
    required this.controller,
    this.scrollController,
    this.headerHeight,
    this.rowHeight,
    this.autoHeaderHeight,
    this.filterWidget,
    this.showLoadingOverlay = true,
    this.loadingOverlayBuilder,
    this.loadingBackdropColor,
    this.loadingIndicatorColor,
    this.theme,
    this.showPagination = true,
    this.paginationBuilder,
    this.cacheExtent = 1000.0,
  });

  @override
  State<DataGrid<T>> createState() => _DataGridState<T>();
}

class _DataGridState<T extends DataGridRow> extends State<DataGrid<T>> {
  late GridScrollController _scrollController;
  late Widget _filterWidget;
  late DataGridThemeData _themeData;

  final FocusNode _gridFocusNode = FocusNode();
  StreamSubscription<String?>? _activeCellSubscription;
  StreamSubscription<bool>? _editSubscription;
  double _viewportHeight = 0;
  double _viewportWidth = 0;
  double _rowHeight = 48.0;

  // -- Derived-view memoization ---------------------------------------------
  // `computeDisplayRows` and `state.effectiveColumns` both allocate a fresh
  // list on every call. The quadrants key their `_cellCache` on list
  // *identity* (see GridUnpinnedQuadrant.didUpdateWidget), so recomputing
  // these per emission would leave the cache permanently cold and rebuild the
  // whole viewport for state changes the cells don't even depend on. Memoize
  // each on exactly the state slices it derives from.
  List<GridDisplayRow<T>> _displayRows = const [];
  List<double>? _displayRowsOrderRef;
  Map<double, T>? _displayRowsByIdRef;
  GroupState? _displayRowsGroupRef;
  List<DataGridColumn<T>>? _displayRowsColumnsRef;

  List<DataGridColumn<T>> _effectiveColumns = const [];
  List<DataGridColumn<T>>? _effectiveColumnsRef;
  SelectionMode? _effectiveColumnsModeRef;

  // -- Stable views over the Freezed collections -----------------------------
  // `DataGridState.columns` / `rowsById` / `displayOrder` are Freezed
  // collection getters, and Freezed wraps those in a **fresh**
  // `EqualUnmodifiable*View` on every single access:
  //
  //   Map<double, T> get rowsById {
  //     if (_rowsById is EqualUnmodifiableMapView) return _rowsById;
  //     return EqualUnmodifiableMapView(_rowsById);   // new object, every call
  //   }
  //
  // So `identical(state.rowsById, state.rowsById)` is **false**, and every
  // identity-based reuse check downstream (the quadrants' `_cellCache`, the
  // row-height delegate's structural-change guard) silently always fired.
  // These views do override `==` to compare their *sources*, which for a plain
  // List/Map is identity — so `==` is an O(1) "same underlying collection?"
  // test. Latch the view whenever that test says the source is unchanged, and
  // hand the latched instance downstream so `identical` works again.
  List<DataGridColumn<T>> _columnsView = const [];
  Map<double, T> _rowsByIdView = const {};
  List<double> _displayOrderView = const [];

  void _syncStateViews(DataGridState<T> state) {
    final columns = state.columns;
    if (_columnsView != columns) _columnsView = columns;
    final rowsById = state.rowsById;
    if (_rowsByIdView != rowsById) _rowsByIdView = rowsById;
    final displayOrder = state.displayOrder;
    if (_displayOrderView != displayOrder) _displayOrderView = displayOrder;
  }

  // -- Auto header height --------------------------------------------------
  double _headerHeight = 48.0;

  /// The flattened display-row list for [state], reusing the previous list
  /// whenever every input it derives from is unchanged. Preserving list
  /// identity is what keeps the quadrants' cell caches warm across emissions.
  List<GridDisplayRow<T>> _resolveDisplayRows(DataGridState<T> state) {
    if (identical(_displayRowsOrderRef, _displayOrderView) &&
        identical(_displayRowsByIdRef, _rowsByIdView) &&
        identical(_displayRowsGroupRef, state.group) &&
        identical(_displayRowsColumnsRef, _columnsView)) {
      return _displayRows;
    }
    _displayRowsOrderRef = _displayOrderView;
    _displayRowsByIdRef = _rowsByIdView;
    _displayRowsGroupRef = state.group;
    _displayRowsColumnsRef = _columnsView;
    return _displayRows = computeDisplayRows<T>(
      displayOrder: _displayOrderView,
      rowsById: _rowsByIdView,
      columns: _columnsView,
      group: state.group,
    );
  }

  /// [DataGridState.effectiveColumns] is a getter that allocates a new list
  /// (and a new selection column) on every access under multi-select. Memoize
  /// it on the two slices it actually depends on.
  List<DataGridColumn<T>> _resolveEffectiveColumns(DataGridState<T> state) {
    if (identical(_effectiveColumnsRef, _columnsView) &&
        _effectiveColumnsModeRef == state.selection.mode) {
      return _effectiveColumns;
    }
    _effectiveColumnsRef = _columnsView;
    _effectiveColumnsModeRef = state.selection.mode;
    return _effectiveColumns = state.selection.mode == SelectionMode.multiple
        ? [DataGridColumn<T>.selection(pinned: true), ..._columnsView]
        : _columnsView;
  }

  /// [DataGridState]'s generated `==` deep-compares `columns`, `rowsById` and
  /// `displayOrder` with [DeepCollectionEquality] — an O(n) walk of every row,
  /// run on every emission if used as the stream's `distinct` predicate. These
  /// three are replaced wholesale on a real change and never mutated in place,
  /// so identity decides them correctly and in constant time; the small
  /// sub-states keep value equality.
  bool _stateUnchanged(DataGridState<T> a, DataGridState<T> b) {
    if (identical(a, b)) return true;
    // `==` on these three is a source-identity check (see _syncStateViews),
    // not the O(n) deep compare Freezed's own `==` would do.
    return a.columns == b.columns &&
        a.rowsById == b.rowsById &&
        a.displayOrder == b.displayOrder &&
        a.selection == b.selection &&
        a.sort == b.sort &&
        a.filter == b.filter &&
        a.group == b.group &&
        a.edit == b.edit &&
        a.pagination == b.pagination &&
        a.totalItems == b.totalItems &&
        a.isLoading == b.isLoading &&
        a.loadingMessage == b.loadingMessage;
  }

  @override
  void initState() {
    super.initState();
    // The header context menu is triggered by right-click; on web that
    // would otherwise also open the browser's native context menu.
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
    _scrollController = widget.scrollController ?? GridScrollController();
    _filterWidget = widget.filterWidget ?? const DefaultFilterWidget();
    _themeData = widget.theme ?? DataGridThemeData.defaultTheme();
    _headerHeight = widget.autoHeaderHeight?.estimatedHeight ?? _themeData.dimensions.headerHeight;
    _activeCellSubscription = widget.controller.state$.map((s) => s.selection.activeCellId).distinct().skip(1).listen((cellId) {
      if (cellId != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCellVisible(cellId));
      }
    });
    // On WASM web the browser's focus system does not automatically return
    // keyboard focus to Flutter when the editing TextField is removed from the
    // widget tree.  Explicitly reclaim focus on the grid's Focus node so that
    // keyboard navigation (arrow keys, Ctrl+C, etc.) keeps working after an
    // edit is committed or cancelled.
    _editSubscription = widget.controller.state$.map((s) => s.edit.isEditing).distinct().listen((isEditing) {
      if (!isEditing && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _gridFocusNode.requestFocus();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant DataGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.theme, oldWidget.theme)) {
      _themeData = widget.theme ?? DataGridThemeData.defaultTheme();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    _activeCellSubscription?.cancel();
    _editSubscription?.cancel();
    _gridFocusNode.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _ensureCellVisible(String cellId) {
    if (!mounted) return;
    final state = widget.controller.state;
    final (rowId, colId) = parseCellId(cellId);

    // --- Vertical ---
    // Resolved against the grouped display list, not raw displayOrder, so
    // scrolling stays correct when grouping reorders/interleaves rows. If the
    // row is hidden inside a collapsed group it isn't in this list at all —
    // skip the scroll rather than guessing a position (known v1 limitation).
    final rowIndex = _displayRows.indexWhere((r) => r is GridDataRow<T> && r.rowId == rowId);
    if (rowIndex >= 0) {
      final vCtrl = _scrollController.verticalController;
      if (vCtrl.hasClients) {
        final cellTop = rowIndex * _rowHeight;
        final cellBottom = cellTop + _rowHeight;
        final vOffset = vCtrl.offset;
        final maxV = vCtrl.position.maxScrollExtent;
        if (cellTop < vOffset) {
          vCtrl.animateTo(cellTop.clamp(0.0, maxV), duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
        } else if (cellBottom > vOffset + _viewportHeight) {
          vCtrl.animateTo((cellBottom - _viewportHeight).clamp(0.0, maxV), duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
        }
      }
    }

    // --- Horizontal ---
    final visibleColumns = _resolveEffectiveColumns(state).where((c) => c.visible).toList();
    final colIndex = visibleColumns.indexWhere((c) => c.id == colId);
    if (colIndex < 0) return;

    if (visibleColumns[colIndex].pinned) return; // always visible

    final pinnedWidth = visibleColumns.where((c) => c.pinned).fold(0.0, (sum, c) => sum + c.width);

    final unpinnedColumns = visibleColumns.where((c) => !c.pinned).toList();
    final unpinnedColIndex = unpinnedColumns.indexWhere((c) => c.id == colId);
    if (unpinnedColIndex < 0) return;

    double cellLeft = 0;
    for (int i = 0; i < unpinnedColIndex; i++) {
      cellLeft += unpinnedColumns[i].width;
    }
    final cellRight = cellLeft + unpinnedColumns[unpinnedColIndex].width;
    final scrollableWidth = _viewportWidth - pinnedWidth;

    final hCtrl = _scrollController.horizontalController;
    if (hCtrl.hasClients) {
      final hOffset = hCtrl.offset;
      final maxH = hCtrl.position.maxScrollExtent;
      if (cellLeft < hOffset) {
        hCtrl.animateTo(cellLeft.clamp(0.0, maxH), duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
      } else if (cellRight > hOffset + scrollableWidth) {
        hCtrl.animateTo((cellRight - scrollableWidth).clamp(0.0, maxH), duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
      }
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (widget.controller.state.edit.isEditing) {
      return KeyEventResult.ignored;
    }

    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isCtrlOrMeta = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      widget.controller.addEvent(NavigateCellEvent(CellNavDirection.up, extend: isShift));
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      widget.controller.addEvent(NavigateCellEvent(CellNavDirection.down, extend: isShift));
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.controller.addEvent(NavigateCellEvent(CellNavDirection.left, extend: isShift));
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.controller.addEvent(NavigateCellEvent(CellNavDirection.right, extend: isShift));
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.controller.addEvent(ClearCellSelectionEvent());
      widget.controller.addEvent(ClearSelectionEvent());
      return KeyEventResult.handled;
    } else if (isCtrlOrMeta && event.logicalKey == LogicalKeyboardKey.keyA) {
      widget.controller.addEvent(SelectAllVisibleEvent());
      return KeyEventResult.handled;
    } else if (isCtrlOrMeta && event.logicalKey == LogicalKeyboardKey.keyC) {
      if (widget.controller.state.selection.focusedCells.isNotEmpty) {
        widget.controller.addEvent(CopyCellsEvent());
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      final activeCellId = widget.controller.state.selection.activeCellId;
      if (activeCellId != null) {
        final (rowId, colId) = parseCellId(activeCellId);
        final state = widget.controller.state;
        final colIndex = state.columns.indexWhere((c) => c.id == colId);
        if (colIndex != -1 && state.columns[colIndex].editable) {
          widget.controller.startEditCell(rowId, colId);
          return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }

  void _onHeaderHeightChanged(double newHeight) {
    if (!mounted) return;
    if ((newHeight - _headerHeight).abs() < 0.5) return;
    setState(() => _headerHeight = newHeight);
  }

  @override
  Widget build(BuildContext context) {
    final autoHeaderHeight = widget.autoHeaderHeight;
    final effectiveHeaderHeight = autoHeaderHeight != null ? _headerHeight : widget.headerHeight ?? _themeData.dimensions.headerHeight;
    final effectiveRowHeight = widget.rowHeight ?? _themeData.dimensions.rowHeight;

    return DataGridTheme(
      data: _themeData,
      child: StreamBuilder<DataGridState<T>>(
        stream: widget.controller.state$.debounceTime(const Duration(milliseconds: 10)).distinct(_stateUnchanged),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!;
          _syncStateViews(state);
          final displayRows = _resolveDisplayRows(state);
          final effectiveColumns = _resolveEffectiveColumns(state);
          final rowCount = displayRows.length;
          final columnCount = effectiveColumns.length;

          _rowHeight = effectiveRowHeight;

          return DataGridInherited<T>(
            controller: widget.controller,
            scrollController: _scrollController,
            state: state,
            displayRows: displayRows,
            effectiveColumns: effectiveColumns,
            rowsById: _rowsByIdView,
            gridFocusNode: _gridFocusNode,
            child: Focus(
              autofocus: true,
              focusNode: _gridFocusNode,
              onKeyEvent: (node, event) => _handleKeyEvent(event),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final paginationHeight = (widget.showPagination && state.pagination.enabled) ? 56.0 : 0.0;
                  final hasFilterableColumns = state.columns.any((col) => col.filterable && col.visible);
                  final filterRowHeight = hasFilterableColumns ? _themeData.dimensions.filterRowHeight : 0.0;
                  final availableHeight = constraints.maxHeight - effectiveHeaderHeight - filterRowHeight - paginationHeight;

                  final double bodyHeight;

                  final contentHeight = rowCount * effectiveRowHeight;
                  if (state.pagination.enabled && state.displayOrder.isNotEmpty) {
                    final requiredHeight = state.pagination.pageSize * effectiveRowHeight;
                    bodyHeight = requiredHeight <= availableHeight ? requiredHeight : availableHeight;
                  } else {
                    bodyHeight = contentHeight < availableHeight ? contentHeight : availableHeight;
                  }

                  final Widget bodyChild = CustomLayoutGridBody<T>(rowHeight: effectiveRowHeight, cacheExtent: widget.cacheExtent);

                  final bodyWidget = SizedBox(height: bodyHeight, child: bodyChild);

                  final totalColumnWidth = effectiveColumns.where((col) => col.visible).fold<double>(0.0, (sum, col) => sum + col.width);
                  final bodyWidth = totalColumnWidth < constraints.maxWidth ? totalColumnWidth : constraints.maxWidth;

                  _viewportHeight = bodyHeight;
                  _viewportWidth = bodyWidth;

                  return Semantics(
                    label: 'Data grid with $rowCount rows and $columnCount columns',
                    child: SizedBox(
                      width: bodyWidth,
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DataGridHeader<T>(
                                defaultFilterWidget: _filterWidget,
                                headerHeight: effectiveHeaderHeight,
                                autoHeaderHeight: autoHeaderHeight,
                                onHeightChanged: autoHeaderHeight != null ? _onHeaderHeightChanged : null,
                              ),
                              bodyWidget,
                              if (widget.showPagination && state.pagination.enabled) widget.paginationBuilder != null ? widget.paginationBuilder!(context, state) : DataGridPagination<T>(),
                            ],
                          ),
                          DataGridLoadingScope<T>(loadingOverlayBuilder: widget.loadingOverlayBuilder, backdropColor: widget.loadingBackdropColor, indicatorColor: widget.loadingIndicatorColor),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
