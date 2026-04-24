// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettlementDraft {

 String get fromUserId; String get fromUserName; String get toUserId; String get toUserName; String get toPixKey; Decimal get amount;
/// Create a copy of SettlementDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettlementDraftCopyWith<SettlementDraft> get copyWith => _$SettlementDraftCopyWithImpl<SettlementDraft>(this as SettlementDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettlementDraft&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.fromUserName, fromUserName) || other.fromUserName == fromUserName)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.toUserName, toUserName) || other.toUserName == toUserName)&&(identical(other.toPixKey, toPixKey) || other.toPixKey == toPixKey)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,fromUserId,fromUserName,toUserId,toUserName,toPixKey,amount);

@override
String toString() {
  return 'SettlementDraft(fromUserId: $fromUserId, fromUserName: $fromUserName, toUserId: $toUserId, toUserName: $toUserName, toPixKey: $toPixKey, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $SettlementDraftCopyWith<$Res>  {
  factory $SettlementDraftCopyWith(SettlementDraft value, $Res Function(SettlementDraft) _then) = _$SettlementDraftCopyWithImpl;
@useResult
$Res call({
 String fromUserId, String fromUserName, String toUserId, String toUserName, String toPixKey, Decimal amount
});




}
/// @nodoc
class _$SettlementDraftCopyWithImpl<$Res>
    implements $SettlementDraftCopyWith<$Res> {
  _$SettlementDraftCopyWithImpl(this._self, this._then);

  final SettlementDraft _self;
  final $Res Function(SettlementDraft) _then;

/// Create a copy of SettlementDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromUserId = null,Object? fromUserName = null,Object? toUserId = null,Object? toUserName = null,Object? toPixKey = null,Object? amount = null,}) {
  return _then(_self.copyWith(
fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,fromUserName: null == fromUserName ? _self.fromUserName : fromUserName // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,toUserName: null == toUserName ? _self.toUserName : toUserName // ignore: cast_nullable_to_non_nullable
as String,toPixKey: null == toPixKey ? _self.toPixKey : toPixKey // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [SettlementDraft].
extension SettlementDraftPatterns on SettlementDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettlementDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettlementDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettlementDraft value)  $default,){
final _that = this;
switch (_that) {
case _SettlementDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettlementDraft value)?  $default,){
final _that = this;
switch (_that) {
case _SettlementDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromUserId,  String fromUserName,  String toUserId,  String toUserName,  String toPixKey,  Decimal amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettlementDraft() when $default != null:
return $default(_that.fromUserId,_that.fromUserName,_that.toUserId,_that.toUserName,_that.toPixKey,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromUserId,  String fromUserName,  String toUserId,  String toUserName,  String toPixKey,  Decimal amount)  $default,) {final _that = this;
switch (_that) {
case _SettlementDraft():
return $default(_that.fromUserId,_that.fromUserName,_that.toUserId,_that.toUserName,_that.toPixKey,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromUserId,  String fromUserName,  String toUserId,  String toUserName,  String toPixKey,  Decimal amount)?  $default,) {final _that = this;
switch (_that) {
case _SettlementDraft() when $default != null:
return $default(_that.fromUserId,_that.fromUserName,_that.toUserId,_that.toUserName,_that.toPixKey,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _SettlementDraft implements SettlementDraft {
  const _SettlementDraft({required this.fromUserId, required this.fromUserName, required this.toUserId, required this.toUserName, required this.toPixKey, required this.amount});
  

@override final  String fromUserId;
@override final  String fromUserName;
@override final  String toUserId;
@override final  String toUserName;
@override final  String toPixKey;
@override final  Decimal amount;

/// Create a copy of SettlementDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettlementDraftCopyWith<_SettlementDraft> get copyWith => __$SettlementDraftCopyWithImpl<_SettlementDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettlementDraft&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.fromUserName, fromUserName) || other.fromUserName == fromUserName)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.toUserName, toUserName) || other.toUserName == toUserName)&&(identical(other.toPixKey, toPixKey) || other.toPixKey == toPixKey)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,fromUserId,fromUserName,toUserId,toUserName,toPixKey,amount);

@override
String toString() {
  return 'SettlementDraft(fromUserId: $fromUserId, fromUserName: $fromUserName, toUserId: $toUserId, toUserName: $toUserName, toPixKey: $toPixKey, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$SettlementDraftCopyWith<$Res> implements $SettlementDraftCopyWith<$Res> {
  factory _$SettlementDraftCopyWith(_SettlementDraft value, $Res Function(_SettlementDraft) _then) = __$SettlementDraftCopyWithImpl;
@override @useResult
$Res call({
 String fromUserId, String fromUserName, String toUserId, String toUserName, String toPixKey, Decimal amount
});




}
/// @nodoc
class __$SettlementDraftCopyWithImpl<$Res>
    implements _$SettlementDraftCopyWith<$Res> {
  __$SettlementDraftCopyWithImpl(this._self, this._then);

  final _SettlementDraft _self;
  final $Res Function(_SettlementDraft) _then;

/// Create a copy of SettlementDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromUserId = null,Object? fromUserName = null,Object? toUserId = null,Object? toUserName = null,Object? toPixKey = null,Object? amount = null,}) {
  return _then(_SettlementDraft(
fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,fromUserName: null == fromUserName ? _self.fromUserName : fromUserName // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,toUserName: null == toUserName ? _self.toUserName : toUserName // ignore: cast_nullable_to_non_nullable
as String,toPixKey: null == toPixKey ? _self.toPixKey : toPixKey // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
