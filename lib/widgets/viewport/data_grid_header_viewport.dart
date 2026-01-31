import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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

  const DataGridHeaderViewport({
    super.key,
    required this.columns,
    required this.horizontalController,
    required this.pinnedBackgroundColor,
    this.pinnedDecoration,
    required super.children,
    required this.childColumnIds,
  });

  @override
  RenderDataGridHeader<T> createRenderObject(BuildContext context) {
    return RenderDataGridHeader<T>(
      columns: columns,
      horizontalController: horizontalController,
      pinnedBackgroundColor: pinnedBackgroundColor,
      pinnedDecoration: pinnedDecoration,
      childColumnIds: childColumnIds,
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
      ..childColumnIds = childColumnIds;
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
  }) : _columns = columns,
       _horizontalController = horizontalController,
       _pinnedBackgroundColor = pinnedBackgroundColor,
       _pinnedDecoration = pinnedDecoration,
       _childColumnIds = childColumnIds;

  List<DataGridColumn<T>> _columns;
  List<DataGridColumn<T>> get columns => _columns;
  set columns(List<DataGridColumn<T>> value) {
    if (_columns == value) return;
    _columns = value;
    _columnById = null;
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
    if (_childColumnIds == value) return;
    _childColumnIds = value;
    markNeedsLayout();
  }

  double get _horizontalOffset =>
      _horizontalController.hasClients ? _horizontalController.offset : 0.0;

  double _pinnedWidth = 0;

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

  @override
  void performLayout() {
    final height = constraints.maxHeight;

    _pinnedWidth = 0;
    for (final col in _columns) {
      if (col.pinned && col.visible) {
        _pinnedWidth += col.width;
      }
    }

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

  @override
  void paint(PaintingContext context, Offset offset) {
    final horizontalOffset = _horizontalOffset;

    // Calculate column positions
    final pinnedPositions = <int, double>{};
    final unpinnedPositions = <int, double>{};

    double pinnedX = 0;
    double unpinnedX = 0;
    for (final col in _columns) {
      if (!col.visible) continue;
      if (col.pinned) {
        pinnedPositions[col.id] = pinnedX;
        pinnedX += col.width;
      } else {
        unpinnedPositions[col.id] = unpinnedX;
        unpinnedX += col.width;
      }
    }

    // Clip the painting area
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      context,
      offset,
    ) {
      // Paint unpinned children first (scrolled)
      RenderBox? child = firstChild;
      while (child != null) {
        final parentData = child.parentData! as HeaderChildData;
        final column = columnById[parentData.columnId];

        if (column != null && column.visible && !column.pinned) {
          final xPos = unpinnedPositions[column.id]!;
          final paintX = _pinnedWidth + xPos - horizontalOffset;

          // Only paint if visible
          if (paintX + column.width > _pinnedWidth && paintX < size.width) {
            context.paintChild(child, offset + Offset(paintX, 0));
          }
        }

        child = parentData.nextSibling;
      }

      // Paint mask over pinned area to hide scrolling content bleeding
      if (_pinnedWidth > 0) {
        context.canvas.drawRect(
          Rect.fromLTWH(offset.dx, offset.dy, _pinnedWidth, size.height),
          Paint()..color = _pinnedBackgroundColor,
        );
      }

      // Paint pinned children last (fixed position, on top)
      child = firstChild;
      while (child != null) {
        final parentData = child.parentData! as HeaderChildData;
        final column = columnById[parentData.columnId];

        if (column != null && column.visible && column.pinned) {
          final xPos = pinnedPositions[column.id]!;
          context.paintChild(child, offset + Offset(xPos, 0));
        }

        child = parentData.nextSibling;
      }
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final horizontalOffset = _horizontalOffset;

    // Calculate column positions (same logic as paint)
    final pinnedPositions = <int, double>{};
    final unpinnedPositions = <int, double>{};

    double pinnedX = 0;
    double unpinnedX = 0;
    for (final col in _columns) {
      if (!col.visible) continue;
      if (col.pinned) {
        pinnedPositions[col.id] = pinnedX;
        pinnedX += col.width;
      } else {
        unpinnedPositions[col.id] = unpinnedX;
        unpinnedX += col.width;
      }
    }

    // Hit test pinned children first (they're on top)
    RenderBox? child = lastChild;
    while (child != null) {
      final parentData = child.parentData! as HeaderChildData;
      final column = columnById[parentData.columnId];

      if (column != null && column.visible && column.pinned) {
        final xPos = pinnedPositions[column.id]!;
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

    // Hit test unpinned children
    child = lastChild;
    while (child != null) {
      final parentData = child.parentData! as HeaderChildData;
      final column = columnById[parentData.columnId];

      if (column != null && column.visible && !column.pinned) {
        final xPos = unpinnedPositions[column.id]!;
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
