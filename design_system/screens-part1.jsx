// Splitpot — Screens part 1: Login, Onboarding, Home, Create Table, QR Share

// ══════════════════════════════════════════════════════════
// 1. LOGIN — Google / Apple
// ══════════════════════════════════════════════════════════
const ScreenLogin = ({ onNav }) => (
  <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
    <StatusBar dark />
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 32px' }}>
      {/* hero */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', gap: 28 }}>
        {/* big stacked chips */}
        <div style={{ position: 'relative', height: 130, width: 130 }}>
          <div style={{ position: 'absolute', left: 0, top: 35 }}>
            <PokerChip size={72} color="#c0392b" count={4}/>
          </div>
          <div style={{ position: 'absolute', right: 0, top: 20 }}>
            <PokerChip size={72} color="#1f3f6b" count={5}/>
          </div>
          <div style={{ position: 'absolute', left: 30, top: 0 }}>
            <PokerChip size={72} color="#2a2a2a" count={3}/>
          </div>
        </div>

        <div style={{ textAlign: 'center' }}>
          <div className="sp-display sp-gold-foil" style={{ fontSize: 52, fontWeight: 800, lineHeight: 1, letterSpacing: '-0.02em' }}>
            Splitpot
          </div>
          <div style={{ marginTop: 10, display: 'flex', justifyContent: 'center', gap: 10, opacity: 0.75 }}>
            <Suit suit="s" size={14}/>
            <Suit suit="h" size={14}/>
            <Suit suit="d" size={14}/>
            <Suit suit="c" size={14}/>
          </div>
          <div className="sp-ui" style={{ marginTop: 16, color: 'var(--cream)', fontSize: 15, opacity: 0.8, fontWeight: 400, lineHeight: 1.5 }}>
            Caixa transparente<br/>para seu home game
          </div>
        </div>
      </div>

      {/* auth buttons */}
      <div style={{ paddingBottom: 40, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <button onClick={() => onNav('onboarding')} style={{
          height: 52, borderRadius: 12,
          background: '#000', color: '#fff',
          border: '1px solid rgba(255,255,255,0.15)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          fontFamily: 'Inter', fontWeight: 600, fontSize: 16, cursor: 'pointer',
        }}>
          <svg width="18" height="20" viewBox="0 0 18 20" fill="#fff">
            <path d="M14.7 10.6c0-2.3 1.9-3.4 2-3.5-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.2-2.8.9-3.5.9-.7 0-1.9-.8-3-.8-1.6 0-3 .9-3.8 2.3-1.6 2.8-.4 7 1.2 9.3.8 1.1 1.7 2.3 2.9 2.3 1.2-.1 1.6-.8 3-.8 1.4 0 1.8.8 3 .7 1.2 0 2-1.1 2.8-2.3.9-1.3 1.2-2.6 1.3-2.7-.1-.1-2.5-1-2.5-3.6z M12.6 3.7c.6-.8 1.1-1.9 1-3-1 0-2.1.7-2.8 1.5-.6.7-1.1 1.8-1 2.9 1.1.1 2.2-.6 2.8-1.4z"/>
          </svg>
          Continue with Apple
        </button>
        <button onClick={() => onNav('onboarding')} style={{
          height: 52, borderRadius: 12,
          background: 'var(--cream)', color: '#222',
          border: '1px solid rgba(255,255,255,0.3)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          fontFamily: 'Inter', fontWeight: 600, fontSize: 16, cursor: 'pointer',
        }}>
          <svg width="18" height="18" viewBox="0 0 18 18">
            <path fill="#4285F4" d="M17.64 9.2c0-.64-.06-1.25-.17-1.84H9v3.48h4.84c-.21 1.12-.84 2.07-1.79 2.71v2.26h2.9c1.7-1.57 2.69-3.88 2.69-6.61z"/>
            <path fill="#34A853" d="M9 18c2.43 0 4.47-.81 5.96-2.19l-2.9-2.26c-.81.54-1.83.87-3.06.87-2.35 0-4.35-1.59-5.06-3.72H.96v2.34C2.44 15.98 5.48 18 9 18z"/>
            <path fill="#FBBC05" d="M3.94 10.7c-.18-.54-.28-1.12-.28-1.7s.1-1.16.28-1.7V4.96H.96C.35 6.17 0 7.55 0 9s.35 2.83.96 4.04l2.98-2.34z"/>
            <path fill="#EA4335" d="M9 3.58c1.32 0 2.51.45 3.44 1.35l2.58-2.58C13.46.89 11.43 0 9 0 5.48 0 2.44 2.02.96 4.96l2.98 2.34C4.65 5.17 6.65 3.58 9 3.58z"/>
          </svg>
          Continue with Google
        </button>

        <div className="sp-ui" style={{ textAlign: 'center', color: 'var(--muted)', fontSize: 11, marginTop: 8, lineHeight: 1.5 }}>
          Ao continuar, você concorda com os<br/>
          <span style={{ color: 'var(--gold)' }}>Termos</span> e <span style={{ color: 'var(--gold)' }}>Política de Privacidade</span>
        </div>
      </div>
    </div>
  </div>
);

// ══════════════════════════════════════════════════════════
// 2. ONBOARDING — nome, pix (email já veio do Google)
// ══════════════════════════════════════════════════════════
const ScreenOnboarding = ({ onNav }) => (
  <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
    <StatusBar dark />
    <AppHeader left={<BackArrow onClick={() => onNav('login')}/>} title="" />

    <div style={{ flex: 1, padding: '8px 24px', display: 'flex', flexDirection: 'column' }}>
      <div className="sp-display" style={{ fontSize: 28, fontWeight: 700, color: 'var(--cream)', lineHeight: 1.15 }}>
        Complete seu<br/>perfil
      </div>
      <div className="sp-ui" style={{ fontSize: 14, color: 'var(--muted)', marginTop: 8, lineHeight: 1.5 }}>
        Essas informações aparecem quando você entra em uma mesa.
      </div>

      <div style={{ marginTop: 28, display: 'flex', flexDirection: 'column', gap: 18 }}>
        <div>
          <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 8 }}>Nome</div>
          <input className="sp-input" defaultValue="Rafael Monteiro" />
        </div>
        <div>
          <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 8 }}>Email</div>
          <input className="sp-input" defaultValue="rafa.monteiro@gmail.com" style={{ opacity: 0.7 }} disabled />
        </div>
        <div>
          <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 8 }}>Chave PIX</div>
          <input className="sp-input" placeholder="CPF, telefone, email ou aleatória" defaultValue="rafa.monteiro@gmail.com" />
          <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 6, lineHeight: 1.4 }}>
            Usada apenas para receber acertos ao fim da mesa.
          </div>
        </div>
      </div>
    </div>

    <div style={{ padding: '16px 24px 32px' }}>
      <button onClick={() => onNav('home')} className="sp-btn-gold" style={{
        width: '100%', height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 16,
      }}>Entrar no Splitpot</button>
    </div>
  </div>
);

