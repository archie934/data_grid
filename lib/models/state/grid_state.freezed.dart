// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grid_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DataGridState<T extends DataGridRow> {
  List<DataGridColumn<T>> get columns => throw _privateConstructorUsedError;
  Map<double, T> get rowsById => throw _privateConstructorUsedError;
  List<double> get displayOrder => throw _privateConstructorUsedError;
  ViewportState get viewport => throw _privateConstructorUsedError;
  SelectionState get selection => throw _privateConstructorUsedError;
  SortState get sort => throw _privateConstructorUsedError;
  FilterState get filter => throw _privateConstructorUsedError;
  GroupState get group => throw _privateConstructorUsedError;
  EditState get edit => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get loadingMessage => throw _privateConstructorUsedError;

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DataGridStateCopyWith<T, DataGridState<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataGridStateCopyWith<T extends DataGridRow, $Res> {
  factory $DataGridStateCopyWith(
    DataGridState<T> value,
    $Res Function(DataGridState<T>) then,
  ) = _$DataGridStateCopyWithImpl<T, $Res, DataGridState<T>>;
  @useResult
  $Res call({
    List<DataGridColumn<T>> columns,
    Map<double, T> rowsById,
    List<double> displayOrder,
    ViewportState viewport,
    SelectionState selection,
    SortState sort,
    FilterState filter,
    GroupState group,
    EditState edit,
    bool isLoading,
    String? loadingMessage,
  });

  $ViewportStateCopyWith<$Res> get viewport;
  $SelectionStateCopyWith<$Res> get selection;
  $SortStateCopyWith<$Res> get sort;
  $FilterStateCopyWith<$Res> get filter;
  $GroupStateCopyWith<$Res> get group;
  $EditStateCopyWith<$Res> get edit;
}

/// @nodoc
class _$DataGridStateCopyWithImpl<
  T extends DataGridRow,
  $Res,
  $Val extends DataGridState<T>
