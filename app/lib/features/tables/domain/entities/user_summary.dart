/// Pequeno resumo de um usuário cadastrado — o suficiente pra autocomplete
/// de busca quando o host está adicionando um jogador. Não inclui PIX (o
/// backend resolve no `join`).
class UserSummary {
  const UserSummary({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}