// ══════════════════════════════════════════════════════════
// 3. HOME — criar ou entrar em mesa + histórico
// ══════════════════════════════════════════════════════════
const ScreenHome = ({ onNav }) => (
  <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
    <StatusBar dark />
    <AppHeader
      left={<Avatar name="Rafael Monteiro" size={32}/>}
      title={<Logo size={18}/>}
      right={
        <button style={{ background: 'transparent', border: 'none', color: 'var(--gold-bright)', cursor: 'pointer', padding: 4 }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
            <path d="M15 17h5l-1.4-1.4A2 2 0 0118 14.2V11a6 6 0 00-5-5.9V4a1 1 0 10-2 0v1.1A6 6 0 006 11v3.2c0 .5-.2 1-.6 1.4L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" stroke="currentColor" strokeWidth="1.6"/>
          </svg>
        </button>
      }
    />

    <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '4px 20px 40px' }}>
      {/* hero CTA */}
      <div style={{
        background: 'linear-gradient(135deg, rgba(212,162,74,0.18), rgba(212,162,74,0.04))',
        border: '1px solid rgba(212,162,74,0.3)',
        borderRadius: 20, padding: '22px 20px',
        position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', right: -10, top: -10, opacity: 0.3 }}>
          <PokerChip size={90} color="#d4a24a" count={3}/>
        </div>
        <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase' }}>
          Começar agora
        </div>
        <div className="sp-display" style={{ fontSize: 22, fontWeight: 700, color: 'var(--cream)', marginTop: 4, lineHeight: 1.2 }}>
          Nova mesa<br/>de cash game
        </div>
        <div className="sp-ui" style={{ fontSize: 13, color: 'var(--muted)', marginTop: 8, lineHeight: 1.5, maxWidth: 220 }}>
          Crie uma mesa, compartilhe o QR e deixe o app cuidar do caixa.
        </div>
        <button onClick={() => onNav('create')} className="sp-btn-gold" style={{
          marginTop: 16, height: 42, padding: '0 18px', borderRadius: 10,
          fontSize: 14, cursor: 'pointer',
          display: 'inline-flex', alignItems: 'center', gap: 8,
        }}>
          Criar mesa
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <path d="M5 12h14M13 5l7 7-7 7" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
      </div>

      {/* Join via code */}
      <div style={{ marginTop: 14 }}>
        <button onClick={() => onNav('join')} style={{
          width: '100%', padding: '16px 18px', borderRadius: 14,
          background: 'rgba(8,25,15,0.55)',
          border: '1px solid rgba(245,236,214,0.1)',
          display: 'flex', alignItems: 'center', gap: 14,
          cursor: 'pointer', textAlign: 'left',
        }}>
          <div style={{
            width: 38, height: 38, borderRadius: 10, flexShrink: 0,
            background: 'rgba(212,162,74,0.15)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: 'var(--gold-bright)',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <rect x="3" y="3" width="7" height="7" rx="1" stroke="currentColor" strokeWidth="1.8"/>
              <rect x="14" y="3" width="7" height="7" rx="1" stroke="currentColor" strokeWidth="1.8"/>
              <rect x="3" y="14" width="7" height="7" rx="1" stroke="currentColor" strokeWidth="1.8"/>
              <path d="M14 14h3v3h-3zM20 14h1v1h-1zM14 20h1v1h-1zM18 18h3v3h-3z" fill="currentColor"/>
            </svg>
          </div>
          <div style={{ flex: 1 }}>
            <div className="sp-ui" style={{ color: 'var(--cream)', fontSize: 15, fontWeight: 600 }}>Entrar com código</div>
            <div className="sp-ui" style={{ color: 'var(--muted)', fontSize: 12, marginTop: 2 }}>Escaneie o QR ou digite o ID</div>
          </div>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" style={{ color: 'var(--muted)' }}>
            <path d="M9 5l7 7-7 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
      </div>

      {/* Stats */}
      <div style={{ marginTop: 28, display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '0 4px' }}>
        <div className="sp-display" style={{ fontSize: 18, fontWeight: 700, color: 'var(--cream)' }}>Suas estatísticas</div>
        <button onClick={() => onNav('history')} style={{ background: 'transparent', border: 'none', color: 'var(--gold)', fontSize: 12, fontFamily: 'Inter', fontWeight: 600, cursor: 'pointer' }}>Ver tudo</button>
      </div>

      <div style={{ marginTop: 12, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <div className="sp-card" style={{ padding: 14 }}>
          <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold-dark)', fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase' }}>P&L total</div>
          <div className="sp-num" style={{ fontSize: 22, fontWeight: 700, color: 'var(--success)', marginTop: 4 }}>+R$ 842</div>
          <div className="sp-ui" style={{ fontSize: 11, color: '#888', marginTop: 2 }}>em 12 mesas</div>
        </div>
        <div className="sp-card" style={{ padding: 14 }}>
          <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold-dark)', fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase' }}>Taxa de vitória</div>
          <div className="sp-num" style={{ fontSize: 22, fontWeight: 700, color: '#222', marginTop: 4 }}>58%</div>
          <div className="sp-ui" style={{ fontSize: 11, color: '#888', marginTop: 2 }}>7 de 12 mesas</div>
        </div>
      </div>

      {/* Recent */}
      <div style={{ marginTop: 28 }}>
        <div className="sp-display" style={{ fontSize: 18, fontWeight: 700, color: 'var(--cream)', padding: '0 4px', marginBottom: 12 }}>Mesas recentes</div>
        {[
          { date: 'Ontem', name: 'Sexta na casa do Léo', players: 7, pl: 340, host: false },
          { date: '12 abr', name: 'Mesa do escritório', players: 5, pl: -120, host: false },
          { date: '05 abr', name: 'Aniversário do Caio', players: 6, pl: 622, host: true },
        ].map((t, i) => (
          <button key={i} onClick={() => onNav('detail')} style={{
            width: '100%', marginBottom: 8, padding: '14px 16px', borderRadius: 12,
            background: 'rgba(8,25,15,0.45)',
            border: '1px solid rgba(245,236,214,0.08)',
            display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer', textAlign: 'left',
          }}>
            <div style={{
              width: 44, height: 44, borderRadius: 8, flexShrink: 0,
              background: 'rgba(212,162,74,0.12)',
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
              border: '1px solid rgba(212,162,74,0.2)',
            }}>
              <div className="sp-ui" style={{ fontSize: 9, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase' }}>{t.date.split(' ')[1] || t.date.slice(0,3)}</div>
              {t.date.split(' ')[0] && <div className="sp-display" style={{ fontSize: 15, fontWeight: 700, color: 'var(--cream)', lineHeight: 1 }}>{t.date.split(' ')[0]}</div>}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div className="sp-ui" style={{ color: 'var(--cream)', fontSize: 14, fontWeight: 600, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                {t.name} {t.host && <span style={{ color: 'var(--gold)', fontSize: 10, fontWeight: 700, letterSpacing: '0.1em', marginLeft: 4 }}>· HOST</span>}
              </div>
              <div className="sp-ui" style={{ color: 'var(--muted)', fontSize: 12, marginTop: 2 }}>{t.players} jogadores</div>
            </div>
            <div className="sp-num" style={{ fontSize: 15, fontWeight: 700, color: t.pl >= 0 ? 'var(--success)' : 'var(--danger-soft)' }}>
              {t.pl >= 0 ? '+' : ''}{BRL(t.pl)}
            </div>
          </button>
        ))}
      </div>
    </div>
  </div>
);

// ══════════════════════════════════════════════════════════
// 4. CREATE TABLE — nome, buy-in min/max, moeda
// ══════════════════════════════════════════════════════════
const ScreenCreate = ({ onNav }) => {
  const [min, setMin] = React.useState(50);
  const [max, setMax] = React.useState(200);
  const [name, setName] = React.useState('Sexta na casa do Léo');
  return (
    <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <StatusBar dark />
      <AppHeader left={<BackArrow onClick={() => onNav('home')}/>} title="Nova mesa" />

      <div className="sp-scroll" style={{ flex: 1, overflow: 'auto', padding: '8px 24px 20px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
          <div>
            <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 8 }}>Nome da mesa</div>
            <input className="sp-input" value={name} onChange={e => setName(e.target.value)} />
          </div>

          <div>
            <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 10 }}>Buy-in (R$)</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <div style={{ position: 'relative' }}>
                <div className="sp-ui" style={{ position: 'absolute', left: 12, top: 6, fontSize: 10, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>Mínimo</div>
                <input className="sp-input sp-num" value={min} onChange={e => setMin(+e.target.value||0)} style={{ paddingTop: 22, paddingBottom: 8, fontSize: 22, fontWeight: 700 }} />
              </div>
              <div style={{ position: 'relative' }}>
                <div className="sp-ui" style={{ position: 'absolute', left: 12, top: 6, fontSize: 10, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>Máximo</div>
                <input className="sp-input sp-num" value={max} onChange={e => setMax(+e.target.value||0)} style={{ paddingTop: 22, paddingBottom: 8, fontSize: 22, fontWeight: 700 }} />
              </div>
            </div>
            <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 8, lineHeight: 1.4 }}>
              Jogadores podem aportar qualquer valor entre <span style={{ color: 'var(--cream)' }}>R$ {min}</span> e <span style={{ color: 'var(--cream)' }}>R$ {max}</span>. Rebuys são permitidos.
            </div>
          </div>

          <div>
            <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 10 }}>Valor da ficha (small blind)</div>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {['0,25', '0,50', '1,00', '2,00', '5,00'].map((v, i) => (
                <button key={v} style={{
                  padding: '10px 14px', borderRadius: 10,
                  background: i === 1 ? 'rgba(212,162,74,0.18)' : 'rgba(8,25,15,0.5)',
                  border: i === 1 ? '1px solid var(--gold)' : '1px solid rgba(245,236,214,0.12)',
                  color: i === 1 ? 'var(--gold-bright)' : 'var(--cream)',
                  fontSize: 13, fontFamily: 'JetBrains Mono', fontWeight: 600, cursor: 'pointer',
                }}>R$ {v}</button>
              ))}
            </div>
          </div>

          <div style={{ background: 'rgba(8,25,15,0.5)', border: '1px solid rgba(245,236,214,0.08)', borderRadius: 12, padding: 16 }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div>
                <div className="sp-ui" style={{ fontSize: 14, fontWeight: 600, color: 'var(--cream)' }}>Você também vai jogar</div>
                <div className="sp-ui" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>Entra na mesa como jogador</div>
              </div>
              <div style={{
                width: 48, height: 28, borderRadius: 14, background: 'var(--gold)',
                position: 'relative', cursor: 'pointer',
              }}>
                <div style={{ position: 'absolute', right: 3, top: 3, width: 22, height: 22, borderRadius: '50%', background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.3)' }}/>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div style={{ padding: '16px 24px 32px', background: 'linear-gradient(180deg, transparent, rgba(8,25,15,0.9) 40%)' }}>
        <button onClick={() => onNav('qr')} className="sp-btn-gold" style={{
          width: '100%', height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 16,
        }}>Abrir mesa</button>
      </div>
    </div>
  );
};

// ══════════════════════════════════════════════════════════
// 5. QR SHARE — mesa recém-criada, host mostra para convidados
// ══════════════════════════════════════════════════════════
const QRPattern = ({ size = 200 }) => {
  // Deterministic QR-ish pattern
  const cells = 25;
  const s = size / cells;
  const rand = (x, y) => (Math.sin(x * 12.9898 + y * 78.233) * 43758.5453) % 1;
  const isFinder = (x, y) =>
    (x < 7 && y < 7) || (x > cells - 8 && y < 7) || (x < 7 && y > cells - 8);
  const finderFill = (x, y, ox, oy) => {
    const lx = x - ox, ly = y - oy;
    if (lx < 0 || lx > 6 || ly < 0 || ly > 6) return false;
    if (lx === 0 || lx === 6 || ly === 0 || ly === 6) return true;
    if (lx >= 2 && lx <= 4 && ly >= 2 && ly <= 4) return true;
    return false;
  };
  const fill = (x, y) => {
    if (isFinder(x, y)) {
      return finderFill(x, y, 0, 0) || finderFill(x, y, cells - 7, 0) || finderFill(x, y, 0, cells - 7);
    }
    return Math.abs(rand(x, y)) > 0.55;
  };
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ display: 'block' }}>
      <rect width={size} height={size} fill="#fbf6e8"/>
      {Array.from({ length: cells }).map((_, y) =>
        Array.from({ length: cells }).map((_, x) =>
          fill(x, y) ? <rect key={`${x}-${y}`} x={x * s} y={y * s} width={s} height={s} fill="#0a2518"/> : null
        )
      )}
      {/* center chip logo */}
      <g transform={`translate(${size/2 - 16}, ${size/2 - 16})`}>
        <rect x="-4" y="-4" width="40" height="40" fill="#fbf6e8"/>
        <circle cx="16" cy="16" r="14" fill="#d4a24a"/>
        <circle cx="16" cy="16" r="8" fill="#0f3a24"/>
        <path d="M12 16 L20 16 M16 12 L16 20" stroke="#f0c770" strokeWidth="1.8" strokeLinecap="round"/>
      </g>
    </svg>
  );
};

