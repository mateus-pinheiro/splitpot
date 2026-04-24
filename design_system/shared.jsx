// Splitpot — Shared primitives (icons, chips, status bar, buttons)

// ──────────────────────────────────────────────
// Suit glyphs (playing cards)
// ──────────────────────────────────────────────
const Suit = ({ suit, size = 16, color }) => {
  const c = color || (suit === 'h' || suit === 'd' ? '#c0392b' : '#111');
  const paths = {
    s: 'M12 2C12 2 4 9 4 14C4 17 6 19 9 19C10.5 19 11.5 18.3 12 17.5C12.5 18.3 13.5 19 15 19C18 19 20 17 20 14C20 9 12 2 12 2Z M12 17L10 22H14L12 17Z',
    h: 'M12 21C12 21 3 14.5 3 8.5C3 5.5 5 3.5 7.5 3.5C9.5 3.5 11 5 12 6.5C13 5 14.5 3.5 16.5 3.5C19 3.5 21 5.5 21 8.5C21 14.5 12 21 12 21Z',
    d: 'M12 2L20 12L12 22L4 12Z',
    c: 'M12 2C10 2 8 4 8 6C8 7 8.3 7.8 8.8 8.4C7 8 5 9.5 5 12C5 14 7 15.5 9 15.5C10 15.5 11 15 11.5 14.4C11 15.5 10 17 10 18H14C14 17 13 15.5 12.5 14.4C13 15 14 15.5 15 15.5C17 15.5 19 14 19 12C19 9.5 17 8 15.2 8.4C15.7 7.8 16 7 16 6C16 4 14 2 12 2Z M11 17L10 22H14L13 17Z',
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'inline-block', verticalAlign: 'middle' }}>
      <path d={paths[suit]} fill={c} />
    </svg>
  );
};

// Tiny inline suit for logo
const SuitRow = ({ size = 14, gap = 3 }) => (
  <span style={{ display: 'inline-flex', gap, alignItems: 'center' }}>
    <Suit suit="s" size={size} />
    <Suit suit="h" size={size} />
    <Suit suit="d" size={size} />
    <Suit suit="c" size={size} />
  </span>
);

// ──────────────────────────────────────────────
// Poker chip (SVG, stacks)
// ──────────────────────────────────────────────
const PokerChip = ({ size = 36, color = '#c0392b', count = 1, tilt = false }) => {
  const rim = color;
  const face = '#f5ecd6';
  const wedge = color;
  return (
    <div style={{ position: 'relative', width: size, height: size * 0.9, transform: tilt ? 'rotate(-8deg)' : undefined }}>
      {Array.from({ length: count }).map((_, i) => (
        <svg key={i} width={size} height={size} viewBox="0 0 40 40"
             style={{ position: 'absolute', left: 0, top: i * -3 }}>
          <defs>
            <radialGradient id={`rimG-${color}-${i}`}>
              <stop offset="0%" stopColor={rim}/>
              <stop offset="100%" stopColor={rim} stopOpacity="0.7"/>
            </radialGradient>
          </defs>
          <circle cx="20" cy="20" r="19" fill={rim} stroke="#000" strokeOpacity="0.15" strokeWidth="0.5"/>
          {/* wedges */}
          {[0, 45, 90, 135, 180, 225, 270, 315].map(a => (
            <rect key={a} x="19" y="1" width="2" height="6" fill={face}
                  transform={`rotate(${a} 20 20)`} />
          ))}
          <circle cx="20" cy="20" r="13" fill={face}/>
          <circle cx="20" cy="20" r="13" fill="none" stroke={wedge} strokeOpacity="0.3" strokeWidth="0.5" strokeDasharray="1.5 1.5"/>
          <circle cx="20" cy="20" r="9" fill="none" stroke={wedge} strokeWidth="1"/>
        </svg>
      ))}
    </div>
  );
};

// ──────────────────────────────────────────────
// Splitpot logo
// ──────────────────────────────────────────────
const Logo = ({ size = 22, color = '#f0c770' }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
    <svg width={size * 1.3} height={size * 1.3} viewBox="0 0 32 32">
      {/* chip with split motif */}
      <circle cx="16" cy="16" r="14" fill={color}/>
      <circle cx="16" cy="16" r="14" fill="none" stroke="#2a1d08" strokeWidth="1" strokeOpacity="0.3"/>
      {[0, 60, 120, 180, 240, 300].map(a => (
        <rect key={a} x="15" y="2" width="2" height="4" fill="#2a1d08" opacity="0.5"
              transform={`rotate(${a} 16 16)`} />
      ))}
      <circle cx="16" cy="16" r="8" fill="#0f3a24"/>
      <path d="M12 16 L20 16 M16 12 L16 20" stroke={color} strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
    <span className="sp-display" style={{
      fontSize: size, fontWeight: 700, color: color,
      letterSpacing: '-0.01em',
    }}>
      Splitpot
    </span>
  </div>
);

