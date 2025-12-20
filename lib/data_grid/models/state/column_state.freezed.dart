// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'column_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ColumnState {
  int get columnId => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  bool get visible => throw _privateConstructorUsedError;
  bool get pinned => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  bool get resizable => throw _privateConstructorUsedError;
  bool get sortable => throw _privateConstructorUsedError;
  bool get filterable => throw _privateConstructorUsedError;

  /// Create a copy of ColumnState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnStateCopyWith<ColumnState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnStateCopyWith<$Res> {
  factory $ColumnStateCopyWith(
    ColumnState value,
    $Res Function(ColumnState) then,
  ) = _$ColumnStateCopyWithImpl<$Res, ColumnState>;
  @useResult
  $Res call({
    int columnId,
    double width,
    bool visible,
    bool pinned,
    int order,
    bool resizable,
    bool sortable,
    bool filterable,
  });
}

/// @nodoc
class _$ColumnStateCopyWithImpl<$Res, $Val extends ColumnState>
    implements $ColumnStateCopyWith<$Res> {
  _$ColumnStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColumnState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? width = null,
    Object? visible = null,
    Object? pinned = null,
    Object? order = null,
    Object? resizable = null,
    Object? sortable = null,
    Object? filterable = null,
  }) {
    return _then(
      _value.copyWith(
            columnId: null == columnId
                ? _value.columnId
                : columnId // ignore: cast_nullable_to_non_nullable
                      as int,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            pinned: null == pinned
                ? _value.pinned
                : pinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            resizable: null == resizable
                ? _value.resizable
                : resizable // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortable: null == sortable
                ? _value.sortable
                : sortable // ignore: cast_nullable_to_non_nullable
                      as bool,
            filterable: null == filterable
                ? _value.filterable
                : filterable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ColumnStateImplCopyWith<$Res>
    implements $ColumnStateCopyWith<$Res> {
  factory _$$ColumnStateImplCopyWith(
    _$ColumnStateImpl value,
    $Res Function(_$ColumnStateImpl) then,
  ) = __$$ColumnStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int columnId,
    double width,
    bool visible,
    bool pinned,
    int order,
    bool resizable,
    bool sortable,
    bool filterable,
  });
}

/// @nodoc
class __$$ColumnStateImplCopyWithImpl<$Res>
    extends _$ColumnStateCopyWithImpl<$Res, _$ColumnStateImpl>
    implements _$$ColumnStateImplCopyWith<$Res> {
  __$$ColumnStateImplCopyWithImpl(
    _$ColumnStateImpl _value,
    $Res Function(_$ColumnStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ColumnState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columnId = null,
    Object? width = null,
    Object? visible = null,
    Object? pinned = null,
    Object? order = null,
    Object? resizable = null,
    Object? sortable = null,
    Object? filterable = null,
  }) {
    return _then(
      _$ColumnStateImpl(
        columnId: null == columnId
            ? _value.columnId
            : columnId // ignore: cast_nullable_to_non_nullable
                  as int,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        pinned: null == pinned
            ? _value.pinned
            : pinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        resizable: null == resizable
            ? _value.resizable
            : resizable // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortable: null == sortable
            ? _value.sortable
            : sortable // ignore: cast_nullable_to_non_nullable
                  as bool,
        filterable: null == filterable
            ? _value.filterable
            : filterable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ColumnStateImpl implements _ColumnState {
  const _$ColumnStateImpl({
    required this.columnId,
    required this.width,
    this.visible = true,
    this.pinned = false,
    required this.order,
    this.resizable = true,
    this.sortable = true,
    this.filterable = true,
  });

  @override
  final int columnId;
  @override
  final double width;
  @override
  @JsonKey()
  final bool visible;
  @override
  @JsonKey()
  final bool pinned;
  @override
  final int order;
  @override
  @JsonKey()
  final bool resizable;
  @override
  @JsonKey()
  final bool sortable;
  @override
  @JsonKey()
  final bool filterable;

  @override
  String toString() {
    return 'ColumnState(columnId: $columnId, width: $width, visible: $visible, pinned: $pinned, order: $order, resizable: $resizable, sortable: $sortable, filterable: $filterable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnStateImpl &&
            (identical(other.columnId, columnId) ||
                other.columnId == columnId) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.resizable, resizable) ||
                other.resizable == resizable) &&
            (identical(other.sortable, sortable) ||
                other.sortable == sortable) &&
            (identical(other.filterable, filterable) ||
                other.filterable == filterable));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    columnId,
    width,
    visible,
    pinned,
    order,
    resizable,
    sortable,
    filterable,
  );

  /// Create a copy of ColumnState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnStateImplCopyWith<_$ColumnStateImpl> get copyWith =>
      __$$ColumnStateImplCopyWithImpl<_$ColumnStateImpl>(this, _$identity);
}

abstract class _ColumnState implements ColumnState {
  const factory _ColumnState({
    required final int columnId,
    required final double width,
    final bool visible,
    final bool pinned,
    required final int order,
    final bool resizable,
    final bool sortable,
    final bool filterable,
  }) = _$ColumnStateImpl;

  @override
  int get columnId;
  @override
  double get width;
  @override
  bool get visible;
  @override
  bool get pinned;
  @override
  int get order;
  @override
  bool get resizable;
  @override
  bool get sortable;
  @override
  bool get filterable;

  /// Create a copy of ColumnState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnStateImplCopyWith<_$ColumnStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ColumnsState {
  Map<int, ColumnState> get columns => throw _privateConstructorUsedError;
  List<int> get columnOrder => throw _privateConstructorUsedError;
  double get totalWidth => throw _privateConstructorUsedError;

  /// Create a copy of ColumnsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnsStateCopyWith<ColumnsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnsStateCopyWith<$Res> {
  factory $ColumnsStateCopyWith(
    ColumnsState value,
    $Res Function(ColumnsState) then,
  ) = _$ColumnsStateCopyWithImpl<$Res, ColumnsState>;
  @useResult
  $Res call({
    Map<int, ColumnState> columns,
    List<int> columnOrder,
    double totalWidth,
  });
}

/// @nodoc
class _$ColumnsStateCopyWithImpl<$Res, $Val extends ColumnsState>
    implements $ColumnsStateCopyWith<$Res> {
  _$ColumnsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColumnsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columns = null,
    Object? columnOrder = null,
    Object? totalWidth = null,
  }) {
    return _then(
      _value.copyWith(
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as Map<int, ColumnState>,
            columnOrder: null == columnOrder
                ? _value.columnOrder
                : columnOrder // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            totalWidth: null == totalWidth
                ? _value.totalWidth
                : totalWidth // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ColumnsStateImplCopyWith<$Res>
    implements $ColumnsStateCopyWith<$Res> {
  factory _$$ColumnsStateImplCopyWith(
    _$ColumnsStateImpl value,
    $Res Function(_$ColumnsStateImpl) then,
  ) = __$$ColumnsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<int, ColumnState> columns,
    List<int> columnOrder,
    double totalWidth,
  });
}

/// @nodoc
class __$$ColumnsStateImplCopyWithImpl<$Res>
    extends _$ColumnsStateCopyWithImpl<$Res, _$ColumnsStateImpl>
    implements _$$ColumnsStateImplCopyWith<$Res> {
  __$$ColumnsStateImplCopyWithImpl(
    _$ColumnsStateImpl _value,
    $Res Function(_$ColumnsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ColumnsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? columns = null,
    Object? columnOrder = null,
    Object? totalWidth = null,
  }) {
    return _then(
      _$ColumnsStateImpl(
        columns: null == columns
            ? _value._columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as Map<int, ColumnState>,
        columnOrder: null == columnOrder
            ? _value._columnOrder
            : columnOrder // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        totalWidth: null == totalWidth
            ? _value.totalWidth
            : totalWidth // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$ColumnsStateImpl extends _ColumnsState {
  const _$ColumnsStateImpl({
    required final Map<int, ColumnState> columns,
    required final List<int> columnOrder,
    required this.totalWidth,
  }) : _columns = columns,
       _columnOrder = columnOrder,
       super._();

  final Map<int, ColumnState> _columns;
  @override
  Map<int, ColumnState> get columns {
    if (_columns is EqualUnmodifiableMapView) return _columns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_columns);
  }

  final List<int> _columnOrder;
  @override
  List<int> get columnOrder {
    if (_columnOrder is EqualUnmodifiableListView) return _columnOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_columnOrder);
  }

  @override
  final double totalWidth;

  @override
  String toString() {
    return 'ColumnsState(columns: $columns, columnOrder: $columnOrder, totalWidth: $totalWidth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnsStateImpl &&
            const DeepCollectionEquality().equals(other._columns, _columns) &&
            const DeepCollectionEquality().equals(
              other._columnOrder,
              _columnOrder,
            ) &&
            (identical(other.totalWidth, totalWidth) ||
                other.totalWidth == totalWidth));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_columns),
    const DeepCollectionEquality().hash(_columnOrder),
    totalWidth,
  );

  /// Create a copy of ColumnsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnsStateImplCopyWith<_$ColumnsStateImpl> get copyWith =>
      __$$ColumnsStateImplCopyWithImpl<_$ColumnsStateImpl>(this, _$identity);
}

abstract class _ColumnsState extends ColumnsState {
  const factory _ColumnsState({
    required final Map<int, ColumnState> columns,
    required final List<int> columnOrder,
    required final double totalWidth,
  }) = _$ColumnsStateImpl;
  const _ColumnsState._() : super._();

  @override
  Map<int, ColumnState> get columns;
  @override
  List<int> get columnOrder;
  @override
  double get totalWidth;

  /// Create a copy of ColumnsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnsStateImplCopyWith<_$ColumnsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
