import 'package:decimal/decimal.dart';

import '../../domain/entities/settlement_draft.dart';

/// A API expõe settlements como registros persistidos. Pro app que só
/// precisa exibir o "quem paga quem", mapeamos para [SettlementDraft].
class SettlementDto {
  static SettlementDraft toDraft(Map<String, dynamic> json) {
    final from = json['fromUser'] as Map<String, dynamic>?;
    final to = json['toUser'] as Map<String, dynamic>?;
    final fromGuest = json['fromGuestName'] as String?;
    final toGuest = json['toGuestName'] as String?;
    return SettlementDraft(
      fromUserId: json['fromUserId'] as String?,
      fromUserName: from?['name'] as String? ?? fromGuest ?? 'Convidado',
      toUserId: json['toUserId'] as String?,
      toUserName: to?['name'] as String? ?? toGuest ?? 'Convidado',
      toPixKey: json['toPixKey'] as String? ??
          to?['pixKey'] as String? ??
          '',
      amount: _decimal(json['amount']),
    );
  }

  static Decimal _decimal(Object? value) {
    if (value is String) return Decimal.parse(value);
    if (value is num) return Decimal.parse(value.toString());
    throw StateError('Valor decimal inválido: $value');
  }
}
