// Splitpot — Screens part 3: Close (settlement review), PIX confirmation, History, Detail

// Optimized P2P settlement mock data
const settlementMock = {
  table: 'Sexta na casa do Léo',
  duration: '4h 12min',
  date: '20 abr 2026',
  players: [
    { name: 'Léo Castro', pix: 'leo@gmail.com', invested: 300, out: 180, pl: -120, role: 'HOST' },
    { name: 'Rafael Monteiro', pix: 'rafa.monteiro@gmail.com', invested: 150, out: 340, pl: 190, role: 'VOCÊ' },
    { name: 'Amanda S.', pix: '11987654321', invested: 200, out: 450, pl: 250 },
    { name: 'Caio Farias', pix: 'caio.f@outlook.com', invested: 200, out: 60, pl: -140 },
    { name: 'Bruno T.', pix: '987.654.321-00', invested: 100, out: 0, pl: -100 },
    { name: 'Marina R.', pix: 'marina.r@gmail.com', invested: 150, out: 70, pl: -80 },
  ],
  transfers: [
    { from: 'Léo Castro', to: 'Rafael Monteiro', amount: 120, pix: 'rafa.monteiro@gmail.com' },
    { from: 'Caio Farias', to: 'Rafael Monteiro', amount: 70, pix: 'rafa.monteiro@gmail.com' },
    { from: 'Caio Farias', to: 'Amanda S.', amount: 70, pix: '11987654321' },
    { from: 'Bruno T.', to: 'Amanda S.', amount: 100, pix: '11987654321' },
    { from: 'Marina R.', to: 'Amanda S.', amount: 80, pix: '11987654321' },
  ],
};

// ══════════════════════════════════════════════════════════
// 9. CLOSE TABLE — host revê acertos otimizados
// ══════════════════════════════════════════════════════════
const ScreenClose = ({ onNav }) => {
  const d = settlementMock;
  const totalPot = d.players.reduce((s, p) => s + p.invested, 0);
  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader left={<BackArrow onClick={() => onNav('live')}/>} title="Fechar mesa" subtitle="revisão final"/>

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '4px 20px 20px' }}>
        {/* summary card */}
        <div style={{
          background: 'linear-gradient(135deg, rgba(212,162,74,0.14), rgba(212,162,74,0.02))',
          border: '1px solid rgba(212,162,74,0.3)',
          borderRadius: 16, padding: 16,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <div>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase' }}>Pote total</div>
              <div className="sp-num sp-gold-foil" style={{ fontSize: 28, fontWeight: 800, marginTop: 2 }}>{BRL(totalPot)}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Duração</div>
              <div className="sp-num" style={{ fontSize: 14, color: 'var(--cream)', marginTop: 2, fontWeight: 600 }}>{d.duration}</div>
              <div className="sp-ui" style={{ fontSize: 11, color: 'var(--muted)', marginTop: 4 }}>{d.players.length} jogadores</div>
            </div>
          </div>
        </div>

        {/* P&L por jogador */}
        <div style={{ marginTop: 22 }}>
          <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 10 }}>Resultado da mesa</div>
          <div style={{ background: 'rgba(8,25,15,0.5)', border: '1px solid rgba(245,236,214,0.08)', borderRadius: 12, overflow: 'hidden' }}>
            {d.players.map((p, i) => (
              <div key={p.name} style={{
                padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
                borderBottom: i < d.players.length - 1 ? '1px solid rgba(245,236,214,0.06)' : 'none',
              }}>
                <Avatar name={p.name} size={32}/>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div className="sp-ui" style={{ fontSize: 13, color: 'var(--cream)', fontWeight: 600, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.name}</div>
                  <div className="sp-num" style={{ fontSize: 11, color: 'var(--muted)', marginTop: 1 }}>entrou {BRL(p.invested)} · saiu {BRL(p.out)}</div>
                </div>
                <div className="sp-num" style={{ fontSize: 15, fontWeight: 700, color: p.pl >= 0 ? '#6bc997' : '#e57373' }}>
                  {p.pl >= 0 ? '+' : ''}{BRL(p.pl)}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Settlement diagram */}
        <div style={{ marginTop: 22 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
            <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase' }}>Acertos PIX · otimizados</div>
            <div className="sp-ui" style={{ fontSize: 11, color: 'var(--muted)' }}>{d.transfers.length} transferências</div>
          </div>
          <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 4, lineHeight: 1.4 }}>
            Algoritmo minimizou de {d.players.length * (d.players.length-1) / 2} para apenas {d.transfers.length} pagamentos.
          </div>

          <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {d.transfers.map((t, i) => (
              <div key={i} style={{
                padding: '12px 14px', borderRadius: 12,
                background: 'rgba(8,25,15,0.5)',
                border: '1px solid rgba(245,236,214,0.08)',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Avatar name={t.from} size={30}/>
                  <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8 }}>
                    <div style={{ flex: 1, height: 1, background: 'linear-gradient(90deg, transparent, rgba(212,162,74,0.6))' }}/>
                    <div className="sp-num" style={{
                      padding: '4px 10px', borderRadius: 999,
                      background: 'rgba(212,162,74,0.18)',
                      border: '1px solid rgba(212,162,74,0.35)',
                      color: 'var(--gold-bright)', fontSize: 13, fontWeight: 700,
                    }}>{BRL(t.amount)}</div>
                    <div style={{ flex: 1, height: 1, background: 'linear-gradient(90deg, rgba(212,162,74,0.6), transparent)' }}/>
                  </div>
                  <Avatar name={t.to} size={30}/>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 6 }}>
                  <div className="sp-ui" style={{ fontSize: 12, color: 'var(--cream)' }}>{t.from.split(' ')[0]}</div>
                  <div className="sp-ui" style={{ fontSize: 10, color: 'var(--muted)', fontFamily: 'JetBrains Mono' }}>→ {t.pix}</div>
                  <div className="sp-ui" style={{ fontSize: 12, color: 'var(--cream)' }}>{t.to.split(' ')[0]}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ padding: '14px 20px 32px', display: 'flex', gap: 10 }}>
        <button onClick={() => onNav('live')} className="sp-btn-ghost" style={{
          flex: 1, height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 15,
        }}>Voltar</button>
        <button onClick={() => onNav('pix')} className="sp-btn-gold" style={{
          flex: 1.5, height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 15,
        }}>Gerar QR Codes PIX</button>
      </div>
    </div>
  );
};

