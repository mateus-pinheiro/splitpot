// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_table_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateTableState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTableState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateTableState()';
}


}

/// @nodoc
class $CreateTableStateCopyWith<$Res>  {
$CreateTableStateCopyWith(CreateTableState _, $Res Function(CreateTableState) __);
}


/// Adds pattern-matching-related methods to [CreateTableState].
extension CreateTableStatePatterns on CreateTableState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreateTableIdle value)?  idle,TResult Function( CreateTableCreating value)?  creating,TResult Function( CreateTableCreated value)?  created,TResult Function( CreateTableError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreateTableIdle() when idle != null:
return idle(_that);case CreateTableCreating() when creating != null:
return creating(_that);case CreateTableCreated() when created != null:
return created(_that);case CreateTableError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreateTableIdle value)  idle,required TResult Function( CreateTableCreating value)  creating,required TResult Function( CreateTableCreated value)  created,required TResult Function( CreateTableError value)  error,}){
final _that = this;
switch (_that) {
case CreateTableIdle():
return idle(_that);case CreateTableCreating():
return creating(_that);case CreateTableCreated():
return created(_that);case CreateTableError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreateTableIdle value)?  idle,TResult? Function( CreateTableCreating value)?  creating,TResult? Function( CreateTableCreated value)?  created,TResult? Function( CreateTableError value)?  error,}){
final _that = this;
switch (_that) {
case CreateTableIdle() when idle != null:
return idle(_that);case CreateTableCreating() when creating != null:
return creating(_that);case CreateTableCreated() when created != null:
return created(_that);case CreateTableError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  creating,TResult Function( String tableId)?  created,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreateTableIdle() when idle != null:
return idle();case CreateTableCreating() when creating != null:
return creating();case CreateTableCreated() when created != null:
return created(_that.tableId);case CreateTableError() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  creating,required TResult Function( String tableId)  created,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case CreateTableIdle():
return idle();case CreateTableCreating():
return creating();case CreateTableCreated():
return created(_that.tableId);case CreateTableError():
return error(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  creating,TResult? Function( String tableId)?  created,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case CreateTableIdle() when idle != null:
return idle();case CreateTableCreating() when creating != null:
return creating();case CreateTableCreated() when created != null:
return created(_that.tableId);case CreateTableError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class CreateTableIdle implements CreateTableState {
  const CreateTableIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTableIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateTableState.idle()';
}


}




/// @nodoc


class CreateTableCreating implements CreateTableState {
  const CreateTableCreating();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTableCreating);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreateTableState.creating()';
}


}




/// @nodoc


class CreateTableCreated implements CreateTableState {
  const CreateTableCreated(this.tableId);
  

 final  String tableId;

/// Create a copy of CreateTableState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTableCreatedCopyWith<CreateTableCreated> get copyWith => _$CreateTableCreatedCopyWithImpl<CreateTableCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTableCreated&&(identical(other.tableId, tableId) || other.tableId == tableId));
}


@override
int get hashCode => Object.hash(runtimeType,tableId);

@override
String toString() {
  return 'CreateTableState.created(tableId: $tableId)';
}


}

/// @nodoc
abstract mixin class $CreateTableCreatedCopyWith<$Res> implements $CreateTableStateCopyWith<$Res> {
  factory $CreateTableCreatedCopyWith(CreateTableCreated value, $Res Function(CreateTableCreated) _then) = _$CreateTableCreatedCopyWithImpl;
@useResult
$Res call({
 String tableId
});




}
/// @nodoc
class _$CreateTableCreatedCopyWithImpl<$Res>
    implements $CreateTableCreatedCopyWith<$Res> {
  _$CreateTableCreatedCopyWithImpl(this._self, this._then);

  final CreateTableCreated _self;
  final $Res Function(CreateTableCreated) _then;

/// Create a copy of CreateTableState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tableId = null,}) {
  return _then(CreateTableCreated(
null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CreateTableError implements CreateTableState {
  const CreateTableError(this.failure);
  

 final  Failure failure;

/// Create a copy of CreateTableState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTableErrorCopyWith<CreateTableError> get copyWith => _$CreateTableErrorCopyWithImpl<CreateTableError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTableError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'CreateTableState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $CreateTableErrorCopyWith<$Res> implements $CreateTableStateCopyWith<$Res> {
  factory $CreateTableErrorCopyWith(CreateTableError value, $Res Function(CreateTableError) _then) = _$CreateTableErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});


$FailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$CreateTableErrorCopyWithImpl<$Res>
    implements $CreateTableErrorCopyWith<$Res> {
  _$CreateTableErrorCopyWithImpl(this._self, this._then);

  final CreateTableError _self;
  final $Res Function(CreateTableError) _then;

/// Create a copy of CreateTableState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(CreateTableError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}

/// Create a copy of CreateTableState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res> get failure {
  
  return $FailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