>
    implements $DataGridStateCopyWith<T, $Res> {
  _$DataGridStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columns = null,
    Object? rowsById = null,
    Object? displayOrder = null,
    Object? viewport = null,
    Object? selection = null,
    Object? sort = null,
    Object? filter = null,
    Object? group = null,
    Object? edit = null,
    Object? isLoading = null,
    Object? loadingMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as List<DataGridColumn<T>>,
            rowsById: null == rowsById
                ? _value.rowsById
                : rowsById // ignore: cast_nullable_to_non_nullable
                      as Map<double, T>,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            viewport: null == viewport
                ? _value.viewport
                : viewport // ignore: cast_nullable_to_non_nullable
                      as ViewportState,
            selection: null == selection
                ? _value.selection
                : selection // ignore: cast_nullable_to_non_nullable
                      as SelectionState,
            sort: null == sort
                ? _value.sort
                : sort // ignore: cast_nullable_to_non_nullable
                      as SortState,
            filter: null == filter
                ? _value.filter
                : filter // ignore: cast_nullable_to_non_nullable
                      as FilterState,
            group: null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                      as GroupState,
            edit: null == edit
                ? _value.edit
                : edit // ignore: cast_nullable_to_non_nullable
                      as EditState,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            loadingMessage: freezed == loadingMessage
                ? _value.loadingMessage
                : loadingMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ViewportStateCopyWith<$Res> get viewport {
    return $ViewportStateCopyWith<$Res>(_value.viewport, (value) {
      return _then(_value.copyWith(viewport: value) as $Val);
    });
  }

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SelectionStateCopyWith<$Res> get selection {
    return $SelectionStateCopyWith<$Res>(_value.selection, (value) {
      return _then(_value.copyWith(selection: value) as $Val);
    });
  }

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SortStateCopyWith<$Res> get sort {
    return $SortStateCopyWith<$Res>(_value.sort, (value) {
      return _then(_value.copyWith(sort: value) as $Val);
    });
  }

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FilterStateCopyWith<$Res> get filter {
    return $FilterStateCopyWith<$Res>(_value.filter, (value) {
      return _then(_value.copyWith(filter: value) as $Val);
    });
  }

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GroupStateCopyWith<$Res> get group {
    return $GroupStateCopyWith<$Res>(_value.group, (value) {
      return _then(_value.copyWith(group: value) as $Val);
    });
  }

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EditStateCopyWith<$Res> get edit {
    return $EditStateCopyWith<$Res>(_value.edit, (value) {
      return _then(_value.copyWith(edit: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DataGridStateImplCopyWith<T extends DataGridRow, $Res>
    implements $DataGridStateCopyWith<T, $Res> {
  factory _$$DataGridStateImplCopyWith(
    _$DataGridStateImpl<T> value,
    $Res Function(_$DataGridStateImpl<T>) then,
  ) = __$$DataGridStateImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({
    List<DataGridColumn<T>> columns,
    Map<double, T> rowsById,
    List<double> displayOrder,
    ViewportState viewport,
    SelectionState selection,
    SortState sort,
    FilterState filter,
    GroupState group,
    EditState edit,
    bool isLoading,
    String? loadingMessage,
  });

  @override
  $ViewportStateCopyWith<$Res> get viewport;
  @override
  $SelectionStateCopyWith<$Res> get selection;
  @override
  $SortStateCopyWith<$Res> get sort;
  @override
  $FilterStateCopyWith<$Res> get filter;
  @override
  $GroupStateCopyWith<$Res> get group;
  @override
  $EditStateCopyWith<$Res> get edit;
}

/// @nodoc
class __$$DataGridStateImplCopyWithImpl<T extends DataGridRow, $Res>
    extends _$DataGridStateCopyWithImpl<T, $Res, _$DataGridStateImpl<T>>
    implements _$$DataGridStateImplCopyWith<T, $Res> {
  __$$DataGridStateImplCopyWithImpl(
    _$DataGridStateImpl<T> _value,
    $Res Function(_$DataGridStateImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columns = null,
    Object? rowsById = null,
    Object? displayOrder = null,
    Object? viewport = null,
    Object? selection = null,
    Object? sort = null,
    Object? filter = null,
    Object? group = null,
    Object? edit = null,
    Object? isLoading = null,
    Object? loadingMessage = freezed,
  }) {
    return _then(
      _$DataGridStateImpl<T>(
        columns: null == columns
            ? _value._columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as List<DataGridColumn<T>>,
        rowsById: null == rowsById
            ? _value._rowsById
            : rowsById // ignore: cast_nullable_to_non_nullable
                  as Map<double, T>,
        displayOrder: null == displayOrder
            ? _value._displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        viewport: null == viewport
            ? _value.viewport
            : viewport // ignore: cast_nullable_to_non_nullable
                  as ViewportState,
        selection: null == selection
            ? _value.selection
            : selection // ignore: cast_nullable_to_non_nullable
                  as SelectionState,
        sort: null == sort
            ? _value.sort
            : sort // ignore: cast_nullable_to_non_nullable
                  as SortState,
        filter: null == filter
            ? _value.filter
            : filter // ignore: cast_nullable_to_non_nullable
                  as FilterState,
        group: null == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as GroupState,
        edit: null == edit
            ? _value.edit
            : edit // ignore: cast_nullable_to_non_nullable
                  as EditState,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        loadingMessage: freezed == loadingMessage
            ? _value.loadingMessage
            : loadingMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DataGridStateImpl<T extends DataGridRow> extends _DataGridState<T> {
  const _$DataGridStateImpl({
    required final List<DataGridColumn<T>> columns,
    required final Map<double, T> rowsById,
    required final List<double> displayOrder,
    required this.viewport,
    required this.selection,
    required this.sort,
    required this.filter,
    required this.group,
    required this.edit,
    this.isLoading = false,
    this.loadingMessage,
  }) : _columns = columns,
       _rowsById = rowsById,
       _displayOrder = displayOrder,
       super._();

  final List<DataGridColumn<T>> _columns;
  @override
  List<DataGridColumn<T>> get columns {
    if (_columns is EqualUnmodifiableListView) return _columns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_columns);
  }

  final Map<double, T> _rowsById;
  @override
  Map<double, T> get rowsById {
    if (_rowsById is EqualUnmodifiableMapView) return _rowsById;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rowsById);
  }

  final List<double> _displayOrder;
  @override
  List<double> get displayOrder {
    if (_displayOrder is EqualUnmodifiableListView) return _displayOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_displayOrder);
  }

  @override
  final ViewportState viewport;
  @override
  final SelectionState selection;
  @override
  final SortState sort;
  @override
  final FilterState filter;
  @override
  final GroupState group;
  @override
  final EditState edit;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? loadingMessage;

  @override
  String toString() {
    return 'DataGridState<$T>(columns: $columns, rowsById: $rowsById, displayOrder: $displayOrder, viewport: $viewport, selection: $selection, sort: $sort, filter: $filter, group: $group, edit: $edit, isLoading: $isLoading, loadingMessage: $loadingMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataGridStateImpl<T> &&
            const DeepCollectionEquality().equals(other._columns, _columns) &&
            const DeepCollectionEquality().equals(other._rowsById, _rowsById) &&
            const DeepCollectionEquality().equals(
              other._displayOrder,
              _displayOrder,
            ) &&
            (identical(other.viewport, viewport) ||
                other.viewport == viewport) &&
            (identical(other.selection, selection) ||
                other.selection == selection) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.edit, edit) || other.edit == edit) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.loadingMessage, loadingMessage) ||
                other.loadingMessage == loadingMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_columns),
    const DeepCollectionEquality().hash(_rowsById),
    const DeepCollectionEquality().hash(_displayOrder),
    viewport,
    selection,
    sort,
    filter,
    group,
    edit,
    isLoading,
    loadingMessage,
  );

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataGridStateImplCopyWith<T, _$DataGridStateImpl<T>> get copyWith =>
      __$$DataGridStateImplCopyWithImpl<T, _$DataGridStateImpl<T>>(
        this,
        _$identity,
      );
}

abstract class _DataGridState<T extends DataGridRow> extends DataGridState<T> {
  const factory _DataGridState({
    required final List<DataGridColumn<T>> columns,
    required final Map<double, T> rowsById,
    required final List<double> displayOrder,
    required final ViewportState viewport,
    required final SelectionState selection,
    required final SortState sort,
    required final FilterState filter,
    required final GroupState group,
    required final EditState edit,
    final bool isLoading,
    final String? loadingMessage,
  }) = _$DataGridStateImpl<T>;
  const _DataGridState._() : super._();

  @override
  List<DataGridColumn<T>> get columns;
  @override
  Map<double, T> get rowsById;
  @override
  List<double> get displayOrder;
  @override
  ViewportState get viewport;
  @override
  SelectionState get selection;
  @override
  SortState get sort;
  @override
  FilterState get filter;
  @override
  GroupState get group;
  @override
  EditState get edit;
  @override
  bool get isLoading;
  @override
  String? get loadingMessage;

  /// Create a copy of DataGridState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataGridStateImplCopyWith<T, _$DataGridStateImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ViewportState {
  double get scrollOffsetX => throw _privateConstructorUsedError;
  double get scrollOffsetY => throw _privateConstructorUsedError;
  double get viewportWidth => throw _privateConstructorUsedError;
  double get viewportHeight => throw _privateConstructorUsedError;
  int get firstVisibleRow => throw _privateConstructorUsedError;
  int get lastVisibleRow => throw _privateConstructorUsedError;
  int get firstVisibleColumn => throw _privateConstructorUsedError;
  int get lastVisibleColumn => throw _privateConstructorUsedError;

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ViewportStateCopyWith<ViewportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewportStateCopyWith<$Res> {
  factory $ViewportStateCopyWith(
    ViewportState value,
    $Res Function(ViewportState) then,
  ) = _$ViewportStateCopyWithImpl<$Res, ViewportState>;
  @useResult
  $Res call({
    double scrollOffsetX,
    double scrollOffsetY,
    double viewportWidth,
    double viewportHeight,
    int firstVisibleRow,
    int lastVisibleRow,
    int firstVisibleColumn,
    int lastVisibleColumn,
  });
}

/// @nodoc
class _$ViewportStateCopyWithImpl<$Res, $Val extends ViewportState>
    implements $ViewportStateCopyWith<$Res> {
  _$ViewportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scrollOffsetX = null,
    Object? scrollOffsetY = null,
    Object? viewportWidth = null,
    Object? viewportHeight = null,
    Object? firstVisibleRow = null,
    Object? lastVisibleRow = null,
    Object? firstVisibleColumn = null,
    Object? lastVisibleColumn = null,
  }) {
    return _then(
      _value.copyWith(
            scrollOffsetX: null == scrollOffsetX
                ? _value.scrollOffsetX
                : scrollOffsetX // ignore: cast_nullable_to_non_nullable
                      as double,
            scrollOffsetY: null == scrollOffsetY
                ? _value.scrollOffsetY
                : scrollOffsetY // ignore: cast_nullable_to_non_nullable
                      as double,
            viewportWidth: null == viewportWidth
                ? _value.viewportWidth
                : viewportWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            viewportHeight: null == viewportHeight
                ? _value.viewportHeight
                : viewportHeight // ignore: cast_nullable_to_non_nullable
                      as double,
            firstVisibleRow: null == firstVisibleRow
                ? _value.firstVisibleRow
                : firstVisibleRow // ignore: cast_nullable_to_non_nullable
                      as int,
            lastVisibleRow: null == lastVisibleRow
                ? _value.lastVisibleRow
                : lastVisibleRow // ignore: cast_nullable_to_non_nullable
                      as int,
            firstVisibleColumn: null == firstVisibleColumn
                ? _value.firstVisibleColumn
                : firstVisibleColumn // ignore: cast_nullable_to_non_nullable
                      as int,
            lastVisibleColumn: null == lastVisibleColumn
                ? _value.lastVisibleColumn
                : lastVisibleColumn // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ViewportStateImplCopyWith<$Res>
    implements $ViewportStateCopyWith<$Res> {
  factory _$$ViewportStateImplCopyWith(
    _$ViewportStateImpl value,
    $Res Function(_$ViewportStateImpl) then,
  ) = __$$ViewportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double scrollOffsetX,
    double scrollOffsetY,
    double viewportWidth,
    double viewportHeight,
    int firstVisibleRow,
    int lastVisibleRow,
    int firstVisibleColumn,
    int lastVisibleColumn,
  });
}

/// @nodoc
class __$$ViewportStateImplCopyWithImpl<$Res>
    extends _$ViewportStateCopyWithImpl<$Res, _$ViewportStateImpl>
    implements _$$ViewportStateImplCopyWith<$Res> {
  __$$ViewportStateImplCopyWithImpl(
    _$ViewportStateImpl _value,
    $Res Function(_$ViewportStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scrollOffsetX = null,
    Object? scrollOffsetY = null,
    Object? viewportWidth = null,
    Object? viewportHeight = null,
    Object? firstVisibleRow = null,
    Object? lastVisibleRow = null,
    Object? firstVisibleColumn = null,
    Object? lastVisibleColumn = null,
  }) {
    return _then(
      _$ViewportStateImpl(
        scrollOffsetX: null == scrollOffsetX
            ? _value.scrollOffsetX
            : scrollOffsetX // ignore: cast_nullable_to_non_nullable
                  as double,
        scrollOffsetY: null == scrollOffsetY
            ? _value.scrollOffsetY
            : scrollOffsetY // ignore: cast_nullable_to_non_nullable
                  as double,
        viewportWidth: null == viewportWidth
            ? _value.viewportWidth
            : viewportWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        viewportHeight: null == viewportHeight
            ? _value.viewportHeight
            : viewportHeight // ignore: cast_nullable_to_non_nullable
                  as double,
        firstVisibleRow: null == firstVisibleRow
            ? _value.firstVisibleRow
            : firstVisibleRow // ignore: cast_nullable_to_non_nullable
                  as int,
        lastVisibleRow: null == lastVisibleRow
            ? _value.lastVisibleRow
            : lastVisibleRow // ignore: cast_nullable_to_non_nullable
                  as int,
        firstVisibleColumn: null == firstVisibleColumn
            ? _value.firstVisibleColumn
            : firstVisibleColumn // ignore: cast_nullable_to_non_nullable
                  as int,
        lastVisibleColumn: null == lastVisibleColumn
            ? _value.lastVisibleColumn
            : lastVisibleColumn // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ViewportStateImpl implements _ViewportState {
  const _$ViewportStateImpl({
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    required this.viewportWidth,
    required this.viewportHeight,
    required this.firstVisibleRow,
    required this.lastVisibleRow,
    required this.firstVisibleColumn,
    required this.lastVisibleColumn,
  });

  @override
  final double scrollOffsetX;
  @override
  final double scrollOffsetY;
  @override
  final double viewportWidth;
  @override
  final double viewportHeight;
  @override
  final int firstVisibleRow;
  @override
  final int lastVisibleRow;
  @override
  final int firstVisibleColumn;
  @override
  final int lastVisibleColumn;

  @override
  String toString() {
    return 'ViewportState(scrollOffsetX: $scrollOffsetX, scrollOffsetY: $scrollOffsetY, viewportWidth: $viewportWidth, viewportHeight: $viewportHeight, firstVisibleRow: $firstVisibleRow, lastVisibleRow: $lastVisibleRow, firstVisibleColumn: $firstVisibleColumn, lastVisibleColumn: $lastVisibleColumn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewportStateImpl &&
            (identical(other.scrollOffsetX, scrollOffsetX) ||
                other.scrollOffsetX == scrollOffsetX) &&
            (identical(other.scrollOffsetY, scrollOffsetY) ||
                other.scrollOffsetY == scrollOffsetY) &&
            (identical(other.viewportWidth, viewportWidth) ||
                other.viewportWidth == viewportWidth) &&
            (identical(other.viewportHeight, viewportHeight) ||
                other.viewportHeight == viewportHeight) &&
            (identical(other.firstVisibleRow, firstVisibleRow) ||
                other.firstVisibleRow == firstVisibleRow) &&
            (identical(other.lastVisibleRow, lastVisibleRow) ||
                other.lastVisibleRow == lastVisibleRow) &&
            (identical(other.firstVisibleColumn, firstVisibleColumn) ||
                other.firstVisibleColumn == firstVisibleColumn) &&
            (identical(other.lastVisibleColumn, lastVisibleColumn) ||
                other.lastVisibleColumn == lastVisibleColumn));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    scrollOffsetX,
    scrollOffsetY,
    viewportWidth,
    viewportHeight,
    firstVisibleRow,
    lastVisibleRow,
    firstVisibleColumn,
    lastVisibleColumn,
  );

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewportStateImplCopyWith<_$ViewportStateImpl> get copyWith =>
      __$$ViewportStateImplCopyWithImpl<_$ViewportStateImpl>(this, _$identity);
}

abstract class _ViewportState implements ViewportState {
  const factory _ViewportState({
    required final double scrollOffsetX,
    required final double scrollOffsetY,
    required final double viewportWidth,
    required final double viewportHeight,
    required final int firstVisibleRow,
    required final int lastVisibleRow,
    required final int firstVisibleColumn,
    required final int lastVisibleColumn,
  }) = _$ViewportStateImpl;

  @override
  double get scrollOffsetX;
  @override
  double get scrollOffsetY;
  @override
  double get viewportWidth;
  @override
  double get viewportHeight;
  @override
  int get firstVisibleRow;
  @override
  int get lastVisibleRow;
  @override
  int get firstVisibleColumn;
  @override
  int get lastVisibleColumn;

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ViewportStateImplCopyWith<_$ViewportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SelectionState {
  Set<double> get selectedRowIds => throw _privateConstructorUsedError;
  double? get focusedRowId => throw _privateConstructorUsedError;
  Set<String> get selectedCellIds => throw _privateConstructorUsedError;
  SelectionMode get mode => throw _privateConstructorUsedError;

  /// Create a copy of SelectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectionStateCopyWith<SelectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectionStateCopyWith<$Res> {
  factory $SelectionStateCopyWith(
    SelectionState value,
    $Res Function(SelectionState) then,
  ) = _$SelectionStateCopyWithImpl<$Res, SelectionState>;
  @useResult
  $Res call({
    Set<double> selectedRowIds,
    double? focusedRowId,
    Set<String> selectedCellIds,
    SelectionMode mode,
  });
}

/// @nodoc
class _$SelectionStateCopyWithImpl<$Res, $Val extends SelectionState>
    implements $SelectionStateCopyWith<$Res> {
  _$SelectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedRowIds = null,
    Object? focusedRowId = freezed,
    Object? selectedCellIds = null,
    Object? mode = null,
  }) {
    return _then(
      _value.copyWith(
            selectedRowIds: null == selectedRowIds
                ? _value.selectedRowIds
                : selectedRowIds // ignore: cast_nullable_to_non_nullable
                      as Set<double>,
            focusedRowId: freezed == focusedRowId
                ? _value.focusedRowId
                : focusedRowId // ignore: cast_nullable_to_non_nullable
                      as double?,
            selectedCellIds: null == selectedCellIds
                ? _value.selectedCellIds
                : selectedCellIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as SelectionMode,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SelectionStateImplCopyWith<$Res>
    implements $SelectionStateCopyWith<$Res> {
  factory _$$SelectionStateImplCopyWith(
    _$SelectionStateImpl value,
    $Res Function(_$SelectionStateImpl) then,
  ) = __$$SelectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Set<double> selectedRowIds,
    double? focusedRowId,
    Set<String> selectedCellIds,
    SelectionMode mode,
  });
}

/// @nodoc
class __$$SelectionStateImplCopyWithImpl<$Res>
    extends _$SelectionStateCopyWithImpl<$Res, _$SelectionStateImpl>
    implements _$$SelectionStateImplCopyWith<$Res> {
  __$$SelectionStateImplCopyWithImpl(
    _$SelectionStateImpl _value,
    $Res Function(_$SelectionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SelectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedRowIds = null,
    Object? focusedRowId = freezed,
    Object? selectedCellIds = null,
    Object? mode = null,
  }) {
    return _then(
      _$SelectionStateImpl(
        selectedRowIds: null == selectedRowIds
            ? _value._selectedRowIds
            : selectedRowIds // ignore: cast_nullable_to_non_nullable
                  as Set<double>,
        focusedRowId: freezed == focusedRowId
            ? _value.focusedRowId
            : focusedRowId // ignore: cast_nullable_to_non_nullable
                  as double?,
        selectedCellIds: null == selectedCellIds
            ? _value._selectedCellIds
            : selectedCellIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as SelectionMode,
      ),
    );
  }
}

/// @nodoc

class _$SelectionStateImpl extends _SelectionState {
  const _$SelectionStateImpl({
    required final Set<double> selectedRowIds,
    this.focusedRowId,
    required final Set<String> selectedCellIds,
    required this.mode,
  }) : _selectedRowIds = selectedRowIds,
       _selectedCellIds = selectedCellIds,
       super._();

  final Set<double> _selectedRowIds;
  @override
  Set<double> get selectedRowIds {
    if (_selectedRowIds is EqualUnmodifiableSetView) return _selectedRowIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedRowIds);
  }

  @override
  final double? focusedRowId;
  final Set<String> _selectedCellIds;
  @override
  Set<String> get selectedCellIds {
    if (_selectedCellIds is EqualUnmodifiableSetView) return _selectedCellIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedCellIds);
  }

  @override
  final SelectionMode mode;

  @override
  String toString() {
    return 'SelectionState(selectedRowIds: $selectedRowIds, focusedRowId: $focusedRowId, selectedCellIds: $selectedCellIds, mode: $mode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectionStateImpl &&
            const DeepCollectionEquality().equals(
              other._selectedRowIds,
              _selectedRowIds,
            ) &&
            (identical(other.focusedRowId, focusedRowId) ||
                other.focusedRowId == focusedRowId) &&
            const DeepCollectionEquality().equals(
              other._selectedCellIds,
              _selectedCellIds,
            ) &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_selectedRowIds),
    focusedRowId,
    const DeepCollectionEquality().hash(_selectedCellIds),
    mode,
  );

  /// Create a copy of SelectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectionStateImplCopyWith<_$SelectionStateImpl> get copyWith =>
      __$$SelectionStateImplCopyWithImpl<_$SelectionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _SelectionState extends SelectionState {
  const factory _SelectionState({
    required final Set<double> selectedRowIds,
    final double? focusedRowId,
    required final Set<String> selectedCellIds,
    required final SelectionMode mode,
  }) = _$SelectionStateImpl;
  const _SelectionState._() : super._();

  @override
  Set<double> get selectedRowIds;
  @override
  double? get focusedRowId;
  @override
  Set<String> get selectedCellIds;
  @override
  SelectionMode get mode;

  /// Create a copy of SelectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectionStateImplCopyWith<_$SelectionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SortState {
  List<SortColumn> get sortColumns => throw _privateConstructorUsedError;

  /// Create a copy of SortState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SortStateCopyWith<SortState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SortStateCopyWith<$Res> {
  factory $SortStateCopyWith(SortState value, $Res Function(SortState) then) =
      _$SortStateCopyWithImpl<$Res, SortState>;
  @useResult
  $Res call({List<SortColumn> sortColumns});
}

/// @nodoc
class _$SortStateCopyWithImpl<$Res, $Val extends SortState>
    implements $SortStateCopyWith<$Res> {
  _$SortStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SortState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sortColumns = null}) {
    return _then(
      _value.copyWith(
            sortColumns: null == sortColumns
                ? _value.sortColumns
                : sortColumns // ignore: cast_nullable_to_non_nullable
                      as List<SortColumn>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SortStateImplCopyWith<$Res>
    implements $SortStateCopyWith<$Res> {
  factory _$$SortStateImplCopyWith(
    _$SortStateImpl value,
    $Res Function(_$SortStateImpl) then,
  ) = __$$SortStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SortColumn> sortColumns});
}

/// @nodoc
class __$$SortStateImplCopyWithImpl<$Res>
    extends _$SortStateCopyWithImpl<$Res, _$SortStateImpl>
    implements _$$SortStateImplCopyWith<$Res> {
  __$$SortStateImplCopyWithImpl(
    _$SortStateImpl _value,
    $Res Function(_$SortStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SortState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sortColumns = null}) {
    return _then(
      _$SortStateImpl(
        sortColumns: null == sortColumns
            ? _value._sortColumns
            : sortColumns // ignore: cast_nullable_to_non_nullable
                  as List<SortColumn>,
      ),
    );
  }
}

/// @nodoc

class _$SortStateImpl extends _SortState {
  const _$SortStateImpl({required final List<SortColumn> sortColumns})
    : _sortColumns = sortColumns,
      super._();

  final List<SortColumn> _sortColumns;
  @override
  List<SortColumn> get sortColumns {
    if (_sortColumns is EqualUnmodifiableListView) return _sortColumns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sortColumns);
  }

  @override
  String toString() {
    return 'SortState(sortColumns: $sortColumns)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SortStateImpl &&
            const DeepCollectionEquality().equals(
              other._sortColumns,
              _sortColumns,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_sortColumns),
  );

  /// Create a copy of SortState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SortStateImplCopyWith<_$SortStateImpl> get copyWith =>
      __$$SortStateImplCopyWithImpl<_$SortStateImpl>(this, _$identity);
}

abstract class _SortState extends SortState {
  const factory _SortState({required final List<SortColumn> sortColumns}) =
      _$SortStateImpl;
  const _SortState._() : super._();

  @override
  List<SortColumn> get sortColumns;

  /// Create a copy of SortState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SortStateImplCopyWith<_$SortStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SortColumn {
  int get columnId => throw _privateConstructorUsedError;
  SortDirection get direction => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;

  /// Create a copy of SortColumn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SortColumnCopyWith<SortColumn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SortColumnCopyWith<$Res> {
  factory $SortColumnCopyWith(
    SortColumn value,
    $Res Function(SortColumn) then,
  ) = _$SortColumnCopyWithImpl<$Res, SortColumn>;
  @useResult
  $Res call({int columnId, SortDirection direction, int priority});
}

/// @nodoc
class _$SortColumnCopyWithImpl<$Res, $Val extends SortColumn>
    implements $SortColumnCopyWith<$Res> {
  _$SortColumnCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SortColumn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? direction = null,
    Object? priority = null,
  }) {
    return _then(
      _value.copyWith(
            columnId: null == columnId
                ? _value.columnId
                : columnId // ignore: cast_nullable_to_non_nullable
                      as int,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as SortDirection,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SortColumnImplCopyWith<$Res>
    implements $SortColumnCopyWith<$Res> {
  factory _$$SortColumnImplCopyWith(
    _$SortColumnImpl value,
    $Res Function(_$SortColumnImpl) then,
  ) = __$$SortColumnImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int columnId, SortDirection direction, int priority});
}

/// @nodoc
class __$$SortColumnImplCopyWithImpl<$Res>
    extends _$SortColumnCopyWithImpl<$Res, _$SortColumnImpl>
    implements _$$SortColumnImplCopyWith<$Res> {
  __$$SortColumnImplCopyWithImpl(
    _$SortColumnImpl _value,
    $Res Function(_$SortColumnImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SortColumn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? direction = null,
    Object? priority = null,
  }) {
    return _then(
      _$SortColumnImpl(
        columnId: null == columnId
            ? _value.columnId
            : columnId // ignore: cast_nullable_to_non_nullable
                  as int,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as SortDirection,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$SortColumnImpl implements _SortColumn {
  const _$SortColumnImpl({
    required this.columnId,
    required this.direction,
    required this.priority,
  });

  @override
  final int columnId;
  @override
  final SortDirection direction;
  @override
  final int priority;

  @override
  String toString() {
    return 'SortColumn(columnId: $columnId, direction: $direction, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SortColumnImpl &&
            (identical(other.columnId, columnId) ||
                other.columnId == columnId) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @override
  int get hashCode => Object.hash(runtimeType, columnId, direction, priority);

  /// Create a copy of SortColumn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SortColumnImplCopyWith<_$SortColumnImpl> get copyWith =>
      __$$SortColumnImplCopyWithImpl<_$SortColumnImpl>(this, _$identity);
}

abstract class _SortColumn implements SortColumn {
  const factory _SortColumn({
    required final int columnId,
    required final SortDirection direction,
    required final int priority,
  }) = _$SortColumnImpl;

  @override
  int get columnId;
  @override
  SortDirection get direction;
  @override
  int get priority;

  /// Create a copy of SortColumn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SortColumnImplCopyWith<_$SortColumnImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FilterState {
  Map<int, ColumnFilter> get columnFilters =>
      throw _privateConstructorUsedError;

  /// Create a copy of FilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FilterStateCopyWith<FilterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FilterStateCopyWith<$Res> {
  factory $FilterStateCopyWith(
    FilterState value,
    $Res Function(FilterState) then,
  ) = _$FilterStateCopyWithImpl<$Res, FilterState>;
  @useResult
  $Res call({Map<int, ColumnFilter> columnFilters});
}

/// @nodoc
class _$FilterStateCopyWithImpl<$Res, $Val extends FilterState>
    implements $FilterStateCopyWith<$Res> {
  _$FilterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? columnFilters = null}) {
    return _then(
      _value.copyWith(
            columnFilters: null == columnFilters
                ? _value.columnFilters
                : columnFilters // ignore: cast_nullable_to_non_nullable
                      as Map<int, ColumnFilter>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FilterStateImplCopyWith<$Res>
    implements $FilterStateCopyWith<$Res> {
  factory _$$FilterStateImplCopyWith(
    _$FilterStateImpl value,
    $Res Function(_$FilterStateImpl) then,
  ) = __$$FilterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<int, ColumnFilter> columnFilters});
}

/// @nodoc
class __$$FilterStateImplCopyWithImpl<$Res>
    extends _$FilterStateCopyWithImpl<$Res, _$FilterStateImpl>
    implements _$$FilterStateImplCopyWith<$Res> {
  __$$FilterStateImplCopyWithImpl(
    _$FilterStateImpl _value,
    $Res Function(_$FilterStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? columnFilters = null}) {
    return _then(
      _$FilterStateImpl(
        columnFilters: null == columnFilters
            ? _value._columnFilters
            : columnFilters // ignore: cast_nullable_to_non_nullable
                  as Map<int, ColumnFilter>,
      ),
    );
  }
}

/// @nodoc

class _$FilterStateImpl extends _FilterState {
  const _$FilterStateImpl({required final Map<int, ColumnFilter> columnFilters})
    : _columnFilters = columnFilters,
      super._();

  final Map<int, ColumnFilter> _columnFilters;
  @override
  Map<int, ColumnFilter> get columnFilters {
    if (_columnFilters is EqualUnmodifiableMapView) return _columnFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_columnFilters);
  }

  @override
  String toString() {
    return 'FilterState(columnFilters: $columnFilters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterStateImpl &&
            const DeepCollectionEquality().equals(
              other._columnFilters,
              _columnFilters,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_columnFilters),
  );

  /// Create a copy of FilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterStateImplCopyWith<_$FilterStateImpl> get copyWith =>
      __$$FilterStateImplCopyWithImpl<_$FilterStateImpl>(this, _$identity);
}

abstract class _FilterState extends FilterState {
  const factory _FilterState({
    required final Map<int, ColumnFilter> columnFilters,
  }) = _$FilterStateImpl;
  const _FilterState._() : super._();

  @override
  Map<int, ColumnFilter> get columnFilters;

  /// Create a copy of FilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterStateImplCopyWith<_$FilterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ColumnFilter {
  int get columnId => throw _privateConstructorUsedError;
  FilterOperator get operator => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;

  /// Create a copy of ColumnFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnFilterCopyWith<ColumnFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnFilterCopyWith<$Res> {
  factory $ColumnFilterCopyWith(
    ColumnFilter value,
    $Res Function(ColumnFilter) then,
  ) = _$ColumnFilterCopyWithImpl<$Res, ColumnFilter>;
  @useResult
  $Res call({int columnId, FilterOperator operator, dynamic value});
}

/// @nodoc
class _$ColumnFilterCopyWithImpl<$Res, $Val extends ColumnFilter>
    implements $ColumnFilterCopyWith<$Res> {
  _$ColumnFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColumnFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? operator = null,
    Object? value = freezed,
  }) {
    return _then(
      _value.copyWith(
            columnId: null == columnId
                ? _value.columnId
                : columnId // ignore: cast_nullable_to_non_nullable
                      as int,
            operator: null == operator
                ? _value.operator
                : operator // ignore: cast_nullable_to_non_nullable
                      as FilterOperator,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ColumnFilterImplCopyWith<$Res>
    implements $ColumnFilterCopyWith<$Res> {
  factory _$$ColumnFilterImplCopyWith(
    _$ColumnFilterImpl value,
    $Res Function(_$ColumnFilterImpl) then,
  ) = __$$ColumnFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int columnId, FilterOperator operator, dynamic value});
}

/// @nodoc
class __$$ColumnFilterImplCopyWithImpl<$Res>
    extends _$ColumnFilterCopyWithImpl<$Res, _$ColumnFilterImpl>
    implements _$$ColumnFilterImplCopyWith<$Res> {
  __$$ColumnFilterImplCopyWithImpl(
    _$ColumnFilterImpl _value,
    $Res Function(_$ColumnFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ColumnFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? operator = null,
    Object? value = freezed,
  }) {
    return _then(
      _$ColumnFilterImpl(
        columnId: null == columnId
            ? _value.columnId
            : columnId // ignore: cast_nullable_to_non_nullable
                  as int,
        operator: null == operator
            ? _value.operator
            : operator // ignore: cast_nullable_to_non_nullable
                  as FilterOperator,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc

class _$ColumnFilterImpl implements _ColumnFilter {
  const _$ColumnFilterImpl({
    required this.columnId,
    required this.operator,
    required this.value,
  });

  @override
  final int columnId;
  @override
  final FilterOperator operator;
  @override
  final dynamic value;

  @override
  String toString() {
    return 'ColumnFilter(columnId: $columnId, operator: $operator, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnFilterImpl &&
            (identical(other.columnId, columnId) ||
                other.columnId == columnId) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    columnId,
    operator,
    const DeepCollectionEquality().hash(value),
  );

  /// Create a copy of ColumnFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnFilterImplCopyWith<_$ColumnFilterImpl> get copyWith =>
      __$$ColumnFilterImplCopyWithImpl<_$ColumnFilterImpl>(this, _$identity);
}

abstract class _ColumnFilter implements ColumnFilter {
  const factory _ColumnFilter({
    required final int columnId,
    required final FilterOperator operator,
    required final dynamic value,
  }) = _$ColumnFilterImpl;

  @override
  int get columnId;
  @override
  FilterOperator get operator;
  @override
  dynamic get value;

  /// Create a copy of ColumnFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnFilterImplCopyWith<_$ColumnFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GroupState {
  List<int> get groupedColumnIds => throw _privateConstructorUsedError;
  Map<String, bool> get expandedGroups => throw _privateConstructorUsedError;

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupStateCopyWith<GroupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupStateCopyWith<$Res> {
  factory $GroupStateCopyWith(
    GroupState value,
    $Res Function(GroupState) then,
  ) = _$GroupStateCopyWithImpl<$Res, GroupState>;
  @useResult
  $Res call({List<int> groupedColumnIds, Map<String, bool> expandedGroups});
}

/// @nodoc
class _$GroupStateCopyWithImpl<$Res, $Val extends GroupState>
    implements $GroupStateCopyWith<$Res> {
  _$GroupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? groupedColumnIds = null, Object? expandedGroups = null}) {
    return _then(
      _value.copyWith(
            groupedColumnIds: null == groupedColumnIds
                ? _value.groupedColumnIds
                : groupedColumnIds // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            expandedGroups: null == expandedGroups
                ? _value.expandedGroups
                : expandedGroups // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupStateImplCopyWith<$Res>
    implements $GroupStateCopyWith<$Res> {
  factory _$$GroupStateImplCopyWith(
    _$GroupStateImpl value,
    $Res Function(_$GroupStateImpl) then,
  ) = __$$GroupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int> groupedColumnIds, Map<String, bool> expandedGroups});
}

/// @nodoc
class __$$GroupStateImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupStateImpl>
    implements _$$GroupStateImplCopyWith<$Res> {
  __$$GroupStateImplCopyWithImpl(
    _$GroupStateImpl _value,
    $Res Function(_$GroupStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? groupedColumnIds = null, Object? expandedGroups = null}) {
    return _then(
      _$GroupStateImpl(
        groupedColumnIds: null == groupedColumnIds
            ? _value._groupedColumnIds
            : groupedColumnIds // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        expandedGroups: null == expandedGroups
            ? _value._expandedGroups
            : expandedGroups // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
      ),
    );
  }
}

/// @nodoc

class _$GroupStateImpl extends _GroupState {
  const _$GroupStateImpl({
    required final List<int> groupedColumnIds,
    required final Map<String, bool> expandedGroups,
  }) : _groupedColumnIds = groupedColumnIds,
       _expandedGroups = expandedGroups,
       super._();

  final List<int> _groupedColumnIds;
  @override
  List<int> get groupedColumnIds {
    if (_groupedColumnIds is EqualUnmodifiableListView)
      return _groupedColumnIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groupedColumnIds);
  }

  final Map<String, bool> _expandedGroups;
  @override
  Map<String, bool> get expandedGroups {
    if (_expandedGroups is EqualUnmodifiableMapView) return _expandedGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_expandedGroups);
  }

  @override
  String toString() {
    return 'GroupState(groupedColumnIds: $groupedColumnIds, expandedGroups: $expandedGroups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupStateImpl &&
            const DeepCollectionEquality().equals(
              other._groupedColumnIds,
              _groupedColumnIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._expandedGroups,
              _expandedGroups,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_groupedColumnIds),
    const DeepCollectionEquality().hash(_expandedGroups),
  );

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupStateImplCopyWith<_$GroupStateImpl> get copyWith =>
      __$$GroupStateImplCopyWithImpl<_$GroupStateImpl>(this, _$identity);
}

abstract class _GroupState extends GroupState {
  const factory _GroupState({
    required final List<int> groupedColumnIds,
    required final Map<String, bool> expandedGroups,
  }) = _$GroupStateImpl;
  const _GroupState._() : super._();

  @override
  List<int> get groupedColumnIds;
  @override
  Map<String, bool> get expandedGroups;

  /// Create a copy of GroupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupStateImplCopyWith<_$GroupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EditState {
  String? get editingCellId => throw _privateConstructorUsedError;
  dynamic get editingValue => throw _privateConstructorUsedError;

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EditStateCopyWith<EditState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EditStateCopyWith<$Res> {
  factory $EditStateCopyWith(EditState value, $Res Function(EditState) then) =
      _$EditStateCopyWithImpl<$Res, EditState>;
  @useResult
  $Res call({String? editingCellId, dynamic editingValue});
}

/// @nodoc
class _$EditStateCopyWithImpl<$Res, $Val extends EditState>
    implements $EditStateCopyWith<$Res> {
  _$EditStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? editingCellId = freezed, Object? editingValue = freezed}) {
    return _then(
      _value.copyWith(
            editingCellId: freezed == editingCellId
                ? _value.editingCellId
                : editingCellId // ignore: cast_nullable_to_non_nullable
                      as String?,
            editingValue: freezed == editingValue
                ? _value.editingValue
                : editingValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EditStateImplCopyWith<$Res>
    implements $EditStateCopyWith<$Res> {
  factory _$$EditStateImplCopyWith(
    _$EditStateImpl value,
    $Res Function(_$EditStateImpl) then,
  ) = __$$EditStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? editingCellId, dynamic editingValue});
}

/// @nodoc
class __$$EditStateImplCopyWithImpl<$Res>
    extends _$EditStateCopyWithImpl<$Res, _$EditStateImpl>
    implements _$$EditStateImplCopyWith<$Res> {
  __$$EditStateImplCopyWithImpl(
    _$EditStateImpl _value,
    $Res Function(_$EditStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? editingCellId = freezed, Object? editingValue = freezed}) {
    return _then(
      _$EditStateImpl(
        editingCellId: freezed == editingCellId
            ? _value.editingCellId
            : editingCellId // ignore: cast_nullable_to_non_nullable
                  as String?,
        editingValue: freezed == editingValue
            ? _value.editingValue
            : editingValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc

class _$EditStateImpl extends _EditState {
  const _$EditStateImpl({this.editingCellId, this.editingValue}) : super._();

  @override
  final String? editingCellId;
  @override
  final dynamic editingValue;

  @override
  String toString() {
    return 'EditState(editingCellId: $editingCellId, editingValue: $editingValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditStateImpl &&
            (identical(other.editingCellId, editingCellId) ||
                other.editingCellId == editingCellId) &&
            const DeepCollectionEquality().equals(
              other.editingValue,
              editingValue,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    editingCellId,
    const DeepCollectionEquality().hash(editingValue),
  );

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditStateImplCopyWith<_$EditStateImpl> get copyWith =>
      __$$EditStateImplCopyWithImpl<_$EditStateImpl>(this, _$identity);
}

abstract class _EditState extends EditState {
  const factory _EditState({
    final String? editingCellId,
    final dynamic editingValue,
  }) = _$EditStateImpl;
  const _EditState._() : super._();

  @override
  String? get editingCellId;
  @override
  dynamic get editingValue;

  /// Create a copy of EditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditStateImplCopyWith<_$EditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
