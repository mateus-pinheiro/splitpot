// Splitpot — Screens part 2: Join (player scans QR), Live Table, Cash Out

// ══════════════════════════════════════════════════════════
// 6. JOIN TABLE — jogador escaneou QR, informa buy-in
// ══════════════════════════════════════════════════════════
const ScreenJoin = ({ onNav }) => {
  const [amount, setAmount] = React.useState(100);
  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader left={<BackArrow onClick={() => onNav('home')}/>} title="Entrar na mesa" />

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '8px 24px 20px' }}>
        {/* Table info card */}
        <div style={{
          background: 'rgba(8,25,15,0.6)',
          border: '1px solid rgba(212,162,74,0.3)',
          borderRadius: 16, padding: 18,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ position: 'absolute', right: 12, top: 12, opacity: 0.25 }}>
            <Suit suit="s" size={40} color="#d4a24a"/>
          </div>
          <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase' }}>Mesa K7N-2QX</div>
          <div className="sp-display" style={{ fontSize: 22, fontWeight: 700, color: 'var(--cream)', marginTop: 4, lineHeight: 1.2 }}>Sexta na casa do Léo</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 12 }}>
            <Avatar name="Léo Castro" size={26}/>
            <div className="sp-ui" style={{ fontSize: 13, color: 'var(--cream)' }}>Léo Castro <span style={{ color: 'var(--muted)' }}>é o host</span></div>
          </div>
          <div className="sp-divider-gold" style={{ margin: '14px 0' }}/>
          <div style={{ display: 'flex', gap: 18 }}>
            <div>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Buy-in</div>
              <div className="sp-num" style={{ fontSize: 14, color: 'var(--cream)', marginTop: 2, fontWeight: 600 }}>R$ 50 – 200</div>
            </div>
            <div>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Blinds</div>
              <div className="sp-num" style={{ fontSize: 14, color: 'var(--cream)', marginTop: 2, fontWeight: 600 }}>0,25 / 0,50</div>
            </div>
            <div>
              <div className="sp-ui" style={{ fontSize: 10, color: 'var(--muted)', fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Na mesa</div>
              <div className="sp-num" style={{ fontSize: 14, color: 'var(--cream)', marginTop: 2, fontWeight: 600 }}>4 jogadores</div>
            </div>
          </div>
        </div>

        {/* Buy-in picker */}
        <div style={{ marginTop: 24 }}>
          <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 12 }}>Seu aporte inicial</div>
          <div style={{ textAlign: 'center', padding: '24px 0 18px', background: 'rgba(8,25,15,0.5)', border: '1px solid rgba(245,236,214,0.08)', borderRadius: 16 }}>
            <div className="sp-num" style={{ fontSize: 56, fontWeight: 700, color: 'var(--gold-bright)', lineHeight: 1, letterSpacing: '-0.02em' }}>
              <span style={{ fontSize: 28, verticalAlign: 'top', opacity: 0.7 }}>R$</span> {amount}
            </div>
            <input type="range" min="50" max="200" step="10" value={amount} onChange={e => setAmount(+e.target.value)}
              style={{ width: '80%', marginTop: 16, accentColor: '#d4a24a' }}/>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: 'var(--muted)', width: '80%', margin: '6px auto 0', fontFamily: 'JetBrains Mono' }}>
              <span>R$ 50 (min)</span>
              <span>R$ 200 (max)</span>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
            {[50, 100, 150, 200].map(v => (
              <button key={v} onClick={() => setAmount(v)} style={{
                flex: 1, padding: '10px 0', borderRadius: 10,
                background: amount === v ? 'rgba(212,162,74,0.18)' : 'rgba(8,25,15,0.5)',
                border: amount === v ? '1px solid var(--gold)' : '1px solid rgba(245,236,214,0.1)',
                color: amount === v ? 'var(--gold-bright)' : 'var(--cream)',
                fontSize: 13, fontFamily: 'JetBrains Mono', fontWeight: 600, cursor: 'pointer',
              }}>R$ {v}</button>
            ))}
          </div>
        </div>

        {/* PIX summary */}
        <div style={{
          marginTop: 18, padding: 14,
          background: 'rgba(212,162,74,0.06)',
          border: '1px solid rgba(212,162,74,0.2)',
          borderRadius: 12,
          display: 'flex', gap: 12,
        }}>
          <div style={{ color: 'var(--gold)', flexShrink: 0, marginTop: 2 }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="1.8"/>
              <path d="M12 8v4M12 16h.01" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
            </svg>
          </div>
          <div className="sp-ui" style={{ fontSize: 12, color: 'var(--cream)', lineHeight: 1.5 }}>
            Este valor é apenas seu registro de entrada. Nenhum PIX é enviado agora — acertos acontecem no fim da mesa.
          </div>
        </div>
      </div>

      <div style={{ padding: '14px 24px 32px' }}>
        <button onClick={() => onNav('live')} className="sp-btn-gold" style={{
          width: '100%', height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 16,
        }}>Confirmar entrada · R$ {amount}</button>
      </div>
    </div>
  );
};

