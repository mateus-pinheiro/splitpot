# SplitPot

Plataforma para controle de caixa de mesas de poker Texas Hold'em cash game presencial (home game). Calcula acerto P2P otimizado entre participantes no modelo Splitwise.

## Estrutura

```
splitpot/
  api/   NestJS + TypeScript + Prisma + PostgreSQL
  app/   Flutter (web + mobile) — Clean Architecture + Cubit + GoRouter
```

## Stack

- **Backend**: NestJS, Prisma, PostgreSQL
- **Frontend**: Flutter (web primeiro, Android depois, iOS por último)
- **Auth**: Firebase Auth (Google Sign-In), backend valida ID token
- **Pagamento**: PIX copia-e-cola gerado pela plataforma; beneficiário confirma recebimento no app

## Desenvolvimento

### API

```bash
cd api
docker compose up -d          # sobe Postgres local
npm install
npx prisma migrate dev        # aplica schema
npm run start:dev
```

### App

```bash
cd app
flutter pub get
flutter run -d chrome         # web
```
