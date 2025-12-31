// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grid_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DataGridState<T extends DataGridRow> {

 List<DataGridColumn<T>> get columns; Map<double, T> get rowsById; List<double> get displayOrder; ViewportState get viewport; SelectionState get selection; SortState get sort; FilterState get filter; GroupState get group; EditState get edit; bool get isLoading; String? get loadingMessage;
/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataGridStateCopyWith<T, DataGridState<T>> get copyWith => _$DataGridStateCopyWithImpl<T, DataGridState<T>>(this as DataGridState<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataGridState<T>&&const DeepCollectionEquality().equals(other.columns, columns)&&const DeepCollectionEquality().equals(other.rowsById, rowsById)&&const DeepCollectionEquality().equals(other.displayOrder, displayOrder)&&(identical(other.viewport, viewport) || other.viewport == viewport)&&(identical(other.selection, selection) || other.selection == selection)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.group, group) || other.group == group)&&(identical(other.edit, edit) || other.edit == edit)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.loadingMessage, loadingMessage) || other.loadingMessage == loadingMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(columns),const DeepCollectionEquality().hash(rowsById),const DeepCollectionEquality().hash(displayOrder),viewport,selection,sort,filter,group,edit,isLoading,loadingMessage);

@override
String toString() {
  return 'DataGridState<$T>(columns: $columns, rowsById: $rowsById, displayOrder: $displayOrder, viewport: $viewport, selection: $selection, sort: $sort, filter: $filter, group: $group, edit: $edit, isLoading: $isLoading, loadingMessage: $loadingMessage)';
}


}