const ScreenQR = ({ onNav }) => (
  <div className="sp-felt" style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column' }}>
    <StatusBar dark />
    <AppHeader
      left={<BackArrow onClick={() => onNav('create')}/>}
      title="Convidar jogadores"
      right={
        <button onClick={() => onNav('live')} style={{ background: 'transparent', border: 'none', color: 'var(--gold-bright)', fontFamily: 'Inter', fontWeight: 600, fontSize: 14, cursor: 'pointer' }}>Pular</button>
      }
    />

    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 24px', overflow: 'auto' }} className="sp-scroll">
      <div className="sp-display" style={{ fontSize: 22, fontWeight: 700, color: 'var(--cream)', textAlign: 'center', lineHeight: 1.2 }}>
        Sexta na casa do Léo
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', gap: 14, marginTop: 8, fontSize: 12, color: 'var(--muted)', fontFamily: 'Inter', fontWeight: 500 }}>
        <span>Buy-in R$ 50 – 200</span>
        <span style={{ color: 'var(--gold-dark)' }}>•</span>
        <span>Blinds 0,25 / 0,50</span>
      </div>

      {/* QR card */}
      <div style={{
        marginTop: 20,
        background: 'var(--ivory)',
        borderRadius: 20,
        padding: 20,
        position: 'relative',
        boxShadow: '0 20px 50px rgba(0,0,0,0.4), inset 0 0 0 4px var(--gold)',
      }}>
        {/* corner flourishes */}
        {[['tl', 0, 0], ['tr', 1, 0], ['bl', 0, 1], ['br', 1, 1]].map(([k, x, y]) => (
          <svg key={k} width="20" height="20" viewBox="0 0 20 20" style={{
            position: 'absolute', [x ? 'right' : 'left']: 8, [y ? 'bottom' : 'top']: 8,
            transform: `scale(${x ? -1 : 1}, ${y ? -1 : 1})`,
          }}>
            <path d="M2 8 L2 2 L8 2 M2 2 L18 2" stroke="#d4a24a" strokeWidth="1.5" fill="none"/>
          </svg>
        ))}
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <QRPattern size={220}/>
        </div>
        <div style={{ marginTop: 14, textAlign: 'center' }}>
          <div className="sp-ui" style={{ fontSize: 10, color: 'var(--gold-dark)', fontWeight: 700, letterSpacing: '0.2em', textTransform: 'uppercase' }}>Código da mesa</div>
          <div className="sp-num" style={{ fontSize: 28, fontWeight: 700, color: 'var(--felt-deep)', letterSpacing: '0.15em', marginTop: 2 }}>K7N-2QX</div>
        </div>
      </div>

      {/* share row */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, marginTop: 18 }}>
        {[
          { label: 'WhatsApp', c: '#25D366', icon: <path d="M12 2A10 10 0 002 12a10 10 0 001.5 5.3L2 22l4.8-1.4A10 10 0 0022 12 10 10 0 0012 2m4.1 14c-.2.6-1 1-1.6 1.1-.4 0-.9.1-1.5 0-.4-.1-.8-.2-1.4-.4-2.5-1-4.1-3.5-4.2-3.7-.1-.1-1-1.3-1-2.5s.6-1.8.8-2.1c.2-.2.4-.3.6-.3h.4c.1 0 .3 0 .5.4l.7 1.6c0 .1.1.2 0 .4l-.3.3-.3.3c-.1.1-.2.2-.1.4.1.2.6.9 1.2 1.5.8.7 1.5 1 1.7 1.1.2.1.3 0 .4-.1l.5-.6c.1-.2.3-.2.4-.1l1.5.8c.3.1.4.2.4.3.1.2.1.7-.1 1.3"/> },
          { label: 'Copiar link', c: '#d4a24a', icon: <path d="M10 13a5 5 0 007.5.5l3-3a5 5 0 00-7-7l-1.7 1.7M14 11a5 5 0 00-7.5-.5l-3 3a5 5 0 007 7l1.7-1.7" stroke="currentColor" strokeWidth="1.8" fill="none" strokeLinecap="round"/> },
          { label: 'Compartilhar', c: '#aaa', icon: <path d="M12 3v13m0-13l-4 4m4-4l4 4M5 15v4a2 2 0 002 2h10a2 2 0 002-2v-4" stroke="currentColor" strokeWidth="1.8" fill="none" strokeLinecap="round" strokeLinejoin="round"/> },
        ].map((s) => (
          <button key={s.label} style={{
            padding: '12px 8px', borderRadius: 12,
            background: 'rgba(8,25,15,0.5)',
            border: '1px solid rgba(245,236,214,0.1)',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
            cursor: 'pointer', color: 'var(--cream)', fontFamily: 'Inter', fontSize: 12, fontWeight: 500,
          }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill={s.c === '#25D366' ? s.c : 'none'} style={{ color: s.c }}>{s.icon}</svg>
            {s.label}
          </button>
        ))}
      </div>

      {/* waiting list preview */}
      <div style={{ marginTop: 20, padding: '14px 16px', background: 'rgba(8,25,15,0.5)', borderRadius: 12, border: '1px solid rgba(245,236,214,0.08)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
          <div className="sp-live-dot"/>
          <div className="sp-ui" style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase' }}>Aguardando · 2 entraram</div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: -8 }}>
          {['Rafael Monteiro', 'Léo Castro', 'Amanda S.'].map((n, i) => (
            <div key={n} style={{ marginLeft: i === 0 ? 0 : -8 }}>
              <Avatar name={n} size={32}/>
            </div>
          ))}
          <div style={{ marginLeft: 10, fontSize: 12, color: 'var(--muted)', fontFamily: 'Inter' }}>Você + 2</div>
        </div>
      </div>
    </div>

    <div style={{ padding: '14px 24px 28px' }}>
      <button onClick={() => onNav('live')} className="sp-btn-gold" style={{
        width: '100%', height: 52, borderRadius: 12, cursor: 'pointer', fontSize: 16,
      }}>Iniciar jogo</button>
    </div>
  </div>
);

Object.assign(window, { ScreenLogin, ScreenOnboarding, ScreenHome, ScreenCreate, ScreenQR, QRPattern });
