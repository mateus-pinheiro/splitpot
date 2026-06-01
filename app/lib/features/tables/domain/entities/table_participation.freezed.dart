// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'table_participation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TableParticipation {

 String get id; String get tableId; String? get userId; String get userName; String? get guestName; String? get guestPixKey; DateTime get joinedAt; DateTime? get leftAt; List<BuyIn> get buyIns; CashOut? get cashOut;
/// Create a copy of TableParticipation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableParticipationCopyWith<TableParticipation> get copyWith => _$TableParticipationCopyWithImpl<TableParticipation>(this as TableParticipation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableParticipation&&(identical(other.id, id) || other.id == id)&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestPixKey, guestPixKey) || other.guestPixKey == guestPixKey)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&const DeepCollectionEquality().equals(other.buyIns, buyIns)&&(identical(other.cashOut, cashOut) || other.cashOut == cashOut));
}


@override
int get hashCode => Object.hash(runtimeType,id,tableId,userId,userName,guestName,guestPixKey,joinedAt,leftAt,const DeepCollectionEquality().hash(buyIns),cashOut);

@override
String toString() {
  return 'TableParticipation(id: $id, tableId: $tableId, userId: $userId, userName: $userName, guestName: $guestName, guestPixKey: $guestPixKey, joinedAt: $joinedAt, leftAt: $leftAt, buyIns: $buyIns, cashOut: $cashOut)';
}


}

/// @nodoc
abstract mixin class $TableParticipationCopyWith<$Res>  {
  factory $TableParticipationCopyWith(TableParticipation value, $Res Function(TableParticipation) _then) = _$TableParticipationCopyWithImpl;
@useResult
$Res call({
 String id, String tableId, String? userId, String userName, String? guestName, String? guestPixKey, DateTime joinedAt, DateTime? leftAt, List<BuyIn> buyIns, CashOut? cashOut
});


$CashOutCopyWith<$Res>? get cashOut;

}
/// @nodoc
class _$TableParticipationCopyWithImpl<$Res>
    implements $TableParticipationCopyWith<$Res> {
  _$TableParticipationCopyWithImpl(this._self, this._then);

  final TableParticipation _self;
  final $Res Function(TableParticipation) _then;

/// Create a copy of TableParticipation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tableId = null,Object? userId = freezed,Object? userName = null,Object? guestName = freezed,Object? guestPixKey = freezed,Object? joinedAt = null,Object? leftAt = freezed,Object? buyIns = null,Object? cashOut = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestPixKey: freezed == guestPixKey ? _self.guestPixKey : guestPixKey // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buyIns: null == buyIns ? _self.buyIns : buyIns // ignore: cast_nullable_to_non_nullable
as List<BuyIn>,cashOut: freezed == cashOut ? _self.cashOut : cashOut // ignore: cast_nullable_to_non_nullable
as CashOut?,
  ));
}
/// Create a copy of TableParticipation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CashOutCopyWith<$Res>? get cashOut {
    if (_self.cashOut == null) {
    return null;
  }

  return $CashOutCopyWith<$Res>(_self.cashOut!, (value) {
    return _then(_self.copyWith(cashOut: value));
  });
}
}


/// Adds pattern-matching-related methods to [TableParticipation].
extension TableParticipationPatterns on TableParticipation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableParticipation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableParticipation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableParticipation value)  $default,){
final _that = this;
switch (_that) {
case _TableParticipation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableParticipation value)?  $default,){
final _that = this;
switch (_that) {
case _TableParticipation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tableId,  String? userId,  String userName,  String? guestName,  String? guestPixKey,  DateTime joinedAt,  DateTime? leftAt,  List<BuyIn> buyIns,  CashOut? cashOut)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableParticipation() when $default != null:
return $default(_that.id,_that.tableId,_that.userId,_that.userName,_that.guestName,_that.guestPixKey,_that.joinedAt,_that.leftAt,_that.buyIns,_that.cashOut);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tableId,  String? userId,  String userName,  String? guestName,  String? guestPixKey,  DateTime joinedAt,  DateTime? leftAt,  List<BuyIn> buyIns,  CashOut? cashOut)  $default,) {final _that = this;
switch (_that) {
case _TableParticipation():
return $default(_that.id,_that.tableId,_that.userId,_that.userName,_that.guestName,_that.guestPixKey,_that.joinedAt,_that.leftAt,_that.buyIns,_that.cashOut);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tableId,  String? userId,  String userName,  String? guestName,  String? guestPixKey,  DateTime joinedAt,  DateTime? leftAt,  List<BuyIn> buyIns,  CashOut? cashOut)?  $default,) {final _that = this;
switch (_that) {
case _TableParticipation() when $default != null:
return $default(_that.id,_that.tableId,_that.userId,_that.userName,_that.guestName,_that.guestPixKey,_that.joinedAt,_that.leftAt,_that.buyIns,_that.cashOut);case _:
  return null;

}
}

}

