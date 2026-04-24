# Handoff: Splitpot — Poker Cash Game Split App

## Overview

**Splitpot** is a mobile-first web app (Flutter target) that solves cash-flow management for in-person Texas Hold'em home games. It works like Splitwise but for poker: the host creates a table, players scan a QR code to join with a buy-in, rebuys are tracked during the game, and when the table closes, an optimized P2P settlement algorithm minimizes the number of PIX transfers needed.

**Target stack (per user):** Flutter Web, initially.

## About the Design Files

The files in this bundle are **design references created in HTML/React**. They are **prototypes** showing intended look, hierarchy, typography, spacing, color, and interaction flow — **not production code to copy directly**.

Your job: **recreate these designs in Flutter** (web first) using idiomatic Flutter patterns (`StatelessWidget`/`StatefulWidget`, `Theme`, `GoRouter` or similar, Material/Cupertino only where appropriate). The HTML files are the source of truth for visual fidelity.

When in doubt about a value (padding, color, font weight), open the JSX file and read the inline styles — they are literal.

## Fidelity

**High-fidelity.** Final colors, typography, spacing, iconography, and interactions are settled. Recreate pixel-perfectly in Flutter.

## Brand Identity

- **Name**: Splitpot
- **Tone**: Classic poker — green felt table + gold accents — with a modern, refined feel (not kitschy cassino neon)
- **Logo**: A gold chip with a "+" split motif + wordmark. See `shared.jsx` → `Logo`. Suggest rendering in Flutter as a `CustomPainter` or SVG via `flutter_svg`.

## Design Tokens

Copy these into your Flutter `ThemeData` / design system. All values are final.

### Colors (CSS vars in `styles.css`)

| Token | Hex | Use |
|---|---|---|
| `--felt-deep` | `#0a2518` | App background (base of radial gradient) |
| `--felt` | `#0f3a24` | Felt mid (main surface) |
| `--felt-light` | `#155a36` | Felt highlight (top of radial) |
| `--felt-rail` | `#08190f` | Rail / darkest shadow |
| `--gold` | `#d4a24a` | Primary accent, CTA |
| `--gold-bright` | `#f0c770` | Hover/active gold, icons |
| `--gold-dark` | `#8e6a26` | Gold text on light bg |
| `--cream` | `#f5ecd6` | Primary text on dark |
| `--ivory` | `#fbf6e8` | Card backgrounds on light surfaces (QR card) |
| `--bone` | `#e8dcbf` | Secondary cream |
| `--ink` | `#0c1a12` | Dark text on light bg |
| `--muted` | `#8fa79a` | Secondary text on dark |
| `--danger` | `#c0392b` | Negative P&L, errors |
| `--danger-soft` | `#e57373` | Danger text on dark bg |
| `--success` | `#2e8f5a` | Positive P&L, confirmed |
| Success soft | `#6bc997` | Success text on dark bg |

**Felt background** is not a flat color — it's a radial gradient with SVG noise overlay at 0.5 opacity (blend mode overlay). In Flutter, use a `RadialGradient` inside a `Container` decoration, then stack a noise `CustomPaint` or `Image` with `BlendMode.overlay`.

```css
background: radial-gradient(ellipse at 50% 0%, #155a36 0%, #0f3a24 40%, #0a2518 100%);
```

### Typography

**Font family:** `Rubik` (variable weight 300–900, regular + italic). `.ttf` files bundled in `fonts/`.

**Mono (numeric only):** `JetBrains Mono` — used for money (`R$ 150`), codes (`K7N-2QX`), stats. Google Fonts.

| Class | Family | Weight | Usage |
|---|---|---|---|
| `.sp-display` | Rubik | 700 | Screen titles, hero numbers (letter-spacing -0.02em) |
| `.sp-ui` | Rubik | 400–700 | Body, labels, buttons |
| `.sp-num` | JetBrains Mono | 400–700 | All money values, table codes, stats |

Font sizes seen in the design: 10, 11, 12, 13, 14, 15, 16, 18, 22, 28, 34, 36, 48, 52, 56. Line-heights 1.0–1.5.

**Uppercase micro-labels** (gold color, weight 600–700, `letter-spacing: 0.1em`–`0.15em`) are a signature pattern — used as section headers inside cards.

### Spacing scale

The design uses increments of 4px: `4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32, 40`.
Screen padding: 20–24px horizontal. Card padding: 14–20px.

### Radii

- `8px` — tags, small chips
- `10px` — inputs, secondary buttons
- `12px` — list items, most cards
- `14px` — featured cards
- `16px` — hero cards, panel headers
- `20px` — QR card (ornate)
- `46px` — phone frame bezel

### Shadows

- Cards on dark felt: `0 1px 2px rgba(0,0,0,0.06), 0 4px 16px rgba(0,0,0,0.12)`
- QR ivory card: `0 20px 50px rgba(0,0,0,0.4), inset 0 0 0 4px var(--gold)`
- Gold button has a multi-layer inset: `inset 0 1px 0 rgba(255,240,200,0.7), inset 0 -1px 0 rgba(80,50,10,0.25), 0 2px 6px rgba(0,0,0,0.25)`

