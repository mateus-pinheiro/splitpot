import '../../../../core/network/api_client.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/repositories/settlements_repository.dart';
import '../dto/settlement_full_dto.dart';

class SettlementsRepositoryImpl implements SettlementsRepository {
  SettlementsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Settlement>> listByTable(String tableId) async {
    final list = await _api.getList(
      '/settlements',
      query: {'tableId': tableId},
    );
    return list
        .map((e) => SettlementFullDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> confirm(String settlementId) async {
    await _api.post('/settlements/$settlementId/confirm');
  }

  @override
  Future<void> confirmOnBehalf(String settlementId) async {
    await _api.post('/settlements/$settlementId/confirm-on-behalf');
  }
}
