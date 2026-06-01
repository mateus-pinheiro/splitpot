# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

SplitPot is a cash-tracking platform for in-person Texas Hold'em home games. It records buy-ins/rebuys/cash-outs and calculates optimized P2P settlements (Splitwise-style) via PIX. The repo has three directories:

- `api/` — NestJS + TypeScript + Prisma + PostgreSQL backend
- `app/` — Flutter frontend (web-first, then Android/iOS)
- `design_system/` — JSX design canvas and reference screens (not deployed)

## Development commands

### API (`cd api`)

```bash
docker compose up -d            # start local Postgres
npm install
npx prisma migrate dev          # apply schema, regenerate client
npm run start:dev               # watch mode
npm run build                   # compile to dist/
npm run test                    # unit tests (Jest)
npm run test:e2e                # e2e tests
npm run lint                    # ESLint --fix
```

### App (`cd app`)

```bash
flutter pub get
flutter run -d chrome                                                  # web dev
dart run build_runner build --delete-conflicting-outputs --force-jit  # regenerate freezed/json_serializable
dart run build_runner watch --delete-conflicting-outputs --force-jit  # watch mode for codegen
```

`--force-jit` is required on Dart 3.10+: `dart compile aot-snapshot` no longer
supports the build-hooks API used by build_runner ≤ 2.15, so the default AOT
path fails with `'dart compile' does not support build hooks, use 'dart build'
instead`. JIT mode is slightly slower but otherwise equivalent. Drop the flag
once build_runner ships a fix.

## Architecture overview

### API

NestJS feature modules (`auth`, `users`, `tables`, `participations`, `settlements`), each with controller → service → Prisma. All routes require a Firebase ID token (`FirebaseAuthGuard` is applied globally; `@Public()` opts out). The guard decodes the token with `firebase-admin` and exposes it via `@FirebaseUser()`.

Key business logic lives in `ParticipationsService` and `TablesService`:
- `join` creates a `TableParticipation` (+ optional first `BuyIn`) in a transaction.
- `addBuyIn` / `rejoin` add chips; `setCashOut` records cash-out and auto-closes the table when all active participants have one.
- `leave` sets `leftAt`; if no one remains, it auto-closes the table.
- Settlement calculation (`settlement-calculator.ts`) runs a greedy debt-simplification algorithm when the table is closed.

### App

**Clean Architecture** with three layers per feature: `data` (DTOs, repository impls), `domain` (entities, repository interfaces, use-cases), `presentation` (Cubit + View).

**DI**: GetIt, registered once in `app/lib/core/di/app_dependencies.dart`. Core services (`ApiClient`, `FirebaseTokenStore`) are singletons; Cubits are factories (new instance per view).

**State management**: flutter_bloc Cubits. Sealed-class states (built with `freezed`). `AsyncState<T>` in `core/bloc/` is a shared loading/error/data union for simple cases.

**Routing**: GoRouter in `core/router/app_router.dart`. The `_redirect` guard reads `AuthCubit` state and routes to `/login` or `/complete-profile` when unauthenticated or profile-incomplete. Deep links preserve the intended destination in `?next=`.

**Real-time**: `LiveCubit` polls `GET /tables/:id` every 10 s. No WebSocket yet — if that changes, `LiveCubit` is the only file to touch.

**Auth flow**: Google Sign-In → Firebase ID token stored in `FirebaseTokenStore` → `ApiClient` attaches it as `Authorization: Bearer`. Backend provisions/syncs the user record on first call.

### Prisma schema highlights

```
User → ownedTables (Table), participations (TableParticipation)
Table → participations, settlements
TableParticipation → buyIns (BuyIn[]), cashOut (CashOut?)
Settlement: fromUser → toUser, amount, pixCopiaECola, status (PENDING|CONFIRMED)
```

The backend distinguishes initial buy-in from rebuys purely by insertion order — the first `BuyIn` by `createdAt` is the initial one; the rest are rebuys.

## Code-generation notes

Dart entities under `domain/entities/` use `@freezed` and `@JsonSerializable`. After any model change, run `build_runner` (see above). Generated files (`*.freezed.dart`, `*.g.dart`) are committed.

## Environment

API reads from `api/.env` (see `api/.env.example`). The app reads `--dart-define` flags resolved in `app/lib/core/config/app_config.dart` (`apiBaseUrl`, Firebase config).
