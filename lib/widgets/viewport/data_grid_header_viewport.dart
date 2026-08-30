import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_data_grid/models/auto_header_height.dart';
import 'package:flutter_data_grid/models/data/column.dart';
import 'package:flutter_data_grid/models/data/row.dart';

class HeaderChildData extends ContainerBoxParentData<RenderBox> {
  int columnId = 0;
}

class DataGridHeaderViewport<T extends DataGridRow>
    extends MultiChildRenderObjectWidget {
  final List<DataGridColumn<T>> columns;
  final ScrollController horizontalController;
  final Color pinnedBackgroundColor;
  final BoxDecoration? pinnedDecoration;
  final List<int> childColumnIds;

  /// When non-null, the header measures its content and sizes itself to fit
  /// (clamped to [AutoHeaderHeight.minHeight]/[AutoHeaderHeight.maxHeight])
  /// instead of filling the incoming tight height constraint.
  final AutoHeaderHeight? autoHeaderHeight;

  /// Called after every auto-height layout with the resolved height, only
  /// when it differs from the previously reported value.
  final ValueChanged<double>? onHeightChanged;

  /// The ambient text scaler. Plumbed through explicitly because the render
  /// object memoizes its measured height and has no `MediaQuery` of its own —
  /// header cells are laid out tight (so they're relayout boundaries) and a
  /// text-scale change inside one would not otherwise reach this render object.
  final TextScaler textScaler;

  const DataGridHeaderViewport({
    super.key,
    required this.columns,
    required this.horizontalController,
    required this.pinnedBackgroundColor,
    this.pinnedDecoration,
    required super.children,
    required this.childColumnIds,
    this.autoHeaderHeight,
    this.onHeightChanged,
    this.textScaler = TextScaler.noScaling,
  });

  @override
  RenderDataGridHeader<T> createRenderObject(BuildContext context) {
    return RenderDataGridHeader<T>(
      columns: columns,
      horizontalController: horizontalController,
      pinnedBackgroundColor: pinnedBackgroundColor,
      pinnedDecoration: pinnedDecoration,
      childColumnIds: childColumnIds,
      autoHeaderHeight: autoHeaderHeight,
      onHeightChanged: onHeightChanged,
      textScaler: textScaler,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDataGridHeader<T> renderObject,
  ) {
    renderObject
      ..columns = columns
      ..horizontalController = horizontalController
      ..pinnedBackgroundColor = pinnedBackgroundColor
      ..pinnedDecoration = pinnedDecoration
      ..childColumnIds = childColumnIds
      ..autoHeaderHeight = autoHeaderHeight
      ..onHeightChanged = onHeightChanged
      ..textScaler = textScaler;
  }
}

class RenderDataGridHeader<T extends DataGridRow> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, HeaderChildData>,
        RenderBoxContainerDefaultsMixin<RenderBox, HeaderChildData> {
  RenderDataGridHeader({
    required List<DataGridColumn<T>> columns,
    required ScrollController horizontalController,
    required Color pinnedBackgroundColor,
    BoxDecoration? pinnedDecoration,
    required List<int> childColumnIds,
    AutoHeaderHeight? autoHeaderHeight,
    this.onHeightChanged,
    TextScaler textScaler = TextScaler.noScaling,
  }) : _columns = columns,
       _textScaler = textScaler,
       _horizontalController = horizontalController,
       _pinnedBackgroundColor = pinnedBackgroundColor,
       _pinnedDecoration = pinnedDecoration,
       _childColumnIds = childColumnIds,
       _autoHeaderHeight = autoHeaderHeight;

  List<DataGridColumn<T>> _columns;
  List<DataGridColumn<T>> get columns => _columns;
  set columns(List<DataGridColumn<T>> value) {
    // listEquals, not `==`: `==` on a List is identity, and the caller derives
    // this list per build, so identity would relayout the header every frame.
    if (listEquals(_columns, value)) return;
    _columns = value;
    _columnById = null;
    _invalidateMeasuredHeight();
    markNeedsLayout();
  }

  Map<int, DataGridColumn<T>>? _columnById;
  Map<int, DataGridColumn<T>> get columnById {
    _columnById ??= {for (var c in _columns) c.id: c};
    return _columnById!;
  }

  ScrollController _horizontalController;
  ScrollController get horizontalController => _horizontalController;
  set horizontalController(ScrollController value) {
    if (_horizontalController == value) return;
    _horizontalController.removeListener(_onScroll);
    _horizontalController = value;
    _horizontalController.addListener(_onScroll);
    markNeedsPaint();
  }

  Color _pinnedBackgroundColor;
  Color get pinnedBackgroundColor => _pinnedBackgroundColor;
  set pinnedBackgroundColor(Color value) {
    if (_pinnedBackgroundColor == value) return;
    _pinnedBackgroundColor = value;
    markNeedsPaint();
  }

  BoxDecoration? _pinnedDecoration;
  BoxDecoration? get pinnedDecoration => _pinnedDecoration;
  set pinnedDecoration(BoxDecoration? value) {
    if (_pinnedDecoration == value) return;
    _pinnedDecoration = value;
    markNeedsPaint();
  }

  List<int> _childColumnIds;
  List<int> get childColumnIds => _childColumnIds;
  set childColumnIds(List<int> value) {
    if (listEquals(_childColumnIds, value)) return;
    _childColumnIds = value;
    _invalidateMeasuredHeight();
    markNeedsLayout();
  }

  AutoHeaderHeight? _autoHeaderHeight;
  AutoHeaderHeight? get autoHeaderHeight => _autoHeaderHeight;
  set autoHeaderHeight(AutoHeaderHeight? value) {
    if (_autoHeaderHeight == value) return;
    _autoHeaderHeight = value;
    _invalidateMeasuredHeight();
    markNeedsLayout();
  }

  /// Called after every auto-height layout with the resolved height, only
  /// when it differs from the previously reported value. Reassigning this
  /// doesn't require a relayout.
  ValueChanged<double>? onHeightChanged;

  double _lastReportedHeight = -1;

  /// Memo for [_measureAutoHeight]. Headers aren't virtualized, so the loose
  /// measuring pass lays out *every* header cell — and `performLayout` then
  /// lays them all out again tight. Without this the grid paid `2 × columns`
  /// full subtree layouts on every layout pass, including ones triggered by
  /// something completely unrelated to the header.
  ///
  /// Invalidated by the column/childColumnIds/autoHeaderHeight setters and by
  /// [markNeedsLayout] arriving through a child (see [_invalidateMeasuredHeight]).
  double? _measuredHeightMemo;
  double _measuredHeightMemoWidth = double.nan;
  TextScaler _measuredHeightMemoTextScaler = TextScaler.noScaling;

  TextScaler _textScaler;
  TextScaler get textScaler => _textScaler;
  set textScaler(TextScaler value) {
    if (_textScaler == value) return;
    _textScaler = value;
    _invalidateMeasuredHeight();
    markNeedsLayout();
  }

  void _invalidateMeasuredHeight() => _measuredHeightMemo = null;

  @override
  void markNeedsLayout() {
    // A child dirtying itself (a sort icon appearing, a resize handle hover,
    // a text-scale change) can change the header's intrinsic height, so any
    // relayout request invalidates the memo. Setter-driven invalidation above
    // is therefore belt-and-braces, but keeps intent explicit.
    _invalidateMeasuredHeight();
    super.markNeedsLayout();
  }

  double get _horizontalOffset =>
      _horizontalController.hasClients ? _horizontalController.offset : 0.0;

  double _pinnedWidth = 0;

  // Cached column positions computed during layout, reused in paint and hit test
  final Map<int, double> _pinnedPositions = {};
  final Map<int, double> _unpinnedPositions = {};

  // Cached paint object for the pinned mask
  Paint? _maskPaint;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _horizontalController.addListener(_onScroll);
  }

  @override
  void detach() {
    _horizontalController.removeListener(_onScroll);
    super.detach();
  }

  void _onScroll() {
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! HeaderChildData) {
      child.parentData = HeaderChildData();
    }
  }

  void _computeColumnPositions() {
    _pinnedPositions.clear();
    _unpinnedPositions.clear();

    double pinnedX = 0;
    double unpinnedX = 0;
    for (final col in _columns) {
      if (!col.visible) continue;
      if (col.pinned) {
        _pinnedPositions[col.id] = pinnedX;
        pinnedX += col.width;
      } else {
        _unpinnedPositions[col.id] = unpinnedX;
        unpinnedX += col.width;
      }
    }
  }

  @override
  void performLayout() {
    final autoHeaderHeight = _autoHeaderHeight;
    final height = autoHeaderHeight != null
        ? _measureAutoHeight(autoHeaderHeight)
        : constraints.maxHeight;

    _pinnedWidth = 0;
    for (final col in _columns) {
      if (col.pinned && col.visible) {
        _pinnedWidth += col.width;
      }
    }

    _computeColumnPositions();

    RenderBox? child = firstChild;
    int childIndex = 0;
    while (child != null) {
      final parentData = child.parentData! as HeaderChildData;
      final columnId = _childColumnIds[childIndex];
      parentData.columnId = columnId;

      final column = columnById[columnId];
      if (column != null && column.visible) {
        child.layout(
          BoxConstraints.tightFor(width: column.width, height: height),
          parentUsesSize: true,
        );
      }

      child = parentData.nextSibling;
      childIndex++;
    }

    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  /// Pass 1 of the two-pass auto-height layout: lays out each header cell
  /// with a loose height (up to [AutoHeaderHeight.maxHeight]) and takes the
  /// max resolved height. The second, tight-constraint pass that makes every
  /// cell fill that resolved height happens in the caller ([performLayout]).
  double _measureAutoHeight(AutoHeaderHeight autoHeaderHeight) {
    final textScaler = _textScaler;
    final memo = _measuredHeightMemo;
    if (memo != null &&
        _measuredHeightMemoWidth == constraints.maxWidth &&
        _measuredHeightMemoTextScaler == textScaler) {
      return memo;
    }

    double measured = 0;
    RenderBox? child = firstChild;
    int childIndex = 0;
    while (child != null) {
      final parentData = child.parentData! as HeaderChildData;
      final columnId = _childColumnIds[childIndex];
      parentData.columnId = columnId;

      final column = columnById[columnId];
      if (column != null && column.visible) {
        child.layout(
          BoxConstraints(
            minWidth: column.width,
            maxWidth: column.width,
            maxHeight: autoHeaderHeight.maxHeight,
          ),
          parentUsesSize: true,
        );
        if (child.size.height > measured) measured = child.size.height;
      }

      child = parentData.nextSibling;
      childIndex++;
    }

    final resolved = measured.clamp(
      autoHeaderHeight.minHeight,
      autoHeaderHeight.maxHeight,
    );

    _measuredHeightMemo = resolved;
    _measuredHeightMemoWidth = constraints.maxWidth;
    _measuredHeightMemoTextScaler = textScaler;

    if ((resolved - _lastReportedHeight).abs() > 0.5) {
      _lastReportedHeight = resolved;
      final callback = onHeightChanged;
      if (callback != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          callback(resolved);
        });
      }
    }

    return resolved;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final horizontalOffset = _horizontalOffset;

    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      context,
      offset,
    ) {
      RenderBox? child = firstChild;
      while (child != null) {
        final parentData = child.parentData! as HeaderChildData;
        final column = columnById[parentData.columnId];

        if (column != null && column.visible && !column.pinned) {
          final xPos = _unpinnedPositions[column.id]!;
          final paintX = _pinnedWidth + xPos - horizontalOffset;

          if (paintX + column.width > _pinnedWidth && paintX < size.width) {
            context.paintChild(child, offset + Offset(paintX, 0));
          }
        }

        child = parentData.nextSibling;
      }

      if (_pinnedWidth > 0) {
        _maskPaint ??= Paint();
        _maskPaint!.color = _pinnedBackgroundColor;
        context.canvas.drawRect(
          Rect.fromLTWH(offset.dx, offset.dy, _pinnedWidth, size.height),
          _maskPaint!,
        );
      }

      child = firstChild;
      while (child != null) {
        final parentData = child.parentData! as HeaderChildData;
        final column = columnById[parentData.columnId];

        if (column != null && column.visible && column.pinned) {
          final xPos = _pinnedPositions[column.id]!;
          context.paintChild(child, offset + Offset(xPos, 0));
        }

        child = parentData.nextSibling;
      }
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final horizontalOffset = _horizontalOffset;

    RenderBox? child = lastChild;
    while (child != null) {
      final parentData = child.parentData! as HeaderChildData;
      final column = columnById[parentData.columnId];

      if (column != null && column.visible && column.pinned) {
        final xPos = _pinnedPositions[column.id]!;
        final childOffset = Offset(xPos, 0);
        final isHit = result.addWithPaintOffset(
          offset: childOffset,
          position: position,
          hitTest: (result, transformed) =>
              child!.hitTest(result, position: transformed),
        );
        if (isHit) return true;
      }

      child = parentData.previousSibling;
    }

    child = lastChild;
    while (child != null) {
      final parentData = child.parentData! as HeaderChildData;
      final column = columnById[parentData.columnId];

      if (column != null && column.visible && !column.pinned) {
        final xPos = _unpinnedPositions[column.id]!;
        final paintX = _pinnedWidth + xPos - horizontalOffset;

        if (paintX + column.width > _pinnedWidth && paintX < size.width) {
          final childOffset = Offset(paintX, 0);
          final isHit = result.addWithPaintOffset(
            offset: childOffset,
            position: position,
            hitTest: (result, transformed) =>
                child!.hitTest(result, position: transformed),
          );
          if (isHit) return true;
        }
      }

      child = parentData.previousSibling;
    }

    return false;
  }
}
