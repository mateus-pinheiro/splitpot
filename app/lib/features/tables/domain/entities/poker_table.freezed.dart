// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poker_table.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PokerTable {

 String get id; String get ownerId; String get name; Decimal get minBuyIn; TableStatus get status; DateTime get createdAt; DateTime? get closedAt; List<TableParticipation> get participations; List<ActionRequest> get pendingRequests;
/// Create a copy of PokerTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PokerTableCopyWith<PokerTable> get copyWith => _$PokerTableCopyWithImpl<PokerTable>(this as PokerTable, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PokerTable&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.minBuyIn, minBuyIn) || other.minBuyIn == minBuyIn)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&const DeepCollectionEquality().equals(other.participations, participations)&&const DeepCollectionEquality().equals(other.pendingRequests, pendingRequests));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,minBuyIn,status,createdAt,closedAt,const DeepCollectionEquality().hash(participations),const DeepCollectionEquality().hash(pendingRequests));

@override
String toString() {
  return 'PokerTable(id: $id, ownerId: $ownerId, name: $name, minBuyIn: $minBuyIn, status: $status, createdAt: $createdAt, closedAt: $closedAt, participations: $participations, pendingRequests: $pendingRequests)';
}


}

/// @nodoc
abstract mixin class $PokerTableCopyWith<$Res>  {
  factory $PokerTableCopyWith(PokerTable value, $Res Function(PokerTable) _then) = _$PokerTableCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String name, Decimal minBuyIn, TableStatus status, DateTime createdAt, DateTime? closedAt, List<TableParticipation> participations, List<ActionRequest> pendingRequests
});




}
/// @nodoc
class _$PokerTableCopyWithImpl<$Res>
    implements $PokerTableCopyWith<$Res> {
  _$PokerTableCopyWithImpl(this._self, this._then);

  final PokerTable _self;
  final $Res Function(PokerTable) _then;

/// Create a copy of PokerTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? minBuyIn = null,Object? status = null,Object? createdAt = null,Object? closedAt = freezed,Object? participations = null,Object? pendingRequests = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,minBuyIn: null == minBuyIn ? _self.minBuyIn : minBuyIn // ignore: cast_nullable_to_non_nullable
as Decimal,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TableStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,participations: null == participations ? _self.participations : participations // ignore: cast_nullable_to_non_nullable
as List<TableParticipation>,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as List<ActionRequest>,
  ));
}

}


/// Adds pattern-matching-related methods to [PokerTable].
extension PokerTablePatterns on PokerTable {
@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PokerTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PokerTable() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PokerTable value)  $default,){
final _that = this;
switch (_that) {
case _PokerTable():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PokerTable value)?  $default,){
final _that = this;
switch (_that) {
case _PokerTable() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  Decimal minBuyIn,  TableStatus status,  DateTime createdAt,  DateTime? closedAt,  List<TableParticipation> participations,  List<ActionRequest> pendingRequests)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PokerTable() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.minBuyIn,_that.status,_that.createdAt,_that.closedAt,_that.participations,_that.pendingRequests);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  Decimal minBuyIn,  TableStatus status,  DateTime createdAt,  DateTime? closedAt,  List<TableParticipation> participations,  List<ActionRequest> pendingRequests)  $default,) {final _that = this;
switch (_that) {
case _PokerTable():
return $default(_that.id,_that.ownerId,_that.name,_that.minBuyIn,_that.status,_that.createdAt,_that.closedAt,_that.participations,_that.pendingRequests);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String name,  Decimal minBuyIn,  TableStatus status,  DateTime createdAt,  DateTime? closedAt,  List<TableParticipation> participations,  List<ActionRequest> pendingRequests)?  $default,) {final _that = this;
switch (_that) {
case _PokerTable() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.minBuyIn,_that.status,_that.createdAt,_that.closedAt,_that.participations,_that.pendingRequests);case _:
  return null;

}
}

}

/// @nodoc


class _PokerTable implements PokerTable {
  const _PokerTable({required this.id, required this.ownerId, required this.name, required this.minBuyIn, required this.status, required this.createdAt, this.closedAt, final  List<TableParticipation> participations = const <TableParticipation>[], final  List<ActionRequest> pendingRequests = const <ActionRequest>[]}): _participations = participations, _pendingRequests = pendingRequests;


@override final  String id;
@override final  String ownerId;
@override final  String name;
@override final  Decimal minBuyIn;
@override final  TableStatus status;
@override final  DateTime createdAt;
@override final  DateTime? closedAt;
 final  List<TableParticipation> _participations;
@override@JsonKey() List<TableParticipation> get participations {
  if (_participations is EqualUnmodifiableListView) return _participations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participations);
}

 final  List<ActionRequest> _pendingRequests;
@override@JsonKey() List<ActionRequest> get pendingRequests {
  if (_pendingRequests is EqualUnmodifiableListView) return _pendingRequests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingRequests);
}


/// Create a copy of PokerTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PokerTableCopyWith<_PokerTable> get copyWith => __$PokerTableCopyWithImpl<_PokerTable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PokerTable&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.minBuyIn, minBuyIn) || other.minBuyIn == minBuyIn)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&const DeepCollectionEquality().equals(other._participations, _participations)&&const DeepCollectionEquality().equals(other._pendingRequests, _pendingRequests));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,minBuyIn,status,createdAt,closedAt,const DeepCollectionEquality().hash(_participations),const DeepCollectionEquality().hash(_pendingRequests));

@override
String toString() {
  return 'PokerTable(id: $id, ownerId: $ownerId, name: $name, minBuyIn: $minBuyIn, status: $status, createdAt: $createdAt, closedAt: $closedAt, participations: $participations, pendingRequests: $pendingRequests)';
}


}

/// @nodoc
abstract mixin class _$PokerTableCopyWith<$Res> implements $PokerTableCopyWith<$Res> {
  factory _$PokerTableCopyWith(_PokerTable value, $Res Function(_PokerTable) _then) = __$PokerTableCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String name, Decimal minBuyIn, TableStatus status, DateTime createdAt, DateTime? closedAt, List<TableParticipation> participations, List<ActionRequest> pendingRequests
});




}
/// @nodoc
class __$PokerTableCopyWithImpl<$Res>
    implements _$PokerTableCopyWith<$Res> {
  __$PokerTableCopyWithImpl(this._self, this._then);

  final _PokerTable _self;
  final $Res Function(_PokerTable) _then;

/// Create a copy of PokerTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? minBuyIn = null,Object? status = null,Object? createdAt = null,Object? closedAt = freezed,Object? participations = null,Object? pendingRequests = null,}) {
  return _then(_PokerTable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,minBuyIn: null == minBuyIn ? _self.minBuyIn : minBuyIn // ignore: cast_nullable_to_non_nullable
as Decimal,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TableStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,participations: null == participations ? _self._participations : participations // ignore: cast_nullable_to_non_nullable
as List<TableParticipation>,pendingRequests: null == pendingRequests ? _self._pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as List<ActionRequest>,
  ));
}


}

// dart format on
