# For run in android device app

adb devices
flutter run -d zenx2250700015971

Shift + R (this restarts the whole app and resets its state).

# DeenGuard Architecture

## Overview

DeenGuard is an Islamic protection application that helps users block harmful content on their Android devices. The app uses a multi-layered approach combining VPN-based DNS filtering and Android Accessibility Services for comprehensive protection.

## Architecture Layers

### 1. Mobile App (Flutter)

- **State Management**: BLoC pattern
- **Local Storage**: Hive for offline data
- **API Communication**: Dio HTTP client

### 2. Android Native Services

- **VPN Service**: Local VPN for DNS-based domain filtering
- **Accessibility Service**: App blocking and content detection

### 3. Backend (NestJS)

- **API**: RESTful endpoints with JWT authentication
- **Database**: PostgreSQL with Prisma ORM

## Technology Stack

| Layer            | Technology           |
| ---------------- | -------------------- |
| Mobile UI        | Flutter / Dart       |
| State Management | flutter_bloc         |
| Local Cache      | Hive                 |
| Network          | Dio                  |
| Backend API      | NestJS               |
| Database         | PostgreSQL           |
| ORM              | Prisma               |
| VPN Filtering    | Android VpnService   |
| App Detection    | AccessibilityService |

## Key Components

### Mobile App Structure

```
lib/
├── core/              # Shared utilities
│   ├── constants/     # App constants
│   ├── theme/         # Theme configuration
│   └── services/     # API, Storage services
├── features/          # Feature modules
│   ├── auth/          # Authentication
│   ├── dashboard/     # Main dashboard
│   ├── blocking/      # Blocking controls
│   └── settings/      # App settings
└── data/              # Data layer
    ├── models/         # Data models
    └── repositories/   # Data repositories
```

### Android Native Structure

```
android_native/
├── vpn_service/           # DNS filtering
│   ├── DNSFilterService.kt
│   └── BlockedDomainManager.kt
└── accessibility_service/ # App blocking
    ├── AppBlockService.kt
    └── ReelDetector.kt
```

### Backend Structure

```
backend/src/
├── modules/
│   ├── auth/           # Authentication
│   ├── blocking/       # Blocklist management
│   ├── dashboard/      # Stats API
│   ├── users/          # User management
│   └── subscriptions/  # Premium features
├── database/
│   └── prisma/         # Database schema
└── common/             # Shared guards, filters
```

## Data Flow

1. **Domain Blocking Flow**:
   - User enables protection in app
   - App requests VPN permission
   - DNSFilterService intercepts DNS queries
   - BlockedDomainManager checks against blocklist
   - If blocked, returns NXDOMAIN response

2. **App Blocking Flow**:
   - AccessibilityService monitors app launches
   - Detects blocked app package names
   - Shows block overlay screen

3. **Sync Flow**:
   - App fetches blocklist from API
   - Stores locally in Hive
   - Updates Android native services

## Security Considerations

- JWT tokens for API authentication
- Passwords hashed with bcrypt
- HTTPS for all API communication
- Local storage encryption for sensitive data
  ////----------------------------------------------------
  To make this project fully functional, the following would need to be done:

1. Install Flutter dependencies: cd apps/mobile_app && flutter pub get
2. Install Node dependencies: cd backend && npm install
3. Generate Prisma client: cd backend && npx prisma generate
4. Set up PostgreSQL database and update .env with connection string
5. Run database migrations: npx prisma db push
6. Create placeholder UI screens for each feature
7. Build and test the Android native services
   ▣ Compaction · big-pickle · 50.8s
   Thinking: The user is asking what we did so far and I've shown them a summary. They said "Continue if you have next steps, or stop and ask for clarification if you are unsure how to proceed."
   Looking at the "Next Steps" I listed:
8. Install Flutter dependencies
9. Install Node dependencies
10. Generate Prisma client
11. Set up PostgreSQL database
12. Run database migrations
13. Create placeholder UI screens
14. Build and test Android native services
    The most logical next step would be to either:

- Ask the user what they want to do next
- Or continue with one of the practical setup steps
  Let me ask the user what they'd like to do next, since there are multiple paths forward.
  Based on the summary, there are several next steps to make this project functional:

1. Install dependencies (Flutter + Node)
2. Set up database (PostgreSQL + Prisma)
3. Create UI screens for the app
4. Build/test Android services