/// @nodoc


class _TableParticipation extends TableParticipation {
  const _TableParticipation({required this.id, required this.tableId, this.userId, required this.userName, this.guestName, this.guestPixKey, required this.joinedAt, this.leftAt, final  List<BuyIn> buyIns = const <BuyIn>[], this.cashOut}): _buyIns = buyIns,super._();
  

@override final  String id;
@override final  String tableId;
@override final  String? userId;
@override final  String userName;
@override final  String? guestName;
@override final  String? guestPixKey;
@override final  DateTime joinedAt;
@override final  DateTime? leftAt;
 final  List<BuyIn> _buyIns;
@override@JsonKey() List<BuyIn> get buyIns {
  if (_buyIns is EqualUnmodifiableListView) return _buyIns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buyIns);
}

@override final  CashOut? cashOut;

/// Create a copy of TableParticipation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableParticipationCopyWith<_TableParticipation> get copyWith => __$TableParticipationCopyWithImpl<_TableParticipation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableParticipation&&(identical(other.id, id) || other.id == id)&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestPixKey, guestPixKey) || other.guestPixKey == guestPixKey)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&const DeepCollectionEquality().equals(other._buyIns, _buyIns)&&(identical(other.cashOut, cashOut) || other.cashOut == cashOut));
}


@override
int get hashCode => Object.hash(runtimeType,id,tableId,userId,userName,guestName,guestPixKey,joinedAt,leftAt,const DeepCollectionEquality().hash(_buyIns),cashOut);

@override
String toString() {
  return 'TableParticipation(id: $id, tableId: $tableId, userId: $userId, userName: $userName, guestName: $guestName, guestPixKey: $guestPixKey, joinedAt: $joinedAt, leftAt: $leftAt, buyIns: $buyIns, cashOut: $cashOut)';
}


}

/// @nodoc
abstract mixin class _$TableParticipationCopyWith<$Res> implements $TableParticipationCopyWith<$Res> {
  factory _$TableParticipationCopyWith(_TableParticipation value, $Res Function(_TableParticipation) _then) = __$TableParticipationCopyWithImpl;
@override @useResult
$Res call({
 String id, String tableId, String? userId, String userName, String? guestName, String? guestPixKey, DateTime joinedAt, DateTime? leftAt, List<BuyIn> buyIns, CashOut? cashOut
});


@override $CashOutCopyWith<$Res>? get cashOut;

}
/// @nodoc
class __$TableParticipationCopyWithImpl<$Res>
    implements _$TableParticipationCopyWith<$Res> {
  __$TableParticipationCopyWithImpl(this._self, this._then);

  final _TableParticipation _self;
  final $Res Function(_TableParticipation) _then;

/// Create a copy of TableParticipation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tableId = null,Object? userId = freezed,Object? userName = null,Object? guestName = freezed,Object? guestPixKey = freezed,Object? joinedAt = null,Object? leftAt = freezed,Object? buyIns = null,Object? cashOut = freezed,}) {
  return _then(_TableParticipation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestPixKey: freezed == guestPixKey ? _self.guestPixKey : guestPixKey // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buyIns: null == buyIns ? _self._buyIns : buyIns // ignore: cast_nullable_to_non_nullable
as List<BuyIn>,cashOut: freezed == cashOut ? _self.cashOut : cashOut // ignore: cast_nullable_to_non_nullable
as CashOut?,
  ));
}

/// Create a copy of TableParticipation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CashOutCopyWith<$Res>? get cashOut {
    if (_self.cashOut == null) {
    return null;
  }

  return $CashOutCopyWith<$Res>(_self.cashOut!, (value) {
    return _then(_self.copyWith(cashOut: value));
  });
}
}

// dart format on
