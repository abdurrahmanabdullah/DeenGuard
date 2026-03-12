# DeenGuard - Islamic Protection App

Monorepo for DeenGuard Islamic protection application with Flutter mobile app, Android native services, and NestJS backend.

## Project Structure

```
deenguard/
├── apps/
│   ├── mobile_app/           # Flutter Application
│   └── android_native/       # Android Native Blocking Layer
├── backend/                  # NestJS API Server
├── shared/                   # Shared code between apps
├── scripts/                  # Utility scripts
└── docs/                     # Documentation
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile App | Flutter / Dart |
| Local Storage | Hive / Isar |
| VPN DNS Filtering | Android Native (Kotlin) |
| App Detection | Accessibility Service (Kotlin) |
| Backend API | NestJS |
| Database | PostgreSQL |
| ORM | Prisma |

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Node.js 18+
- PostgreSQL 14+
- Android Studio
- Kotlin

### Backend Setup

```bash
cd backend
npm install
npx prisma generate
npx prisma db push
npm run start:dev
```

### Mobile App Setup

```bash
cd apps/mobile_app
flutter pub get
flutter run
```

## License

MIT License