// ══════════════════════════════════════════════════════════
// 7. LIVE TABLE — lista de jogadores, totais, rebuy, sair
// ══════════════════════════════════════════════════════════
const ScreenLive = ({ onNav }) => {
  const players = [
    { name: 'Léo Castro', buyin: 200, rebuys: [100], role: 'HOST' },
    { name: 'Rafael Monteiro', buyin: 150, rebuys: [], role: 'VOCÊ' },
    { name: 'Amanda S.', buyin: 100, rebuys: [50, 50] },
    { name: 'Caio Farias', buyin: 200, rebuys: [] },
    { name: 'Bruno T.', buyin: 100, rebuys: [] },
    { name: 'Marina R.', buyin: 150, rebuys: [] },
  ];
  const total = players.reduce((s, p) => s + p.buyin + p.rebuys.reduce((a, b) => a + b, 0), 0);

  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader
        left={<BackArrow onClick={() => onNav('home')}/>}
        title="Sexta na casa do Léo"
        subtitle={<span><span className="sp-live-dot" style={{ display: 'inline-block', marginRight: 6, verticalAlign: 'middle' }}/>ao vivo · 2h 14min</span>}
        right={
          <button style={{ background: 'transparent', border: 'none', color: 'var(--gold-bright)', cursor: 'pointer', padding: 4 }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
          </button>
        }
      />

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '4px 20px 120px' }}>
        {/* Pot summary */}
        <div style={{
          background: 'linear-gradient(135deg, rgba(212,162,74,0.15) 0%, rgba(212,162,74,0.02) 100%)',
          border: '1px solid rgba(212,162,74,0.25)',
          borderRadius: 16, padding: '18px 20px',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ position: 'absolute', right: -20, bottom: -10, opacity: 0.4 }}>
            <PokerChip size={90} color="#d4a24a" count={4}/>
          </div>
          <div>
            <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase' }}>Total em jogo</div>
            <div className="sp-num sp-gold-foil" style={{ fontSize: 34, fontWeight: 800, marginTop: 2, lineHeight: 1 }}>
              {BRL(total)}
            </div>
            <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 4 }}>{players.length} jogadores · 3 rebuys</div>
          </div>
        </div>

        {/* Tabs */}
        <div style={{ display: 'flex', gap: 4, marginTop: 18, padding: 4, background: 'rgba(8,25,15,0.5)', borderRadius: 12 }}>
          {[{ k: 'mesa', label: 'Mesa' }, { k: 'hist', label: 'Histórico' }].map((t, i) => (
            <button key={t.k} style={{
              flex: 1, padding: '9px 0', borderRadius: 8,
              background: i === 0 ? 'rgba(212,162,74,0.2)' : 'transparent',
              border: i === 0 ? '1px solid rgba(212,162,74,0.4)' : '1px solid transparent',
              color: i === 0 ? 'var(--gold-bright)' : 'var(--muted)',
              fontSize: 13, fontFamily: 'Inter', fontWeight: 600, cursor: 'pointer',
            }}>{t.label}</button>
          ))}
        </div>

        {/* Players list */}
        <div style={{ marginTop: 14, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {players.map((p, i) => {
            const tot = p.buyin + p.rebuys.reduce((a, b) => a + b, 0);
            const isYou = p.role === 'VOCÊ';
            return (
              <div key={i} style={{
                padding: '12px 14px', borderRadius: 12,
                background: isYou ? 'rgba(212,162,74,0.1)' : 'rgba(8,25,15,0.45)',
                border: isYou ? '1px solid rgba(212,162,74,0.35)' : '1px solid rgba(245,236,214,0.06)',
                display: 'flex', alignItems: 'center', gap: 12,
              }}>
                <Avatar name={p.name} size={38}/>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <div className="sp-ui" style={{ fontSize: 14, fontWeight: 600, color: 'var(--cream)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.name}</div>
                    {p.role && <div className="sp-ui" style={{
                      fontSize: 9, fontWeight: 700, letterSpacing: '0.1em',
                      padding: '2px 6px', borderRadius: 4,
                      background: p.role === 'HOST' ? 'rgba(212,162,74,0.25)' : 'rgba(46,143,90,0.25)',
                      color: p.role === 'HOST' ? 'var(--gold-bright)' : '#6bc997',
                    }}>{p.role}</div>}
                  </div>
                  <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>
                    Entrou {BRL(p.buyin)}{p.rebuys.length > 0 && ` · ${p.rebuys.length} rebuy${p.rebuys.length > 1 ? 's' : ''} (${BRL(p.rebuys.reduce((a,b)=>a+b,0))})`}
                  </div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div className="sp-num" style={{ fontSize: 16, fontWeight: 700, color: 'var(--cream)' }}>{BRL(tot)}</div>
                  <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold-dark)', letterSpacing: '0.1em', fontWeight: 600, textTransform: 'uppercase', marginTop: 2 }}>Em jogo</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Sticky action bar */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        padding: '14px 20px 34px',
        background: 'linear-gradient(180deg, transparent, rgba(8,25,15,0.95) 35%)',
        display: 'flex', gap: 10,
      }}>
        <button className="sp-btn-ghost" style={{
          flex: 1, height: 48, borderRadius: 12, cursor: 'pointer', fontSize: 14,
        }}>+ Rebuy</button>
        <button onClick={() => onNav('cashout')} className="sp-btn-ghost" style={{
          flex: 1, height: 48, borderRadius: 12, cursor: 'pointer', fontSize: 14,
          color: 'var(--danger-soft)', borderColor: 'rgba(229,115,115,0.4)',
        }}>Sair da mesa</button>
        <button onClick={() => onNav('close')} className="sp-btn-gold" style={{
          flex: 1.2, height: 48, borderRadius: 12, cursor: 'pointer', fontSize: 14,
        }}>Fechar mesa</button>
      </div>
    </div>
  );
};

// ══════════════════════════════════════════════════════════
// 8. CASH OUT — jogador informa saldo de saída
// ══════════════════════════════════════════════════════════
const ScreenCashout = ({ onNav }) => {
  const invested = 150;
  const [stack, setStack] = React.useState(238);
  const pl = stack - invested;
  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader left={<BackArrow onClick={() => onNav('live')}/>} title="Sair da mesa" />

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '8px 24px 20px' }}>
        <div className="sp-display" style={{ fontSize: 22, fontWeight: 700, color: 'var(--cream)', lineHeight: 1.2 }}>
          Com quanto você<br/>está saindo?
        </div>
        <div className="sp-ui" style={{ fontSize: 13, color: 'var(--muted)', marginTop: 6, lineHeight: 1.5 }}>
          Conte suas fichas e informe o valor final. Se estiver zerado, informe R$ 0.
        </div>

        {/* Summary */}
        <div style={{
          marginTop: 20, padding: 16,
          background: 'rgba(8,25,15,0.5)', border: '1px solid rgba(245,236,214,0.08)', borderRadius: 12,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)' }}>Aporte inicial</div>
            <div className="sp-num" style={{ fontSize: 14, color: 'var(--cream)', fontWeight: 600 }}>{BRL(150)}</div>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginTop: 8 }}>
            <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)' }}>Rebuys (0)</div>
            <div className="sp-num" style={{ fontSize: 14, color: 'var(--cream)', fontWeight: 600 }}>{BRL(0)}</div>
          </div>
          <div className="sp-divider-gold" style={{ margin: '12px 0' }}/>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div className="sp-ui" style={{ fontSize: 13, color: 'var(--cream)', fontWeight: 600 }}>Total investido</div>
            <div className="sp-num" style={{ fontSize: 16, color: 'var(--gold-bright)', fontWeight: 700 }}>{BRL(invested)}</div>
          </div>
        </div>

        {/* Stack input */}
        <div style={{ marginTop: 20 }}>
          <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 10 }}>Valor em fichas ao sair</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, background: 'rgba(8,25,15,0.6)', border: '1px solid rgba(212,162,74,0.3)', borderRadius: 14, padding: '20px 18px' }}>
            <span className="sp-num" style={{ fontSize: 22, color: 'var(--muted)', fontWeight: 500 }}>R$</span>
            <input
              type="number"
              value={stack}
              onChange={e => setStack(+e.target.value || 0)}
              className="sp-num"
              style={{
                flex: 1, background: 'transparent', border: 'none', outline: 'none',
                color: 'var(--cream)', fontSize: 48, fontWeight: 700, padding: 0,
                fontFamily: 'JetBrains Mono',
              }}
            />
          </div>

          <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
            <button onClick={() => setStack(0)} style={{
              flex: 1, padding: '10px 0', borderRadius: 10,
              background: 'rgba(192,57,43,0.12)', border: '1px solid rgba(192,57,43,0.3)',
              color: '#e57373', fontSize: 13, fontFamily: 'Inter', fontWeight: 600, cursor: 'pointer',
            }}>Zerado</button>
            <button onClick={() => setStack(invested)} style={{
              flex: 1, padding: '10px 0', borderRadius: 10,
              background: 'rgba(245,236,214,0.08)', border: '1px solid rgba(245,236,214,0.15)',
              color: 'var(--cream)', fontSize: 13, fontFamily: 'Inter', fontWeight: 600, cursor: 'pointer',
            }}>Empate</button>
          </div>
        </div>

        {/* P&L preview */}
        <div style={{
          marginTop: 20, padding: '16px 18px',
          background: pl >= 0 ? 'rgba(46,143,90,0.1)' : 'rgba(192,57,43,0.1)',
          border: pl >= 0 ? '1px solid rgba(46,143,90,0.3)' : '1px solid rgba(192,57,43,0.3)',
          borderRadius: 12,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <div>
            <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold-dark)', fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase' }}>
              {pl >= 0 ? 'Resultado' : 'Resultado'}
            </div>
            <div className="sp-ui" style={{ fontSize: 13, color: 'var(--cream)', marginTop: 2 }}>
              {pl > 0 ? 'Você vai receber' : pl < 0 ? 'Você vai pagar' : 'Empate zero'}
            </div>
          </div>
          <div className="sp-num" style={{
            fontSize: 26, fontWeight: 700,
            color: pl >= 0 ? '#6bc997' : '#e57373',
          }}>{pl >= 0 ? '+' : ''}{BRL(pl)}</div>
        </div>
      </div>

      <div style={{ padding: '14px 24px 32px' }}>
        <button onClick={() => onNav('live')} className="sp-btn-gold" style={{
          width: '100%', height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 16,
        }}>Confirmar saída</button>
      </div>
    </div>
  );
};

Object.assign(window, { ScreenJoin, ScreenLive, ScreenCashout });