### Gold-foil text effect

A signature on money totals and "Splitpot" wordmark:

```css
background: linear-gradient(180deg, #f3d27b 0%, #d4a24a 45%, #a5791f 55%, #e8bd60 100%);
-webkit-background-clip: text;
color: transparent;
text-shadow: 0 1px 0 rgba(0,0,0,0.15);
```

In Flutter, use `ShaderMask` with a `LinearGradient` on the `Text` widget.

## Screens

12 screens organized in 5 flows. Each has a corresponding component in `screens-part1/2/3.jsx`. **Open the JSX for exact inline styles.**

### Flow 1 · Auth & Onboarding

**01 · Login** (`ScreenLogin`)
Hero stack of 3 overlapping chip towers (red, blue, black) → "Splitpot" wordmark in gold foil → suit row (♠♥♦♣) → tagline "Caixa transparente para seu home game" → two full-width auth buttons (Apple = black, Google = cream with colored G logo). 52px button height, 12px radius. Legal copy muted beneath.

**02 · Onboarding** (`ScreenOnboarding`)
Back arrow header. Title "Complete seu perfil" (display, 28px). Three labeled text inputs: Nome (editable), Email (disabled, from OAuth), Chave PIX (editable, placeholder lists formats). Gold label pattern above each input. Helper text below PIX field. Primary CTA "Entrar no Splitpot".

### Flow 2 · Home & Create

**03 · Home** (`ScreenHome`)
Header: avatar left, logo center, bell right.
Hero CTA card: gold-tinted gradient with 3-stack chip decoration → eyebrow "Começar agora" → display title "Nova mesa de cash game" → description → small gold button "Criar mesa →".
Secondary: "Entrar com código" list row (QR icon left, chevron right).
Stats grid (2 cols): "P&L total" (+R$ 842 in green), "Taxa de vitória" (58%).
"Mesas recentes" list with date-badge thumbnails.

**04 · Create Table** (`ScreenCreate`)
Form: table name input, buy-in min/max (two side-by-side numeric inputs with inset labels), blinds pill group (5 options, "0,50" selected = gold tinted), "Você também vai jogar" toggle row (gold toggle on). CTA "Abrir mesa".

**05 · QR Code** (`ScreenQR`)
Table name + metadata row (buy-in · blinds). Ivory QR card with 4px gold inset border, corner flourish marks, generated QR pattern (see `QRPattern` component — deterministic pseudo-QR SVG with finder squares at top-left, top-right, bottom-left, and centered chip logo). Table code `K7N-2QX` in mono. Share row: WhatsApp (green), Copy link (gold), Share. "Aguardando · 2 entraram" live panel with avatar stack and pulsing red dot. CTA "Iniciar jogo".

### Flow 3 · Player

**06 · Join Table** (`ScreenJoin`)
Table info card (dark, with spade decoration, host avatar row, divider, 3-column meta). Buy-in picker: large mono money display `R$ 100` → range slider → 4 preset buttons. Info panel explaining PIX only happens at close. CTA "Confirmar entrada · R$ {n}".

**07 · Live Table** (`ScreenLive`)
Header with pulsing "ao vivo · 2h 14min" subtitle. Pot summary card: eyebrow "Total em jogo" + gold-foil mono amount + "6 jogadores · 3 rebuys" + chip-stack decoration. Tab control "Mesa | Histórico". Player list rows: avatar, name + HOST/VOCÊ badge, "Entrou R$150 · 1 rebuy (R$50)" secondary, right-aligned total with "EM JOGO" label. VOCÊ row has gold-tinted bg.
Sticky action bar (3 buttons): "+ Rebuy" (ghost), "Sair da mesa" (ghost, danger color), "Fechar mesa" (gold).

**08 · Cash Out** (`ScreenCashout`)
"Com quanto você está saindo?" Summary card (entered, rebuys, total invested). Large stack-count input with `R$` prefix. Two quick-buttons: "Zerado" (danger tint) + "Empate" (neutral). P&L preview panel — color-shifts green/red based on stack vs invested. CTA "Confirmar saída".

### Flow 4 · Settlement

**09 · Close Table** (`ScreenClose`)
Host-only. Pot total card (gold foil) + duration + player count. P&L list per player (avatar, name, entered→out micro, colored +/- amount). "Acertos PIX · otimizados" section with count savings callout ("Minimizou de 15 para 5 pagamentos"). Transfer diagram rows: from-avatar — dashed gold line — pill amount — dashed gold line — to-avatar, with PIX key beneath. Bottom: Voltar (ghost) + Gerar QR Codes PIX (gold primary).

