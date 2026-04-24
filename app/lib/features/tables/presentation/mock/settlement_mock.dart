/// Mock do settlement compartilhado entre Close, Pix e Detail — cópia 1:1
/// do `settlementMock` em screens-part3.jsx do design system.
class SettlementMockPlayer {
  const SettlementMockPlayer({
    required this.name,
    required this.pix,
    required this.invested,
    required this.out,
    required this.pl,
    this.role,
  });
  final String name;
  final String pix;
  final int invested;
  final int out;
  final int pl;
  final String? role;
}

class SettlementMockTransfer {
  const SettlementMockTransfer({
    required this.from,
    required this.to,
    required this.amount,
    required this.pix,
  });
  final String from;
  final String to;
  final int amount;
  final String pix;
}

class SettlementMockEvent {
  const SettlementMockEvent({
    required this.time,
    required this.kind,
    required this.text,
  });
  final String time;
  final String kind; // start, join, rebuy, out, close
  final String text;
}

class SettlementMock {
  static const table = 'Sexta na casa do Léo';
  static const duration = '4h 12min';
  static const date = '20 abr 2026';

  static const players = <SettlementMockPlayer>[
    SettlementMockPlayer(
      name: 'Léo Castro',
      pix: 'leo@gmail.com',
      invested: 300,
      out: 180,
      pl: -120,
      role: 'HOST',
    ),
    SettlementMockPlayer(
      name: 'Rafael Monteiro',
      pix: 'rafa.monteiro@gmail.com',
      invested: 150,
      out: 340,
      pl: 190,
      role: 'VOCÊ',
    ),
    SettlementMockPlayer(
      name: 'Amanda S.',
      pix: '11987654321',
      invested: 200,
      out: 450,
      pl: 250,
    ),
    SettlementMockPlayer(
      name: 'Caio Farias',
      pix: 'caio.f@outlook.com',
      invested: 200,
      out: 60,
      pl: -140,
    ),
    SettlementMockPlayer(
      name: 'Bruno T.',
      pix: '987.654.321-00',
      invested: 100,
      out: 0,
      pl: -100,
    ),
    SettlementMockPlayer(
      name: 'Marina R.',
      pix: 'marina.r@gmail.com',
      invested: 150,
      out: 70,
      pl: -80,
    ),
  ];

  static const transfers = <SettlementMockTransfer>[
    SettlementMockTransfer(
      from: 'Léo Castro',
      to: 'Rafael Monteiro',
      amount: 120,
      pix: 'rafa.monteiro@gmail.com',
    ),
    SettlementMockTransfer(
      from: 'Caio Farias',
      to: 'Rafael Monteiro',
      amount: 70,
      pix: 'rafa.monteiro@gmail.com',
    ),
    SettlementMockTransfer(
      from: 'Caio Farias',
      to: 'Amanda S.',
      amount: 70,
      pix: '11987654321',
    ),
    SettlementMockTransfer(
      from: 'Bruno T.',
      to: 'Amanda S.',
      amount: 100,
      pix: '11987654321',
    ),
    SettlementMockTransfer(
      from: 'Marina R.',
      to: 'Amanda S.',
      amount: 80,
      pix: '11987654321',
    ),
  ];

  static const events = <SettlementMockEvent>[
    SettlementMockEvent(
      time: '20:14',
      kind: 'start',
      text: 'Mesa aberta por Léo Castro',
    ),
    SettlementMockEvent(
      time: '20:22',
      kind: 'join',
      text: 'Rafael Monteiro entrou · R\$ 150',
    ),
    SettlementMockEvent(
      time: '20:25',
      kind: 'join',
      text: 'Amanda S. entrou · R\$ 100',
    ),
    SettlementMockEvent(
      time: '20:27',
      kind: 'join',
      text: 'Caio Farias entrou · R\$ 200',
    ),
    SettlementMockEvent(
      time: '20:30',
      kind: 'join',
      text: 'Bruno T. entrou · R\$ 100',
    ),
    SettlementMockEvent(
      time: '21:48',
      kind: 'rebuy',
      text: 'Amanda S. rebuy · R\$ 50',
    ),
    SettlementMockEvent(
      time: '22:30',
      kind: 'rebuy',
      text: 'Léo Castro rebuy · R\$ 100',
    ),
    SettlementMockEvent(
      time: '23:05',
      kind: 'out',
      text: 'Bruno T. saiu · R\$ 0 (−R\$ 100)',
    ),
    SettlementMockEvent(
      time: '23:40',
      kind: 'rebuy',
      text: 'Amanda S. rebuy · R\$ 50',
    ),
    SettlementMockEvent(
      time: '00:26',
      kind: 'close',
      text: 'Mesa fechada · 5 PIX gerados',
    ),
  ];

  static int get totalPot =>
      players.fold<int>(0, (sum, p) => sum + p.invested);
}
