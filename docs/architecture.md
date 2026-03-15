# For run in android device app

adb devices
flutter run -d zenx2250700015971

Shift + R (this restarts the whole app and resets its state).

//----------------key store file past in terminal
keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000


<!-- #backend  -->

npx prisma generate

then backend is ready 

# DeenGuard Architecture

## Overview

DeenGuard is an Islamic protection application that helps users block harmful content on their Android devices. The app uses a multi-layered approach combining VPN-based DNS filtering, local blocklists, and Android Accessibility Services for comprehensive protection.

## Architecture Layers

### 1. Mobile App (Flutter)

- **State Management**: BLoC pattern
- **Local Storage**: Hive for offline data
- **API Communication**: Dio HTTP client
- **Platform Channels**: MethodChannel for Flutter ↔ Kotlin communication

### 2. Android Native Services

- **VPN Service**: Split-tunnel VPN for DNS-based domain filtering
- **Local Blocklist**: HashSet for O(1) domain lookups (5,000+ domains)
- **Accessibility Services**:
  - App blocking and content detection
  - YouTube AdSkip automation

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
| Platform Channel | MethodChannel        |
| Backend API      | NestJS               |
| Database         | PostgreSQL           |
| ORM              | Prisma               |
| VPN Filtering    | Android VpnService   |
| DNS Blocking     | AdGuard Family DNS   |
| Ad Blocking      | AccessibilityService |
| App Blocking     | AccessibilityService |

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
android/app/src/main/kotlin/com/example/deenguard/
├── MainActivity.kt              # MethodChannel handlers
├── DeenGuardVpnService.kt      # VPN + local blocklist
├── DeenGuardAdSkipService.kt   # YouTube ad auto-skip
├── AppBlockService.kt          # App blocking
├── ReelDetector.kt             # Content detection
└── BlockedActivity.kt          # Block overlay screen

res/xml/
└── ad_skip_service.xml         # Accessibility service config
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

### 1. Domain Blocking Flow (DNS-based)

```
User enables protection → VPN permission → DNS queries routed through AdGuard DNS
  ├── Family Protection DNS (94.140.14.15/15.16) - blocks adult + ads
  └── Clean DNS (94.140.14.14/15.15) - no blocking
```

### 2. Local Blocklist Flow

```
Flutter sends domains → MethodChannel → VpnService.injectBlocklist()
  → HashSet<Domain> (O(1) lookup) → isDomainBlocked() check
  → Assets file (blocklist.txt) can be pre-loaded
```

### 3. App Blocking Flow

```
AccessibilityService monitors app launches
  → Detects blocked package names (e.g., com.adult.app)
  → Shows BlockedActivity overlay
```

### 4. YouTube AdSkip Flow

```
DeenGuardAdSkipService monitors YouTube (com.google.android.youtube)
  → Detects "Ad" / "Sponsored" text → Mutes STREAM_MUSIC
  → Finds "Skip" button → Performs ACTION_CLICK
  → Ad ends → Restores music volume
```

### 5. Sync Flow

```
App fetches blocklist from API → Stores in Hive
  → Updates VPN/Accessibility services via MethodChannel
```

## Security Considerations

- JWT tokens for API authentication
- Passwords hashed with bcrypt
- HTTPS for all API communication
- Local storage encryption for sensitive data

## MethodChannel API

### VPN Channel: `com.example.deenguard/vpn`

| Method                    | Parameters              | Description               |
| ------------------------- | ----------------------- | ------------------------- |
| `startVpn`                | -                       | Start VPN service         |
| `stopVpn`                 | -                       | Stop VPN service          |
| `setFamilyProtection`     | `enabled: bool`         | Toggle AdGuard Family DNS |
| `setBlocklistEnabled`     | `enabled: bool`         | Enable local blocklist    |
| `injectBlocklist`         | `domains: List<String>` | Inject 5,000+ domains     |
| `loadBlocklistFromAssets` | `filename: String`      | Load from assets file     |
| `getBlocklistSize`        | -                       | Get blocklist count       |
| `getFamilyProtection`     | -                       | Get current state         |

### AdSkip Channel: `com.example.deenguard/adskip`

| Method                         | Parameters | Description                |
| ------------------------------ | ---------- | -------------------------- |
| `startAdSkipService`           | -          | Enable YouTube ad skipping |
| `stopAdSkipService`            | -          | Disable ad skipping        |
| `checkAccessibilityPermission` | -          | Check service permission   |
| `openAccessibilitySettings`    | -          | Open system settings       |
| `isAdSkipEnabled`              | -          | Get current state          |
| `isAdPlaying`                  | -          | Check if ad is playing     |
