// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_out.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CashOut {

 String get id; String get participationId; Decimal get amount; DateTime get createdAt;
/// Create a copy of CashOut
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashOutCopyWith<CashOut> get copyWith => _$CashOutCopyWithImpl<CashOut>(this as CashOut, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashOut&&(identical(other.id, id) || other.id == id)&&(identical(other.participationId, participationId) || other.participationId == participationId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,participationId,amount,createdAt);

@override
String toString() {
  return 'CashOut(id: $id, participationId: $participationId, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CashOutCopyWith<$Res>  {
  factory $CashOutCopyWith(CashOut value, $Res Function(CashOut) _then) = _$CashOutCopyWithImpl;
@useResult
$Res call({
 String id, String participationId, Decimal amount, DateTime createdAt
});




}
/// @nodoc
class _$CashOutCopyWithImpl<$Res>
    implements $CashOutCopyWith<$Res> {
  _$CashOutCopyWithImpl(this._self, this._then);

  final CashOut _self;
  final $Res Function(CashOut) _then;

/// Create a copy of CashOut
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? participationId = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,participationId: null == participationId ? _self.participationId : participationId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CashOut].
extension CashOutPatterns on CashOut {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashOut value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashOut() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashOut value)  $default,){
final _that = this;
switch (_that) {
case _CashOut():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashOut value)?  $default,){
final _that = this;
switch (_that) {
case _CashOut() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String participationId,  Decimal amount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashOut() when $default != null:
return $default(_that.id,_that.participationId,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String participationId,  Decimal amount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CashOut():
return $default(_that.id,_that.participationId,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String participationId,  Decimal amount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CashOut() when $default != null:
return $default(_that.id,_that.participationId,_that.amount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _CashOut implements CashOut {
  const _CashOut({required this.id, required this.participationId, required this.amount, required this.createdAt});
  

@override final  String id;
@override final  String participationId;
@override final  Decimal amount;
@override final  DateTime createdAt;

/// Create a copy of CashOut
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashOutCopyWith<_CashOut> get copyWith => __$CashOutCopyWithImpl<_CashOut>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashOut&&(identical(other.id, id) || other.id == id)&&(identical(other.participationId, participationId) || other.participationId == participationId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,participationId,amount,createdAt);

@override
String toString() {
  return 'CashOut(id: $id, participationId: $participationId, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CashOutCopyWith<$Res> implements $CashOutCopyWith<$Res> {
  factory _$CashOutCopyWith(_CashOut value, $Res Function(_CashOut) _then) = __$CashOutCopyWithImpl;
@override @useResult
$Res call({
 String id, String participationId, Decimal amount, DateTime createdAt
});




}
/// @nodoc
class __$CashOutCopyWithImpl<$Res>
    implements _$CashOutCopyWith<$Res> {
  __$CashOutCopyWithImpl(this._self, this._then);

  final _CashOut _self;
  final $Res Function(_CashOut) _then;

/// Create a copy of CashOut
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? participationId = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_CashOut(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,participationId: null == participationId ? _self.participationId : participationId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