// ══════════════════════════════════════════════════════════
// 10. PIX CONFIRMATION — status de cada transferência
// ══════════════════════════════════════════════════════════
const ScreenPix = ({ onNav }) => {
  const d = settlementMock;
  // Mock status: 3 done, 1 pending, 1 failed
  const statuses = ['done', 'done', 'pending', 'failed', 'done'];
  const labels = {
    done: { t: 'Pago', c: '#6bc997', bg: 'rgba(46,143,90,0.18)', bd: 'rgba(46,143,90,0.4)' },
    pending: { t: 'Aguardando', c: '#f0c770', bg: 'rgba(212,162,74,0.18)', bd: 'rgba(212,162,74,0.4)' },
    failed: { t: 'Falhou', c: '#e57373', bg: 'rgba(192,57,43,0.18)', bd: 'rgba(192,57,43,0.4)' },
  };
  const doneCount = statuses.filter(s => s === 'done').length;
  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader left={<BackArrow onClick={() => onNav('close')}/>} title="Acertos PIX"/>

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '4px 20px 20px' }}>
        {/* progress */}
        <div style={{
          background: 'rgba(8,25,15,0.55)', border: '1px solid rgba(212,162,74,0.3)', borderRadius: 16, padding: 18,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase' }}>Progresso</div>
              <div className="sp-num" style={{ fontSize: 28, fontWeight: 700, color: 'var(--cream)', marginTop: 2 }}>
                <span style={{ color: 'var(--gold-bright)' }}>{doneCount}</span>
                <span style={{ color: 'var(--muted)', fontSize: 20 }}> / {d.transfers.length}</span>
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Confirmados</div>
              <div className="sp-num" style={{ fontSize: 14, color: 'var(--cream)', marginTop: 2, fontWeight: 600 }}>{BRL(d.transfers.filter((_,i)=>statuses[i]==='done').reduce((s,t)=>s+t.amount,0))}</div>
            </div>
          </div>
          <div style={{ marginTop: 14, height: 6, borderRadius: 3, background: 'rgba(8,25,15,0.8)', overflow: 'hidden' }}>
            <div style={{ width: `${(doneCount / d.transfers.length) * 100}%`, height: '100%', background: 'linear-gradient(90deg, #d4a24a, #f0c770)', transition: 'width 0.4s' }}/>
          </div>
        </div>

        {/* transfer list */}
        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {d.transfers.map((t, i) => {
            const st = statuses[i];
            const lab = labels[st];
            return (
              <div key={i} style={{
                padding: '14px', borderRadius: 12,
                background: 'rgba(8,25,15,0.55)',
                border: `1px solid ${st === 'failed' ? lab.bd : 'rgba(245,236,214,0.08)'}`,
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Avatar name={t.from} size={32}/>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div className="sp-ui" style={{ fontSize: 13, color: 'var(--cream)', fontWeight: 500 }}>
                      <span style={{ color: 'var(--cream)', fontWeight: 600 }}>{t.from.split(' ')[0]}</span>
                      <span style={{ color: 'var(--muted)' }}> → </span>
                      <span style={{ color: 'var(--cream)', fontWeight: 600 }}>{t.to.split(' ')[0]}</span>
                    </div>
                    <div className="sp-num" style={{ fontSize: 11, color: 'var(--muted)', marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {t.pix}
                    </div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <div className="sp-num" style={{ fontSize: 16, fontWeight: 700, color: 'var(--cream)' }}>{BRL(t.amount)}</div>
                    <div className="sp-ui" style={{
                      display: 'inline-block', marginTop: 3,
                      fontSize: 10, fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase',
                      padding: '2px 8px', borderRadius: 4,
                      background: lab.bg, color: lab.c, border: `1px solid ${lab.bd}`,
                    }}>
                      {st === 'done' && '✓ '}{lab.t}
                    </div>
                  </div>
                </div>
                {st === 'pending' && (
                  <div style={{ marginTop: 10, display: 'flex', gap: 8 }}>
                    <button className="sp-btn-gold" style={{ flex: 1, padding: '8px 0', borderRadius: 8, fontSize: 12, cursor: 'pointer' }}>
                      Abrir QR Code PIX
                    </button>
                    <button className="sp-btn-ghost" style={{ flex: 1, padding: '8px 0', borderRadius: 8, fontSize: 12, cursor: 'pointer' }}>
                      Marcar pago
                    </button>
                  </div>
                )}
                {st === 'failed' && (
                  <div style={{ marginTop: 10, display: 'flex', alignItems: 'center', gap: 8, padding: '8px 10px', background: 'rgba(192,57,43,0.12)', borderRadius: 8 }}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" style={{ color: '#e57373', flexShrink: 0 }}>
                      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.8"/>
                      <path d="M15 9l-6 6M9 9l6 6" stroke="currentColor" strokeWidth="1.8"/>
                    </svg>
                    <div className="sp-ui" style={{ fontSize: 11, color: '#e57373', flex: 1 }}>Chave PIX inválida. Contate {t.to.split(' ')[0]}.</div>
                    <button style={{ background: 'transparent', border: 'none', color: '#e57373', fontSize: 11, fontWeight: 600, cursor: 'pointer' }}>Tentar de novo</button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      <div style={{ padding: '14px 20px 32px' }}>
        <button onClick={() => onNav('home')} className="sp-btn-gold" style={{
          width: '100%', height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 16,
        }}>Encerrar mesa</button>
      </div>
    </div>
  );
};

// ══════════════════════════════════════════════════════════
// 11. HISTORY — lista de mesas passadas
// ══════════════════════════════════════════════════════════
const ScreenHistory = ({ onNav }) => {
  const tables = [
    { date: 'Ontem', name: 'Sexta na casa do Léo', players: 7, pl: 340, duration: '4h 12min', role: 'Jogador' },
    { date: '12 abr', name: 'Mesa do escritório', players: 5, pl: -120, duration: '3h 05min', role: 'Jogador' },
    { date: '05 abr', name: 'Aniversário do Caio', players: 6, pl: 622, duration: '5h 40min', role: 'Host' },
    { date: '29 mar', name: 'Domingo regular', players: 8, pl: -210, duration: '3h 50min', role: 'Host' },
    { date: '22 mar', name: 'Terça quick', players: 4, pl: 180, duration: '2h 10min', role: 'Jogador' },
    { date: '15 mar', name: 'Sexta na casa do Léo', players: 7, pl: 90, duration: '4h 30min', role: 'Jogador' },
  ];
  const total = tables.reduce((s, t) => s + t.pl, 0);
  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader left={<BackArrow onClick={() => onNav('home')}/>} title="Histórico"/>

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '4px 20px 40px' }}>
        {/* Stats panel */}
        <div style={{
          background: 'linear-gradient(135deg, rgba(212,162,74,0.15), rgba(212,162,74,0.02))',
          border: '1px solid rgba(212,162,74,0.3)',
          borderRadius: 16, padding: 18,
        }}>
          <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase' }}>P&L acumulado</div>
          <div className="sp-num sp-gold-foil" style={{ fontSize: 36, fontWeight: 800, marginTop: 2, lineHeight: 1 }}>
            +{BRL(total)}
          </div>
          <div style={{ display: 'flex', gap: 18, marginTop: 14 }}>
            <Stat label="Mesas" value={tables.length}/>
            <Stat label="Vitórias" value={tables.filter(t=>t.pl>0).length}/>
            <Stat label="ROI médio" value="+18%"/>
            <Stat label="Como host" value={tables.filter(t=>t.role==='Host').length}/>
          </div>
        </div>

        {/* List */}
        <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', margin: '24px 4px 12px' }}>
          Todas as mesas
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {tables.map((t, i) => (
            <button key={i} onClick={() => onNav('detail')} style={{
              padding: '14px', borderRadius: 12,
              background: 'rgba(8,25,15,0.55)',
              border: '1px solid rgba(245,236,214,0.08)',
              display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer', textAlign: 'left',
            }}>
              <div style={{
                width: 48, height: 48, borderRadius: 8, flexShrink: 0,
                background: t.pl >= 0 ? 'rgba(46,143,90,0.12)' : 'rgba(192,57,43,0.12)',
                border: `1px solid ${t.pl >= 0 ? 'rgba(46,143,90,0.3)' : 'rgba(192,57,43,0.3)'}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Suit suit={t.pl >= 0 ? 'h' : 's'} size={22} color={t.pl >= 0 ? '#6bc997' : '#e57373'}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div className="sp-ui" style={{ color: 'var(--cream)', fontSize: 14, fontWeight: 600, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                  {t.name}
                </div>
                <div className="sp-ui" style={{ color: 'var(--muted)', fontSize: 11, marginTop: 3, display: 'flex', gap: 6 }}>
                  <span>{t.date}</span><span>·</span>
                  <span>{t.players} jog.</span><span>·</span>
                  <span>{t.duration}</span>
                  {t.role === 'Host' && <><span>·</span><span style={{ color: 'var(--gold)' }}>Host</span></>}
                </div>
              </div>
              <div className="sp-num" style={{ fontSize: 15, fontWeight: 700, color: t.pl >= 0 ? '#6bc997' : '#e57373' }}>
                {t.pl >= 0 ? '+' : ''}{BRL(t.pl)}
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

const Stat = ({ label, value }) => (
  <div>
    <div className="sp-num" style={{ fontSize: 18, fontWeight: 700, color: 'var(--cream)' }}>{value}</div>
    <div className="sp-ui" style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase', marginTop: 2 }}>{label}</div>
  </div>
);

// ══════════════════════════════════════════════════════════
// 12. TABLE DETAIL — mesa passada
// ══════════════════════════════════════════════════════════
const ScreenDetail = ({ onNav }) => {
  const d = settlementMock;
  const you = d.players.find(p => p.role === 'VOCÊ');
  const events = [
    { t: '20:14', kind: 'start', text: 'Mesa aberta por Léo Castro' },
    { t: '20:22', kind: 'join', text: 'Rafael Monteiro entrou · R$ 150' },
    { t: '20:25', kind: 'join', text: 'Amanda S. entrou · R$ 100' },
    { t: '20:27', kind: 'join', text: 'Caio Farias entrou · R$ 200' },
    { t: '20:30', kind: 'join', text: 'Bruno T. entrou · R$ 100' },
    { t: '21:48', kind: 'rebuy', text: 'Amanda S. rebuy · R$ 50' },
    { t: '22:30', kind: 'rebuy', text: 'Léo Castro rebuy · R$ 100' },
    { t: '23:05', kind: 'out', text: 'Bruno T. saiu · R$ 0 (−R$ 100)' },
    { t: '23:40', kind: 'rebuy', text: 'Amanda S. rebuy · R$ 50' },
    { t: '00:26', kind: 'close', text: 'Mesa fechada · 5 PIX gerados' },
  ];
  const iconFor = (k) => {
    if (k === 'start' || k === 'close') return <Suit suit="s" size={10} color="#d4a24a"/>;
    if (k === 'join') return <span style={{ color: '#6bc997' }}>+</span>;
    if (k === 'rebuy') return <span style={{ color: '#f0c770' }}>↻</span>;
    if (k === 'out') return <span style={{ color: '#e57373' }}>−</span>;
  };
  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader left={<BackArrow onClick={() => onNav('history')}/>} title="Detalhes da mesa"/>

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '4px 20px 32px' }}>
        {/* Header card */}
        <div style={{
          background: 'rgba(8,25,15,0.55)',
          border: '1px solid rgba(212,162,74,0.3)',
          borderRadius: 16, padding: 18,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ position: 'absolute', right: -10, bottom: -18, opacity: 0.25 }}>
            <PokerChip size={100} color="#d4a24a" count={3}/>
          </div>
          <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase' }}>{d.date} · encerrada</div>
          <div className="sp-display" style={{ fontSize: 22, fontWeight: 700, color: 'var(--cream)', marginTop: 4, lineHeight: 1.2 }}>{d.table}</div>

          <div style={{ display: 'flex', gap: 20, marginTop: 16 }}>
            <Stat label="Duração" value={d.duration}/>
            <Stat label="Pote" value={BRL(d.players.reduce((s,p)=>s+p.invested,0))}/>
            <Stat label="Jogadores" value={d.players.length}/>
          </div>

          <div className="sp-divider-gold" style={{ margin: '16px 0' }}/>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold-dark)', fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase' }}>Seu resultado</div>
              <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>Investiu {BRL(you.invested)} · Saiu {BRL(you.out)}</div>
            </div>
            <div className="sp-num" style={{ fontSize: 26, fontWeight: 800, color: '#6bc997' }}>
              +{BRL(you.pl)}
            </div>
          </div>
        </div>

        {/* Timeline */}
        <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', margin: '24px 4px 12px' }}>
          Linha do tempo
        </div>
        <div style={{ background: 'rgba(8,25,15,0.55)', border: '1px solid rgba(245,236,214,0.08)', borderRadius: 12, padding: '6px 0' }}>
          {events.map((e, i) => (
            <div key={i} style={{ padding: '10px 16px', display: 'flex', alignItems: 'center', gap: 12 }}>
              <div className="sp-num" style={{ fontSize: 11, color: 'var(--muted)', width: 40 }}>{e.t}</div>
              <div style={{
                width: 22, height: 22, borderRadius: '50%', flexShrink: 0,
                background: 'rgba(212,162,74,0.12)', border: '1px solid rgba(212,162,74,0.3)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 12, fontWeight: 700,
              }}>{iconFor(e.kind)}</div>
              <div className="sp-ui" style={{ fontSize: 13, color: 'var(--cream)', flex: 1 }}>{e.text}</div>
            </div>
          ))}
        </div>

        {/* Player results */}
        <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', margin: '24px 4px 12px' }}>
          Resultado por jogador
        </div>
        <div style={{ background: 'rgba(8,25,15,0.55)', border: '1px solid rgba(245,236,214,0.08)', borderRadius: 12, overflow: 'hidden' }}>
          {d.players.map((p, i) => (
            <div key={p.name} style={{
              padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
              borderBottom: i < d.players.length - 1 ? '1px solid rgba(245,236,214,0.06)' : 'none',
            }}>
              <Avatar name={p.name} size={30}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div className="sp-ui" style={{ fontSize: 13, color: 'var(--cream)', fontWeight: 600 }}>{p.name}</div>
                <div className="sp-num" style={{ fontSize: 10, color: 'var(--muted)', marginTop: 1 }}>{BRL(p.invested)} → {BRL(p.out)}</div>
              </div>
              <div className="sp-num" style={{ fontSize: 14, fontWeight: 700, color: p.pl >= 0 ? '#6bc997' : '#e57373' }}>
                {p.pl >= 0 ? '+' : ''}{BRL(p.pl)}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

Object.assign(window, { ScreenClose, ScreenPix, ScreenHistory, ScreenDetail });