/// @nodoc
abstract mixin class $DataGridStateCopyWith<T extends DataGridRow,$Res>  {
  factory $DataGridStateCopyWith(DataGridState<T> value, $Res Function(DataGridState<T>) _then) = _$DataGridStateCopyWithImpl;
@useResult
$Res call({
 List<DataGridColumn<T>> columns, Map<double, T> rowsById, List<double> displayOrder, ViewportState viewport, SelectionState selection, SortState sort, FilterState filter, GroupState group, EditState edit, bool isLoading, String? loadingMessage
});


$ViewportStateCopyWith<$Res> get viewport;$SelectionStateCopyWith<$Res> get selection;$SortStateCopyWith<$Res> get sort;$FilterStateCopyWith<$Res> get filter;$GroupStateCopyWith<$Res> get group;$EditStateCopyWith<$Res> get edit;

}
/// @nodoc
class _$DataGridStateCopyWithImpl<T extends DataGridRow,$Res>
    implements $DataGridStateCopyWith<T, $Res> {
  _$DataGridStateCopyWithImpl(this._self, this._then);

  final DataGridState<T> _self;
  final $Res Function(DataGridState<T>) _then;

/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columns = null,Object? rowsById = null,Object? displayOrder = null,Object? viewport = null,Object? selection = null,Object? sort = null,Object? filter = null,Object? group = null,Object? edit = null,Object? isLoading = null,Object? loadingMessage = freezed,}) {
  return _then(_self.copyWith(
columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<DataGridColumn<T>>,rowsById: null == rowsById ? _self.rowsById : rowsById // ignore: cast_nullable_to_non_nullable
as Map<double, T>,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as List<double>,viewport: null == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as ViewportState,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as SelectionState,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SortState,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as FilterState,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as GroupState,edit: null == edit ? _self.edit : edit // ignore: cast_nullable_to_non_nullable
as EditState,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadingMessage: freezed == loadingMessage ? _self.loadingMessage : loadingMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewportStateCopyWith<$Res> get viewport {
  
  return $ViewportStateCopyWith<$Res>(_self.viewport, (value) {
    return _then(_self.copyWith(viewport: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SelectionStateCopyWith<$Res> get selection {
  
  return $SelectionStateCopyWith<$Res>(_self.selection, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SortStateCopyWith<$Res> get sort {
  
  return $SortStateCopyWith<$Res>(_self.sort, (value) {
    return _then(_self.copyWith(sort: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FilterStateCopyWith<$Res> get filter {
  
  return $FilterStateCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupStateCopyWith<$Res> get group {
  
  return $GroupStateCopyWith<$Res>(_self.group, (value) {
    return _then(_self.copyWith(group: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditStateCopyWith<$Res> get edit {
  
  return $EditStateCopyWith<$Res>(_self.edit, (value) {
    return _then(_self.copyWith(edit: value));
  });
}
}


/// Adds pattern-matching-related methods to [DataGridState].
extension DataGridStatePatterns<T extends DataGridRow> on DataGridState<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataGridState<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataGridState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataGridState<T> value)  $default,){
final _that = this;
switch (_that) {
case _DataGridState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataGridState<T> value)?  $default,){
final _that = this;
switch (_that) {
case _DataGridState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DataGridColumn<T>> columns,  Map<double, T> rowsById,  List<double> displayOrder,  ViewportState viewport,  SelectionState selection,  SortState sort,  FilterState filter,  GroupState group,  EditState edit,  bool isLoading,  String? loadingMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataGridState() when $default != null:
return $default(_that.columns,_that.rowsById,_that.displayOrder,_that.viewport,_that.selection,_that.sort,_that.filter,_that.group,_that.edit,_that.isLoading,_that.loadingMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DataGridColumn<T>> columns,  Map<double, T> rowsById,  List<double> displayOrder,  ViewportState viewport,  SelectionState selection,  SortState sort,  FilterState filter,  GroupState group,  EditState edit,  bool isLoading,  String? loadingMessage)  $default,) {final _that = this;
switch (_that) {
case _DataGridState():
return $default(_that.columns,_that.rowsById,_that.displayOrder,_that.viewport,_that.selection,_that.sort,_that.filter,_that.group,_that.edit,_that.isLoading,_that.loadingMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DataGridColumn<T>> columns,  Map<double, T> rowsById,  List<double> displayOrder,  ViewportState viewport,  SelectionState selection,  SortState sort,  FilterState filter,  GroupState group,  EditState edit,  bool isLoading,  String? loadingMessage)?  $default,) {final _that = this;
switch (_that) {
case _DataGridState() when $default != null:
return $default(_that.columns,_that.rowsById,_that.displayOrder,_that.viewport,_that.selection,_that.sort,_that.filter,_that.group,_that.edit,_that.isLoading,_that.loadingMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DataGridState<T extends DataGridRow> extends DataGridState<T> {
  const _DataGridState({required final  List<DataGridColumn<T>> columns, required final  Map<double, T> rowsById, required final  List<double> displayOrder, required this.viewport, required this.selection, required this.sort, required this.filter, required this.group, required this.edit, this.isLoading = false, this.loadingMessage}): _columns = columns,_rowsById = rowsById,_displayOrder = displayOrder,super._();
  

 final  List<DataGridColumn<T>> _columns;
@override List<DataGridColumn<T>> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  Map<double, T> _rowsById;
@override Map<double, T> get rowsById {
  if (_rowsById is EqualUnmodifiableMapView) return _rowsById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rowsById);
}

 final  List<double> _displayOrder;
@override List<double> get displayOrder {
  if (_displayOrder is EqualUnmodifiableListView) return _displayOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_displayOrder);
}

@override final  ViewportState viewport;
@override final  SelectionState selection;
@override final  SortState sort;
@override final  FilterState filter;
@override final  GroupState group;
@override final  EditState edit;
@override@JsonKey() final  bool isLoading;
@override final  String? loadingMessage;

/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataGridStateCopyWith<T, _DataGridState<T>> get copyWith => __$DataGridStateCopyWithImpl<T, _DataGridState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataGridState<T>&&const DeepCollectionEquality().equals(other._columns, _columns)&&const DeepCollectionEquality().equals(other._rowsById, _rowsById)&&const DeepCollectionEquality().equals(other._displayOrder, _displayOrder)&&(identical(other.viewport, viewport) || other.viewport == viewport)&&(identical(other.selection, selection) || other.selection == selection)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.group, group) || other.group == group)&&(identical(other.edit, edit) || other.edit == edit)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.loadingMessage, loadingMessage) || other.loadingMessage == loadingMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_rowsById),const DeepCollectionEquality().hash(_displayOrder),viewport,selection,sort,filter,group,edit,isLoading,loadingMessage);

@override
String toString() {
  return 'DataGridState<$T>(columns: $columns, rowsById: $rowsById, displayOrder: $displayOrder, viewport: $viewport, selection: $selection, sort: $sort, filter: $filter, group: $group, edit: $edit, isLoading: $isLoading, loadingMessage: $loadingMessage)';
}


}

/// @nodoc
abstract mixin class _$DataGridStateCopyWith<T extends DataGridRow,$Res> implements $DataGridStateCopyWith<T, $Res> {
  factory _$DataGridStateCopyWith(_DataGridState<T> value, $Res Function(_DataGridState<T>) _then) = __$DataGridStateCopyWithImpl;
@override @useResult
$Res call({
 List<DataGridColumn<T>> columns, Map<double, T> rowsById, List<double> displayOrder, ViewportState viewport, SelectionState selection, SortState sort, FilterState filter, GroupState group, EditState edit, bool isLoading, String? loadingMessage
});


@override $ViewportStateCopyWith<$Res> get viewport;@override $SelectionStateCopyWith<$Res> get selection;@override $SortStateCopyWith<$Res> get sort;@override $FilterStateCopyWith<$Res> get filter;@override $GroupStateCopyWith<$Res> get group;@override $EditStateCopyWith<$Res> get edit;

}
/// @nodoc
class __$DataGridStateCopyWithImpl<T extends DataGridRow,$Res>
    implements _$DataGridStateCopyWith<T, $Res> {
  __$DataGridStateCopyWithImpl(this._self, this._then);

  final _DataGridState<T> _self;
  final $Res Function(_DataGridState<T>) _then;

/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columns = null,Object? rowsById = null,Object? displayOrder = null,Object? viewport = null,Object? selection = null,Object? sort = null,Object? filter = null,Object? group = null,Object? edit = null,Object? isLoading = null,Object? loadingMessage = freezed,}) {
  return _then(_DataGridState<T>(
columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<DataGridColumn<T>>,rowsById: null == rowsById ? _self._rowsById : rowsById // ignore: cast_nullable_to_non_nullable
as Map<double, T>,displayOrder: null == displayOrder ? _self._displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as List<double>,viewport: null == viewport ? _self.viewport : viewport // ignore: cast_nullable_to_non_nullable
as ViewportState,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as SelectionState,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SortState,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as FilterState,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as GroupState,edit: null == edit ? _self.edit : edit // ignore: cast_nullable_to_non_nullable
as EditState,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,loadingMessage: freezed == loadingMessage ? _self.loadingMessage : loadingMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewportStateCopyWith<$Res> get viewport {
  
  return $ViewportStateCopyWith<$Res>(_self.viewport, (value) {
    return _then(_self.copyWith(viewport: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SelectionStateCopyWith<$Res> get selection {
  
  return $SelectionStateCopyWith<$Res>(_self.selection, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SortStateCopyWith<$Res> get sort {
  
  return $SortStateCopyWith<$Res>(_self.sort, (value) {
    return _then(_self.copyWith(sort: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FilterStateCopyWith<$Res> get filter {
  
  return $FilterStateCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupStateCopyWith<$Res> get group {
  
  return $GroupStateCopyWith<$Res>(_self.group, (value) {
    return _then(_self.copyWith(group: value));
  });
}/// Create a copy of DataGridState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EditStateCopyWith<$Res> get edit {
  
  return $EditStateCopyWith<$Res>(_self.edit, (value) {
    return _then(_self.copyWith(edit: value));
  });
}
}

/// @nodoc
mixin _$ViewportState {

 double get scrollOffsetX; double get scrollOffsetY; double get viewportWidth; double get viewportHeight; int get firstVisibleRow; int get lastVisibleRow; int get firstVisibleColumn; int get lastVisibleColumn;
/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewportStateCopyWith<ViewportState> get copyWith => _$ViewportStateCopyWithImpl<ViewportState>(this as ViewportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewportState&&(identical(other.scrollOffsetX, scrollOffsetX) || other.scrollOffsetX == scrollOffsetX)&&(identical(other.scrollOffsetY, scrollOffsetY) || other.scrollOffsetY == scrollOffsetY)&&(identical(other.viewportWidth, viewportWidth) || other.viewportWidth == viewportWidth)&&(identical(other.viewportHeight, viewportHeight) || other.viewportHeight == viewportHeight)&&(identical(other.firstVisibleRow, firstVisibleRow) || other.firstVisibleRow == firstVisibleRow)&&(identical(other.lastVisibleRow, lastVisibleRow) || other.lastVisibleRow == lastVisibleRow)&&(identical(other.firstVisibleColumn, firstVisibleColumn) || other.firstVisibleColumn == firstVisibleColumn)&&(identical(other.lastVisibleColumn, lastVisibleColumn) || other.lastVisibleColumn == lastVisibleColumn));
}


@override
int get hashCode => Object.hash(runtimeType,scrollOffsetX,scrollOffsetY,viewportWidth,viewportHeight,firstVisibleRow,lastVisibleRow,firstVisibleColumn,lastVisibleColumn);

@override
String toString() {
  return 'ViewportState(scrollOffsetX: $scrollOffsetX, scrollOffsetY: $scrollOffsetY, viewportWidth: $viewportWidth, viewportHeight: $viewportHeight, firstVisibleRow: $firstVisibleRow, lastVisibleRow: $lastVisibleRow, firstVisibleColumn: $firstVisibleColumn, lastVisibleColumn: $lastVisibleColumn)';
}


}

/// @nodoc
abstract mixin class $ViewportStateCopyWith<$Res>  {
  factory $ViewportStateCopyWith(ViewportState value, $Res Function(ViewportState) _then) = _$ViewportStateCopyWithImpl;
@useResult
$Res call({
 double scrollOffsetX, double scrollOffsetY, double viewportWidth, double viewportHeight, int firstVisibleRow, int lastVisibleRow, int firstVisibleColumn, int lastVisibleColumn
});




}
/// @nodoc
class _$ViewportStateCopyWithImpl<$Res>
    implements $ViewportStateCopyWith<$Res> {
  _$ViewportStateCopyWithImpl(this._self, this._then);

  final ViewportState _self;
  final $Res Function(ViewportState) _then;

/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scrollOffsetX = null,Object? scrollOffsetY = null,Object? viewportWidth = null,Object? viewportHeight = null,Object? firstVisibleRow = null,Object? lastVisibleRow = null,Object? firstVisibleColumn = null,Object? lastVisibleColumn = null,}) {
  return _then(_self.copyWith(
scrollOffsetX: null == scrollOffsetX ? _self.scrollOffsetX : scrollOffsetX // ignore: cast_nullable_to_non_nullable
as double,scrollOffsetY: null == scrollOffsetY ? _self.scrollOffsetY : scrollOffsetY // ignore: cast_nullable_to_non_nullable
as double,viewportWidth: null == viewportWidth ? _self.viewportWidth : viewportWidth // ignore: cast_nullable_to_non_nullable
as double,viewportHeight: null == viewportHeight ? _self.viewportHeight : viewportHeight // ignore: cast_nullable_to_non_nullable
as double,firstVisibleRow: null == firstVisibleRow ? _self.firstVisibleRow : firstVisibleRow // ignore: cast_nullable_to_non_nullable
as int,lastVisibleRow: null == lastVisibleRow ? _self.lastVisibleRow : lastVisibleRow // ignore: cast_nullable_to_non_nullable
as int,firstVisibleColumn: null == firstVisibleColumn ? _self.firstVisibleColumn : firstVisibleColumn // ignore: cast_nullable_to_non_nullable
as int,lastVisibleColumn: null == lastVisibleColumn ? _self.lastVisibleColumn : lastVisibleColumn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewportState].
extension ViewportStatePatterns on ViewportState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ViewportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ViewportState value)  $default,){
final _that = this;
switch (_that) {
case _ViewportState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ViewportState value)?  $default,){
final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double scrollOffsetX,  double scrollOffsetY,  double viewportWidth,  double viewportHeight,  int firstVisibleRow,  int lastVisibleRow,  int firstVisibleColumn,  int lastVisibleColumn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
return $default(_that.scrollOffsetX,_that.scrollOffsetY,_that.viewportWidth,_that.viewportHeight,_that.firstVisibleRow,_that.lastVisibleRow,_that.firstVisibleColumn,_that.lastVisibleColumn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double scrollOffsetX,  double scrollOffsetY,  double viewportWidth,  double viewportHeight,  int firstVisibleRow,  int lastVisibleRow,  int firstVisibleColumn,  int lastVisibleColumn)  $default,) {final _that = this;
switch (_that) {
case _ViewportState():
return $default(_that.scrollOffsetX,_that.scrollOffsetY,_that.viewportWidth,_that.viewportHeight,_that.firstVisibleRow,_that.lastVisibleRow,_that.firstVisibleColumn,_that.lastVisibleColumn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double scrollOffsetX,  double scrollOffsetY,  double viewportWidth,  double viewportHeight,  int firstVisibleRow,  int lastVisibleRow,  int firstVisibleColumn,  int lastVisibleColumn)?  $default,) {final _that = this;
switch (_that) {
case _ViewportState() when $default != null:
return $default(_that.scrollOffsetX,_that.scrollOffsetY,_that.viewportWidth,_that.viewportHeight,_that.firstVisibleRow,_that.lastVisibleRow,_that.firstVisibleColumn,_that.lastVisibleColumn);case _:
  return null;

}
}

}

/// @nodoc


class _ViewportState implements ViewportState {
  const _ViewportState({required this.scrollOffsetX, required this.scrollOffsetY, required this.viewportWidth, required this.viewportHeight, required this.firstVisibleRow, required this.lastVisibleRow, required this.firstVisibleColumn, required this.lastVisibleColumn});
  

@override final  double scrollOffsetX;
@override final  double scrollOffsetY;
@override final  double viewportWidth;
@override final  double viewportHeight;
@override final  int firstVisibleRow;
@override final  int lastVisibleRow;
@override final  int firstVisibleColumn;
@override final  int lastVisibleColumn;

/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewportStateCopyWith<_ViewportState> get copyWith => __$ViewportStateCopyWithImpl<_ViewportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewportState&&(identical(other.scrollOffsetX, scrollOffsetX) || other.scrollOffsetX == scrollOffsetX)&&(identical(other.scrollOffsetY, scrollOffsetY) || other.scrollOffsetY == scrollOffsetY)&&(identical(other.viewportWidth, viewportWidth) || other.viewportWidth == viewportWidth)&&(identical(other.viewportHeight, viewportHeight) || other.viewportHeight == viewportHeight)&&(identical(other.firstVisibleRow, firstVisibleRow) || other.firstVisibleRow == firstVisibleRow)&&(identical(other.lastVisibleRow, lastVisibleRow) || other.lastVisibleRow == lastVisibleRow)&&(identical(other.firstVisibleColumn, firstVisibleColumn) || other.firstVisibleColumn == firstVisibleColumn)&&(identical(other.lastVisibleColumn, lastVisibleColumn) || other.lastVisibleColumn == lastVisibleColumn));
}


@override
int get hashCode => Object.hash(runtimeType,scrollOffsetX,scrollOffsetY,viewportWidth,viewportHeight,firstVisibleRow,lastVisibleRow,firstVisibleColumn,lastVisibleColumn);

@override
String toString() {
  return 'ViewportState(scrollOffsetX: $scrollOffsetX, scrollOffsetY: $scrollOffsetY, viewportWidth: $viewportWidth, viewportHeight: $viewportHeight, firstVisibleRow: $firstVisibleRow, lastVisibleRow: $lastVisibleRow, firstVisibleColumn: $firstVisibleColumn, lastVisibleColumn: $lastVisibleColumn)';
}


}

/// @nodoc
abstract mixin class _$ViewportStateCopyWith<$Res> implements $ViewportStateCopyWith<$Res> {
  factory _$ViewportStateCopyWith(_ViewportState value, $Res Function(_ViewportState) _then) = __$ViewportStateCopyWithImpl;
@override @useResult
$Res call({
 double scrollOffsetX, double scrollOffsetY, double viewportWidth, double viewportHeight, int firstVisibleRow, int lastVisibleRow, int firstVisibleColumn, int lastVisibleColumn
});




}
/// @nodoc
class __$ViewportStateCopyWithImpl<$Res>
    implements _$ViewportStateCopyWith<$Res> {
  __$ViewportStateCopyWithImpl(this._self, this._then);

  final _ViewportState _self;
  final $Res Function(_ViewportState) _then;

/// Create a copy of ViewportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scrollOffsetX = null,Object? scrollOffsetY = null,Object? viewportWidth = null,Object? viewportHeight = null,Object? firstVisibleRow = null,Object? lastVisibleRow = null,Object? firstVisibleColumn = null,Object? lastVisibleColumn = null,}) {
  return _then(_ViewportState(
scrollOffsetX: null == scrollOffsetX ? _self.scrollOffsetX : scrollOffsetX // ignore: cast_nullable_to_non_nullable
as double,scrollOffsetY: null == scrollOffsetY ? _self.scrollOffsetY : scrollOffsetY // ignore: cast_nullable_to_non_nullable
as double,viewportWidth: null == viewportWidth ? _self.viewportWidth : viewportWidth // ignore: cast_nullable_to_non_nullable
as double,viewportHeight: null == viewportHeight ? _self.viewportHeight : viewportHeight // ignore: cast_nullable_to_non_nullable
as double,firstVisibleRow: null == firstVisibleRow ? _self.firstVisibleRow : firstVisibleRow // ignore: cast_nullable_to_non_nullable
as int,lastVisibleRow: null == lastVisibleRow ? _self.lastVisibleRow : lastVisibleRow // ignore: cast_nullable_to_non_nullable
as int,firstVisibleColumn: null == firstVisibleColumn ? _self.firstVisibleColumn : firstVisibleColumn // ignore: cast_nullable_to_non_nullable
as int,lastVisibleColumn: null == lastVisibleColumn ? _self.lastVisibleColumn : lastVisibleColumn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SelectionState {

 Set<double> get selectedRowIds; double? get focusedRowId; Set<String> get selectedCellIds; SelectionMode get mode;
/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectionStateCopyWith<SelectionState> get copyWith => _$SelectionStateCopyWithImpl<SelectionState>(this as SelectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectionState&&const DeepCollectionEquality().equals(other.selectedRowIds, selectedRowIds)&&(identical(other.focusedRowId, focusedRowId) || other.focusedRowId == focusedRowId)&&const DeepCollectionEquality().equals(other.selectedCellIds, selectedCellIds)&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedRowIds),focusedRowId,const DeepCollectionEquality().hash(selectedCellIds),mode);

@override
String toString() {
  return 'SelectionState(selectedRowIds: $selectedRowIds, focusedRowId: $focusedRowId, selectedCellIds: $selectedCellIds, mode: $mode)';
}


}

/// @nodoc
abstract mixin class $SelectionStateCopyWith<$Res>  {
  factory $SelectionStateCopyWith(SelectionState value, $Res Function(SelectionState) _then) = _$SelectionStateCopyWithImpl;
@useResult
$Res call({
 Set<double> selectedRowIds, double? focusedRowId, Set<String> selectedCellIds, SelectionMode mode
});




}
/// @nodoc
class _$SelectionStateCopyWithImpl<$Res>
    implements $SelectionStateCopyWith<$Res> {
  _$SelectionStateCopyWithImpl(this._self, this._then);

  final SelectionState _self;
  final $Res Function(SelectionState) _then;

/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedRowIds = null,Object? focusedRowId = freezed,Object? selectedCellIds = null,Object? mode = null,}) {
  return _then(_self.copyWith(
selectedRowIds: null == selectedRowIds ? _self.selectedRowIds : selectedRowIds // ignore: cast_nullable_to_non_nullable
as Set<double>,focusedRowId: freezed == focusedRowId ? _self.focusedRowId : focusedRowId // ignore: cast_nullable_to_non_nullable
as double?,selectedCellIds: null == selectedCellIds ? _self.selectedCellIds : selectedCellIds // ignore: cast_nullable_to_non_nullable
as Set<String>,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SelectionMode,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectionState].
extension SelectionStatePatterns on SelectionState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectionState value)  $default,){
final _that = this;
switch (_that) {
case _SelectionState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectionState value)?  $default,){
final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<double> selectedRowIds,  double? focusedRowId,  Set<String> selectedCellIds,  SelectionMode mode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
return $default(_that.selectedRowIds,_that.focusedRowId,_that.selectedCellIds,_that.mode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<double> selectedRowIds,  double? focusedRowId,  Set<String> selectedCellIds,  SelectionMode mode)  $default,) {final _that = this;
switch (_that) {
case _SelectionState():
return $default(_that.selectedRowIds,_that.focusedRowId,_that.selectedCellIds,_that.mode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<double> selectedRowIds,  double? focusedRowId,  Set<String> selectedCellIds,  SelectionMode mode)?  $default,) {final _that = this;
switch (_that) {
case _SelectionState() when $default != null:
return $default(_that.selectedRowIds,_that.focusedRowId,_that.selectedCellIds,_that.mode);case _:
  return null;

}
}

}

/// @nodoc


class _SelectionState extends SelectionState {
  const _SelectionState({required final  Set<double> selectedRowIds, this.focusedRowId, required final  Set<String> selectedCellIds, required this.mode}): _selectedRowIds = selectedRowIds,_selectedCellIds = selectedCellIds,super._();
  

 final  Set<double> _selectedRowIds;
@override Set<double> get selectedRowIds {
  if (_selectedRowIds is EqualUnmodifiableSetView) return _selectedRowIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedRowIds);
}

@override final  double? focusedRowId;
 final  Set<String> _selectedCellIds;
@override Set<String> get selectedCellIds {
  if (_selectedCellIds is EqualUnmodifiableSetView) return _selectedCellIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedCellIds);
}

@override final  SelectionMode mode;

/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectionStateCopyWith<_SelectionState> get copyWith => __$SelectionStateCopyWithImpl<_SelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectionState&&const DeepCollectionEquality().equals(other._selectedRowIds, _selectedRowIds)&&(identical(other.focusedRowId, focusedRowId) || other.focusedRowId == focusedRowId)&&const DeepCollectionEquality().equals(other._selectedCellIds, _selectedCellIds)&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedRowIds),focusedRowId,const DeepCollectionEquality().hash(_selectedCellIds),mode);

@override
String toString() {
  return 'SelectionState(selectedRowIds: $selectedRowIds, focusedRowId: $focusedRowId, selectedCellIds: $selectedCellIds, mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$SelectionStateCopyWith<$Res> implements $SelectionStateCopyWith<$Res> {
  factory _$SelectionStateCopyWith(_SelectionState value, $Res Function(_SelectionState) _then) = __$SelectionStateCopyWithImpl;
@override @useResult
$Res call({
 Set<double> selectedRowIds, double? focusedRowId, Set<String> selectedCellIds, SelectionMode mode
});




}
/// @nodoc
class __$SelectionStateCopyWithImpl<$Res>
    implements _$SelectionStateCopyWith<$Res> {
  __$SelectionStateCopyWithImpl(this._self, this._then);

  final _SelectionState _self;
  final $Res Function(_SelectionState) _then;

/// Create a copy of SelectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedRowIds = null,Object? focusedRowId = freezed,Object? selectedCellIds = null,Object? mode = null,}) {
  return _then(_SelectionState(
selectedRowIds: null == selectedRowIds ? _self._selectedRowIds : selectedRowIds // ignore: cast_nullable_to_non_nullable
as Set<double>,focusedRowId: freezed == focusedRowId ? _self.focusedRowId : focusedRowId // ignore: cast_nullable_to_non_nullable
as double?,selectedCellIds: null == selectedCellIds ? _self._selectedCellIds : selectedCellIds // ignore: cast_nullable_to_non_nullable
as Set<String>,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SelectionMode,
  ));
}


}

/// @nodoc
mixin _$SortState {

 SortColumn? get sortColumn;
/// Create a copy of SortState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SortStateCopyWith<SortState> get copyWith => _$SortStateCopyWithImpl<SortState>(this as SortState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SortState&&(identical(other.sortColumn, sortColumn) || other.sortColumn == sortColumn));
}


@override
int get hashCode => Object.hash(runtimeType,sortColumn);

@override
String toString() {
  return 'SortState(sortColumn: $sortColumn)';
}


}

/// @nodoc
abstract mixin class $SortStateCopyWith<$Res>  {
  factory $SortStateCopyWith(SortState value, $Res Function(SortState) _then) = _$SortStateCopyWithImpl;
@useResult
$Res call({
 SortColumn? sortColumn
});


$SortColumnCopyWith<$Res>? get sortColumn;

}
/// @nodoc
class _$SortStateCopyWithImpl<$Res>
    implements $SortStateCopyWith<$Res> {
  _$SortStateCopyWithImpl(this._self, this._then);

  final SortState _self;
  final $Res Function(SortState) _then;

/// Create a copy of SortState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sortColumn = freezed,}) {
  return _then(_self.copyWith(
sortColumn: freezed == sortColumn ? _self.sortColumn : sortColumn // ignore: cast_nullable_to_non_nullable
as SortColumn?,
  ));
}
/// Create a copy of SortState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SortColumnCopyWith<$Res>? get sortColumn {
    if (_self.sortColumn == null) {
    return null;
  }

  return $SortColumnCopyWith<$Res>(_self.sortColumn!, (value) {
    return _then(_self.copyWith(sortColumn: value));
  });
}
}


/// Adds pattern-matching-related methods to [SortState].
extension SortStatePatterns on SortState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SortState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SortState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SortState value)  $default,){
final _that = this;
switch (_that) {
case _SortState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SortState value)?  $default,){
final _that = this;
switch (_that) {
case _SortState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SortColumn? sortColumn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SortState() when $default != null:
return $default(_that.sortColumn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SortColumn? sortColumn)  $default,) {final _that = this;
switch (_that) {
case _SortState():
return $default(_that.sortColumn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SortColumn? sortColumn)?  $default,) {final _that = this;
switch (_that) {
case _SortState() when $default != null:
return $default(_that.sortColumn);case _:
  return null;

}
}

}

/// @nodoc


class _SortState extends SortState {
  const _SortState({this.sortColumn}): super._();
  

@override final  SortColumn? sortColumn;

/// Create a copy of SortState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SortStateCopyWith<_SortState> get copyWith => __$SortStateCopyWithImpl<_SortState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SortState&&(identical(other.sortColumn, sortColumn) || other.sortColumn == sortColumn));
}


@override
int get hashCode => Object.hash(runtimeType,sortColumn);

@override
String toString() {
  return 'SortState(sortColumn: $sortColumn)';
}


}

/// @nodoc
abstract mixin class _$SortStateCopyWith<$Res> implements $SortStateCopyWith<$Res> {
  factory _$SortStateCopyWith(_SortState value, $Res Function(_SortState) _then) = __$SortStateCopyWithImpl;
@override @useResult
$Res call({
 SortColumn? sortColumn
});


@override $SortColumnCopyWith<$Res>? get sortColumn;

}
/// @nodoc
class __$SortStateCopyWithImpl<$Res>
    implements _$SortStateCopyWith<$Res> {
  __$SortStateCopyWithImpl(this._self, this._then);

  final _SortState _self;
  final $Res Function(_SortState) _then;

/// Create a copy of SortState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sortColumn = freezed,}) {
  return _then(_SortState(
sortColumn: freezed == sortColumn ? _self.sortColumn : sortColumn // ignore: cast_nullable_to_non_nullable
as SortColumn?,
  ));
}

/// Create a copy of SortState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SortColumnCopyWith<$Res>? get sortColumn {
    if (_self.sortColumn == null) {
    return null;
  }

  return $SortColumnCopyWith<$Res>(_self.sortColumn!, (value) {
    return _then(_self.copyWith(sortColumn: value));
  });
}
}

/// @nodoc
mixin _$SortColumn {

 int get columnId; SortDirection get direction;
/// Create a copy of SortColumn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SortColumnCopyWith<SortColumn> get copyWith => _$SortColumnCopyWithImpl<SortColumn>(this as SortColumn, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SortColumn&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,columnId,direction);

@override
String toString() {
  return 'SortColumn(columnId: $columnId, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $SortColumnCopyWith<$Res>  {
  factory $SortColumnCopyWith(SortColumn value, $Res Function(SortColumn) _then) = _$SortColumnCopyWithImpl;
@useResult
$Res call({
 int columnId, SortDirection direction
});




}
/// @nodoc
class _$SortColumnCopyWithImpl<$Res>
    implements $SortColumnCopyWith<$Res> {
  _$SortColumnCopyWithImpl(this._self, this._then);

  final SortColumn _self;
  final $Res Function(SortColumn) _then;

/// Create a copy of SortColumn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columnId = null,Object? direction = null,}) {
  return _then(_self.copyWith(
columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as SortDirection,
  ));
}

}


/// Adds pattern-matching-related methods to [SortColumn].
extension SortColumnPatterns on SortColumn {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SortColumn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SortColumn() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SortColumn value)  $default,){
final _that = this;
switch (_that) {
case _SortColumn():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SortColumn value)?  $default,){
final _that = this;
switch (_that) {
case _SortColumn() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int columnId,  SortDirection direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SortColumn() when $default != null:
return $default(_that.columnId,_that.direction);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int columnId,  SortDirection direction)  $default,) {final _that = this;
switch (_that) {
case _SortColumn():
return $default(_that.columnId,_that.direction);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int columnId,  SortDirection direction)?  $default,) {final _that = this;
switch (_that) {
case _SortColumn() when $default != null:
return $default(_that.columnId,_that.direction);case _:
  return null;

}
}

}

/// @nodoc


class _SortColumn implements SortColumn {
  const _SortColumn({required this.columnId, required this.direction});
  

@override final  int columnId;
@override final  SortDirection direction;

/// Create a copy of SortColumn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SortColumnCopyWith<_SortColumn> get copyWith => __$SortColumnCopyWithImpl<_SortColumn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SortColumn&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,columnId,direction);

@override
String toString() {
  return 'SortColumn(columnId: $columnId, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$SortColumnCopyWith<$Res> implements $SortColumnCopyWith<$Res> {
  factory _$SortColumnCopyWith(_SortColumn value, $Res Function(_SortColumn) _then) = __$SortColumnCopyWithImpl;
@override @useResult
$Res call({
 int columnId, SortDirection direction
});




}
/// @nodoc
class __$SortColumnCopyWithImpl<$Res>
    implements _$SortColumnCopyWith<$Res> {
  __$SortColumnCopyWithImpl(this._self, this._then);

  final _SortColumn _self;
  final $Res Function(_SortColumn) _then;

/// Create a copy of SortColumn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columnId = null,Object? direction = null,}) {
  return _then(_SortColumn(
columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as SortDirection,
  ));
}


}

/// @nodoc
mixin _$FilterState {

 Map<int, ColumnFilter> get columnFilters;
/// Create a copy of FilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterStateCopyWith<FilterState> get copyWith => _$FilterStateCopyWithImpl<FilterState>(this as FilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterState&&const DeepCollectionEquality().equals(other.columnFilters, columnFilters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(columnFilters));

@override
String toString() {
  return 'FilterState(columnFilters: $columnFilters)';
}


}

/// @nodoc
abstract mixin class $FilterStateCopyWith<$Res>  {
  factory $FilterStateCopyWith(FilterState value, $Res Function(FilterState) _then) = _$FilterStateCopyWithImpl;
@useResult
$Res call({
 Map<int, ColumnFilter> columnFilters
});




}
/// @nodoc
class _$FilterStateCopyWithImpl<$Res>
    implements $FilterStateCopyWith<$Res> {
  _$FilterStateCopyWithImpl(this._self, this._then);

  final FilterState _self;
  final $Res Function(FilterState) _then;

/// Create a copy of FilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columnFilters = null,}) {
  return _then(_self.copyWith(
columnFilters: null == columnFilters ? _self.columnFilters : columnFilters // ignore: cast_nullable_to_non_nullable
as Map<int, ColumnFilter>,
  ));
}

}


/// Adds pattern-matching-related methods to [FilterState].
extension FilterStatePatterns on FilterState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilterState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilterState value)  $default,){
final _that = this;
switch (_that) {
case _FilterState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilterState value)?  $default,){
final _that = this;
switch (_that) {
case _FilterState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<int, ColumnFilter> columnFilters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilterState() when $default != null:
return $default(_that.columnFilters);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<int, ColumnFilter> columnFilters)  $default,) {final _that = this;
switch (_that) {
case _FilterState():
return $default(_that.columnFilters);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<int, ColumnFilter> columnFilters)?  $default,) {final _that = this;
switch (_that) {
case _FilterState() when $default != null:
return $default(_that.columnFilters);case _:
  return null;

}
}

}

/// @nodoc


class _FilterState extends FilterState {
  const _FilterState({required final  Map<int, ColumnFilter> columnFilters}): _columnFilters = columnFilters,super._();
  

 final  Map<int, ColumnFilter> _columnFilters;
@override Map<int, ColumnFilter> get columnFilters {
  if (_columnFilters is EqualUnmodifiableMapView) return _columnFilters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_columnFilters);
}


/// Create a copy of FilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterStateCopyWith<_FilterState> get copyWith => __$FilterStateCopyWithImpl<_FilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterState&&const DeepCollectionEquality().equals(other._columnFilters, _columnFilters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_columnFilters));

@override
String toString() {
  return 'FilterState(columnFilters: $columnFilters)';
}


}

/// @nodoc
abstract mixin class _$FilterStateCopyWith<$Res> implements $FilterStateCopyWith<$Res> {
  factory _$FilterStateCopyWith(_FilterState value, $Res Function(_FilterState) _then) = __$FilterStateCopyWithImpl;
@override @useResult
$Res call({
 Map<int, ColumnFilter> columnFilters
});




}
/// @nodoc
class __$FilterStateCopyWithImpl<$Res>
    implements _$FilterStateCopyWith<$Res> {
  __$FilterStateCopyWithImpl(this._self, this._then);

  final _FilterState _self;
  final $Res Function(_FilterState) _then;

/// Create a copy of FilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columnFilters = null,}) {
  return _then(_FilterState(
columnFilters: null == columnFilters ? _self._columnFilters : columnFilters // ignore: cast_nullable_to_non_nullable
as Map<int, ColumnFilter>,
  ));
}


}

/// @nodoc
mixin _$ColumnFilter {

 int get columnId; FilterOperator get operator; dynamic get value;
/// Create a copy of ColumnFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColumnFilterCopyWith<ColumnFilter> get copyWith => _$ColumnFilterCopyWithImpl<ColumnFilter>(this as ColumnFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColumnFilter&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.operator, operator) || other.operator == operator)&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,columnId,operator,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'ColumnFilter(columnId: $columnId, operator: $operator, value: $value)';
}


}

/// @nodoc
abstract mixin class $ColumnFilterCopyWith<$Res>  {
  factory $ColumnFilterCopyWith(ColumnFilter value, $Res Function(ColumnFilter) _then) = _$ColumnFilterCopyWithImpl;
@useResult
$Res call({
 int columnId, FilterOperator operator, dynamic value
});




}
/// @nodoc
class _$ColumnFilterCopyWithImpl<$Res>
    implements $ColumnFilterCopyWith<$Res> {
  _$ColumnFilterCopyWithImpl(this._self, this._then);

  final ColumnFilter _self;
  final $Res Function(ColumnFilter) _then;

/// Create a copy of ColumnFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columnId = null,Object? operator = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as int,operator: null == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as FilterOperator,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [ColumnFilter].
extension ColumnFilterPatterns on ColumnFilter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColumnFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColumnFilter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColumnFilter value)  $default,){
final _that = this;
switch (_that) {
case _ColumnFilter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColumnFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ColumnFilter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int columnId,  FilterOperator operator,  dynamic value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColumnFilter() when $default != null:
return $default(_that.columnId,_that.operator,_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int columnId,  FilterOperator operator,  dynamic value)  $default,) {final _that = this;
switch (_that) {
case _ColumnFilter():
return $default(_that.columnId,_that.operator,_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int columnId,  FilterOperator operator,  dynamic value)?  $default,) {final _that = this;
switch (_that) {
case _ColumnFilter() when $default != null:
return $default(_that.columnId,_that.operator,_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _ColumnFilter implements ColumnFilter {
  const _ColumnFilter({required this.columnId, required this.operator, required this.value});
  

@override final  int columnId;
@override final  FilterOperator operator;
@override final  dynamic value;

/// Create a copy of ColumnFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColumnFilterCopyWith<_ColumnFilter> get copyWith => __$ColumnFilterCopyWithImpl<_ColumnFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColumnFilter&&(identical(other.columnId, columnId) || other.columnId == columnId)&&(identical(other.operator, operator) || other.operator == operator)&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,columnId,operator,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'ColumnFilter(columnId: $columnId, operator: $operator, value: $value)';
}


}

/// @nodoc
abstract mixin class _$ColumnFilterCopyWith<$Res> implements $ColumnFilterCopyWith<$Res> {
  factory _$ColumnFilterCopyWith(_ColumnFilter value, $Res Function(_ColumnFilter) _then) = __$ColumnFilterCopyWithImpl;
@override @useResult
$Res call({
 int columnId, FilterOperator operator, dynamic value
});




}
/// @nodoc
class __$ColumnFilterCopyWithImpl<$Res>
    implements _$ColumnFilterCopyWith<$Res> {
  __$ColumnFilterCopyWithImpl(this._self, this._then);

  final _ColumnFilter _self;
  final $Res Function(_ColumnFilter) _then;

/// Create a copy of ColumnFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columnId = null,Object? operator = null,Object? value = freezed,}) {
  return _then(_ColumnFilter(
columnId: null == columnId ? _self.columnId : columnId // ignore: cast_nullable_to_non_nullable
as int,operator: null == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as FilterOperator,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc
mixin _$GroupState {

 List<int> get groupedColumnIds; Map<String, bool> get expandedGroups;
/// Create a copy of GroupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupStateCopyWith<GroupState> get copyWith => _$GroupStateCopyWithImpl<GroupState>(this as GroupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupState&&const DeepCollectionEquality().equals(other.groupedColumnIds, groupedColumnIds)&&const DeepCollectionEquality().equals(other.expandedGroups, expandedGroups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groupedColumnIds),const DeepCollectionEquality().hash(expandedGroups));

@override
String toString() {
  return 'GroupState(groupedColumnIds: $groupedColumnIds, expandedGroups: $expandedGroups)';
}


}

/// @nodoc
abstract mixin class $GroupStateCopyWith<$Res>  {
  factory $GroupStateCopyWith(GroupState value, $Res Function(GroupState) _then) = _$GroupStateCopyWithImpl;
@useResult
$Res call({
 List<int> groupedColumnIds, Map<String, bool> expandedGroups
});




}
/// @nodoc
class _$GroupStateCopyWithImpl<$Res>
    implements $GroupStateCopyWith<$Res> {
  _$GroupStateCopyWithImpl(this._self, this._then);

  final GroupState _self;
  final $Res Function(GroupState) _then;

/// Create a copy of GroupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupedColumnIds = null,Object? expandedGroups = null,}) {
  return _then(_self.copyWith(
groupedColumnIds: null == groupedColumnIds ? _self.groupedColumnIds : groupedColumnIds // ignore: cast_nullable_to_non_nullable
as List<int>,expandedGroups: null == expandedGroups ? _self.expandedGroups : expandedGroups // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupState].
extension GroupStatePatterns on GroupState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupState value)  $default,){
final _that = this;
switch (_that) {
case _GroupState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupState value)?  $default,){
final _that = this;
switch (_that) {
case _GroupState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> groupedColumnIds,  Map<String, bool> expandedGroups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupState() when $default != null:
return $default(_that.groupedColumnIds,_that.expandedGroups);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> groupedColumnIds,  Map<String, bool> expandedGroups)  $default,) {final _that = this;
switch (_that) {
case _GroupState():
return $default(_that.groupedColumnIds,_that.expandedGroups);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> groupedColumnIds,  Map<String, bool> expandedGroups)?  $default,) {final _that = this;
switch (_that) {
case _GroupState() when $default != null:
return $default(_that.groupedColumnIds,_that.expandedGroups);case _:
  return null;

}
}

}

/// @nodoc


class _GroupState extends GroupState {
  const _GroupState({required final  List<int> groupedColumnIds, required final  Map<String, bool> expandedGroups}): _groupedColumnIds = groupedColumnIds,_expandedGroups = expandedGroups,super._();
  

 final  List<int> _groupedColumnIds;
@override List<int> get groupedColumnIds {
  if (_groupedColumnIds is EqualUnmodifiableListView) return _groupedColumnIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupedColumnIds);
}

 final  Map<String, bool> _expandedGroups;
@override Map<String, bool> get expandedGroups {
  if (_expandedGroups is EqualUnmodifiableMapView) return _expandedGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_expandedGroups);
}


/// Create a copy of GroupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupStateCopyWith<_GroupState> get copyWith => __$GroupStateCopyWithImpl<_GroupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupState&&const DeepCollectionEquality().equals(other._groupedColumnIds, _groupedColumnIds)&&const DeepCollectionEquality().equals(other._expandedGroups, _expandedGroups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groupedColumnIds),const DeepCollectionEquality().hash(_expandedGroups));

@override
String toString() {
  return 'GroupState(groupedColumnIds: $groupedColumnIds, expandedGroups: $expandedGroups)';
}


}

/// @nodoc
abstract mixin class _$GroupStateCopyWith<$Res> implements $GroupStateCopyWith<$Res> {
  factory _$GroupStateCopyWith(_GroupState value, $Res Function(_GroupState) _then) = __$GroupStateCopyWithImpl;
@override @useResult
$Res call({
 List<int> groupedColumnIds, Map<String, bool> expandedGroups
});




}
/// @nodoc
class __$GroupStateCopyWithImpl<$Res>
    implements _$GroupStateCopyWith<$Res> {
  __$GroupStateCopyWithImpl(this._self, this._then);

  final _GroupState _self;
  final $Res Function(_GroupState) _then;

/// Create a copy of GroupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupedColumnIds = null,Object? expandedGroups = null,}) {
  return _then(_GroupState(
groupedColumnIds: null == groupedColumnIds ? _self._groupedColumnIds : groupedColumnIds // ignore: cast_nullable_to_non_nullable
as List<int>,expandedGroups: null == expandedGroups ? _self._expandedGroups : expandedGroups // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}


}

/// @nodoc
mixin _$EditState {

 String? get editingCellId; dynamic get editingValue;
/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditStateCopyWith<EditState> get copyWith => _$EditStateCopyWithImpl<EditState>(this as EditState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditState&&(identical(other.editingCellId, editingCellId) || other.editingCellId == editingCellId)&&const DeepCollectionEquality().equals(other.editingValue, editingValue));
}


@override
int get hashCode => Object.hash(runtimeType,editingCellId,const DeepCollectionEquality().hash(editingValue));

@override
String toString() {
  return 'EditState(editingCellId: $editingCellId, editingValue: $editingValue)';
}


}

/// @nodoc
abstract mixin class $EditStateCopyWith<$Res>  {
  factory $EditStateCopyWith(EditState value, $Res Function(EditState) _then) = _$EditStateCopyWithImpl;
@useResult
$Res call({
 String? editingCellId, dynamic editingValue
});




}
/// @nodoc
class _$EditStateCopyWithImpl<$Res>
    implements $EditStateCopyWith<$Res> {
  _$EditStateCopyWithImpl(this._self, this._then);

  final EditState _self;
  final $Res Function(EditState) _then;

/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? editingCellId = freezed,Object? editingValue = freezed,}) {
  return _then(_self.copyWith(
editingCellId: freezed == editingCellId ? _self.editingCellId : editingCellId // ignore: cast_nullable_to_non_nullable
as String?,editingValue: freezed == editingValue ? _self.editingValue : editingValue // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [EditState].
extension EditStatePatterns on EditState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditState value)  $default,){
final _that = this;
switch (_that) {
case _EditState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditState value)?  $default,){
final _that = this;
switch (_that) {
case _EditState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? editingCellId,  dynamic editingValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditState() when $default != null:
return $default(_that.editingCellId,_that.editingValue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? editingCellId,  dynamic editingValue)  $default,) {final _that = this;
switch (_that) {
case _EditState():
return $default(_that.editingCellId,_that.editingValue);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? editingCellId,  dynamic editingValue)?  $default,) {final _that = this;
switch (_that) {
case _EditState() when $default != null:
return $default(_that.editingCellId,_that.editingValue);case _:
  return null;

}
}

}

/// @nodoc


class _EditState extends EditState {
  const _EditState({this.editingCellId, this.editingValue}): super._();
  

@override final  String? editingCellId;
@override final  dynamic editingValue;

/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditStateCopyWith<_EditState> get copyWith => __$EditStateCopyWithImpl<_EditState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditState&&(identical(other.editingCellId, editingCellId) || other.editingCellId == editingCellId)&&const DeepCollectionEquality().equals(other.editingValue, editingValue));
}


@override
int get hashCode => Object.hash(runtimeType,editingCellId,const DeepCollectionEquality().hash(editingValue));

@override
String toString() {
  return 'EditState(editingCellId: $editingCellId, editingValue: $editingValue)';
}


}

/// @nodoc
abstract mixin class _$EditStateCopyWith<$Res> implements $EditStateCopyWith<$Res> {
  factory _$EditStateCopyWith(_EditState value, $Res Function(_EditState) _then) = __$EditStateCopyWithImpl;
@override @useResult
$Res call({
 String? editingCellId, dynamic editingValue
});




}
/// @nodoc
class __$EditStateCopyWithImpl<$Res>
    implements _$EditStateCopyWith<$Res> {
  __$EditStateCopyWithImpl(this._self, this._then);

  final _EditState _self;
  final $Res Function(_EditState) _then;

/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? editingCellId = freezed,Object? editingValue = freezed,}) {
  return _then(_EditState(
editingCellId: freezed == editingCellId ? _self.editingCellId : editingCellId // ignore: cast_nullable_to_non_nullable
as String?,editingValue: freezed == editingValue ? _self.editingValue : editingValue // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