// ──────────────────────────────────────────────
// Status bar (simplified iOS)
// ──────────────────────────────────────────────
const StatusBar = ({ dark = true }) => {
  const c = dark ? '#f5ecd6' : '#000';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '14px 24px 6px', height: 44, boxSizing: 'border-box',
      fontFamily: '-apple-system, system-ui', fontWeight: 600, fontSize: 15,
      color: c, position: 'relative', zIndex: 10,
    }}>
      <span>9:41</span>
      <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
        <svg width="17" height="11" viewBox="0 0 17 11"><path d="M8.5 2.5C10.5 2.5 12.3 3.3 13.7 4.6L14.8 3.5C13.1 1.9 10.9 1 8.5 1C6.1 1 3.9 1.9 2.2 3.5L3.3 4.6C4.7 3.3 6.5 2.5 8.5 2.5Z M8.5 5.5C9.7 5.5 10.8 6 11.6 6.8L12.7 5.7C11.6 4.6 10.1 4 8.5 4C6.9 4 5.4 4.6 4.3 5.7L5.4 6.8C6.2 6 7.3 5.5 8.5 5.5Z" fill={c}/><circle cx="8.5" cy="9" r="1.3" fill={c}/></svg>
        <svg width="25" height="11" viewBox="0 0 25 11"><rect x="0.5" y="0.5" width="21" height="10" rx="2.5" stroke={c} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="18" height="7" rx="1.5" fill={c}/><path d="M23 3.5V7.5C23.6 7.3 24 6.5 24 6C24 5.5 23.6 4.7 23 4.5Z" fill={c} fillOpacity="0.5"/></svg>
      </div>
    </div>
  );
};

// ──────────────────────────────────────────────
// Home indicator
// ──────────────────────────────────────────────
const HomeIndicator = ({ dark = true }) => (
  <div style={{
    position: 'absolute', bottom: 0, left: 0, right: 0,
    height: 28, display: 'flex', justifyContent: 'center', alignItems: 'flex-end',
    paddingBottom: 7, pointerEvents: 'none', zIndex: 60,
  }}>
    <div style={{
      width: 120, height: 4, borderRadius: 100,
      background: dark ? 'rgba(245,236,214,0.55)' : 'rgba(0,0,0,0.28)',
    }} />
  </div>
);

// ──────────────────────────────────────────────
// Phone frame (mobile-first web viewport)
// ──────────────────────────────────────────────
const Phone = ({ children, bg = 'var(--felt-deep)', width = 390, height = 780 }) => (
  <div style={{
    width, height,
    borderRadius: 46,
    overflow: 'hidden',
    position: 'relative',
    background: bg,
    boxShadow: '0 30px 70px rgba(0,0,0,0.35), 0 0 0 2px #111, 0 0 0 10px #1a1a1a, 0 0 0 11px #2a2a2a',
    fontFamily: 'Inter, -apple-system, system-ui, sans-serif',
    WebkitFontSmoothing: 'antialiased',
    color: 'var(--cream)',
    isolation: 'isolate',
  }}>
    {/* dynamic island */}
    <div style={{
      position: 'absolute', top: 10, left: '50%', transform: 'translateX(-50%)',
      width: 110, height: 32, borderRadius: 20, background: '#000', zIndex: 50,
    }} />
    {children}
    <HomeIndicator dark />
  </div>
);

// ──────────────────────────────────────────────
// App header (after status bar)
// ──────────────────────────────────────────────
const AppHeader = ({ left, title, right, subtitle, transparent = false }) => (
  <div style={{
    padding: '6px 20px 14px',
    display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between',
    gap: 12,
    background: transparent ? 'transparent' : undefined,
  }}>
    <div style={{ minWidth: 32, display: 'flex', alignItems: 'center' }}>{left}</div>
    <div style={{ flex: 1, textAlign: 'center' }}>
      {title && <div className="sp-display" style={{ fontSize: 18, fontWeight: 600, color: 'var(--cream)' }}>{title}</div>}
      {subtitle && <div className="sp-ui" style={{ fontSize: 11, color: 'var(--muted)', marginTop: 2, letterSpacing: '0.05em', textTransform: 'uppercase' }}>{subtitle}</div>}
    </div>
    <div style={{ minWidth: 32, display: 'flex', alignItems: 'center', justifyContent: 'flex-end' }}>{right}</div>
  </div>
);

// ──────────────────────────────────────────────
// Money formatter
// ──────────────────────────────────────────────
const BRL = (n) => {
  const s = Math.abs(n).toLocaleString('pt-BR', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
  return (n < 0 ? '-' : '') + 'R$\u00A0' + s;
};

// ──────────────────────────────────────────────
// Avatar (initials circle)
// ──────────────────────────────────────────────
const Avatar = ({ name, size = 36, bg }) => {
  const initials = name.split(' ').map(s => s[0]).slice(0, 2).join('').toUpperCase();
  // deterministic color from name
  const palette = ['#c0392b', '#2e8f5a', '#2c6ba8', '#a44b8e', '#b8822b', '#486a8a'];
  const c = bg || palette[name.charCodeAt(0) % palette.length];
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: c,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#fbf6e8', fontWeight: 700, fontSize: size * 0.38,
      fontFamily: 'Inter, sans-serif',
      boxShadow: '0 1px 3px rgba(0,0,0,0.3), inset 0 1px 0 rgba(255,255,255,0.15)',
      flexShrink: 0,
    }}>{initials}</div>
  );
};

// ──────────────────────────────────────────────
// Back arrow
// ──────────────────────────────────────────────
const BackArrow = ({ onClick }) => (
  <button onClick={onClick} style={{
    background: 'transparent', border: 'none', padding: 6, cursor: 'pointer',
    color: 'var(--gold-bright)', display: 'flex',
  }}>
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  </button>
);

// Export to window
Object.assign(window, { Suit, SuitRow, PokerChip, Logo, StatusBar, HomeIndicator, Phone, AppHeader, BRL, Avatar, BackArrow });