**10 · PIX Status** (`ScreenPix`)
Progress card: "3 / 5" with gold bar. Transfer list — each row shows from→to names + PIX key + amount + status tag (`✓ Pago` green, `Aguardando` gold, `Falhou` red). Pending rows expose "Abrir QR Code PIX" + "Marcar pago". Failed rows show inline error + retry. CTA "Encerrar mesa".

### Flow 5 · History

**11 · History** (`ScreenHistory`)
Stats panel: gold-foil P&L acumulado + 4-stat grid (Mesas, Vitórias, ROI médio, Como host). Full list of past tables — each row has colored suit thumbnail (hearts green for wins, spades red for losses), table name, "date · N jog. · duration · Host?", right-aligned P&L.

**12 · Table Detail** (`ScreenDetail`)
Drill-down into past table. Header card: date eyebrow, title, 3-stat row (Duration, Pot, Players), gold divider, your personal result big and colored. **Timeline** list — each event: time (mono), 22px circle glyph (♠ start/close, + join, ↻ rebuy, − out), event text. Player result list (avatar, name, entered→out, P&L).

## Phone frame

All screens render inside a `Phone` wrapper (`shared.jsx`):
- 390×780 viewport
- 46px radius
- Dynamic island at top (black pill 110×32, 10px from top)
- Home indicator at bottom (120×4 rounded, cream 55% opacity)
- iOS-style status bar (time, wifi, battery icons)

**In Flutter:** for production, you do NOT render a phone frame — that's just for prototype presentation. Build screens at 390px width reference and let them flex.

## Interactions & Navigation

Navigation graph (implement with GoRouter):

```
login → onboarding → home
home ↔ create → qr → live
home ↔ join → live
live → cashout → live
live → close → pix → home
home ↔ history ↔ detail
```

- Back arrow in header always goes back one step
- In-page buttons use the `onNav(key)` prop in JSX — that's the navigation intent
- No animations beyond iOS-default push/pop
- The pulsing "live" dot uses a 1.6s ease-in-out infinite scale+opacity animation

## State Management

Suggest `riverpod` or `provider`. Entities:

```
User { id, name, email, pixKey }
Table {
  id, code, name, hostId,
  buyInMin, buyInMax, smallBlind,
  createdAt, closedAt,
  players: [Player],
  rebuys: [{ playerId, amount, timestamp }],
  cashOuts: [{ playerId, amount, timestamp }],
  transfers: [{ fromId, toId, amount, pixKey, status }]
}
Player { userId, tableId, buyIn, rebuys, cashOut, pixKeyAtJoin }
```

## Algorithms to implement

1. **P2P settlement optimizer** (greedy): Given each player's P&L (`out - invested`), split into debtors and creditors, match largest debtor to largest creditor iteratively until all balances are zero. Result: at most N-1 transfers for N players.

2. **QR code generation**: Use `qr_flutter` package. Encode a URL like `https://splitpot.app/join/K7N-2QX`. The prototype renders a fake pattern — use real QR in Flutter.

3. **PIX BR Code generation**: For the close-phase QR per transfer, generate a valid PIX payload (EMVCo BR Code format) embedding the recipient's PIX key and amount. Libraries: `brcode_parser`, or hand-roll the TLV encoding.

## Assets

- **Fonts**: `fonts/Rubik-VariableFont_wght.ttf`, `fonts/Rubik-Italic-VariableFont_wght.ttf` (bundled)
- **Icons**: All inline SVG in JSX. Port to `flutter_svg` strings or use `lucide_icons` equivalents. The suit glyphs (♠♥♦♣) are custom paths — keep them custom in Flutter (`CustomPainter`).
- **QR pattern**: deterministic SVG generated in `QRPattern` — replace with real `qr_flutter` widget.
- **Poker chip**: custom SVG in `PokerChip` — port to Flutter `CustomPainter` for exact fidelity.

## Files in this bundle

- `Splitpot.html` — main entry point; open this to see the prototype
- `styles.css` — design tokens, font faces, utility classes (`.sp-felt`, `.sp-gold-foil`, `.sp-btn-gold`, etc.)
- `shared.jsx` — primitives: `Phone`, `StatusBar`, `AppHeader`, `Avatar`, `Logo`, `PokerChip`, `Suit`, `BRL()`
- `screens-part1.jsx` — Login, Onboarding, Home, Create, QR
- `screens-part2.jsx` — Join, Live, Cashout
- `screens-part3.jsx` — Close, Pix, History, Detail (contains `settlementMock` with sample data)
- `design-canvas.jsx`, `tweaks-panel.jsx` — prototype-only harness; ignore for implementation
- `fonts/` — Rubik variable TTF files

## Out of scope (not yet designed)

- QR camera scanner screen (the "Entrar com código" entry point in Home)
- Mid-game Rebuy modal (button exists on Live screen, no UI yet)
- Push notification designs
- Empty states (no tables yet)
- Error states beyond PIX failure
- Host kick-player flow
- Account settings screen

Ask the designer before implementing these — don't invent UI.
