# ConnectCall — Flutter Calling App

ConnectCall is a Flutter-based 1-to-1 calling application. It provides user authentication, contact/user search, profiles, audio and video calling, incoming call handling, call history, permissions, and an APK update system using GitHub Releases.

## Features

- Firebase Authentication
- User profile management
- Search/find users and contacts
- 1-to-1 audio calling
- 1-to-1 video calling
- Incoming call notifications/invitations
- Accept/reject incoming calls
- Mute/unmute microphone
- Enable/disable camera
- Switch front/rear camera
- End calls
- Block user
- UnBlock user
- Call history
- Camera and microphone permission handling
- Loading, error, and empty states
- Riverpod state management
- GoRouter navigation
- APK update checking and installation
- GitHub Releases for distributing application updates

## Flutter Version

The project was built and tested with:

```text
Flutter 3.44.6 • channel stable
Dart 3.12.2 • DevTools 2.57.0
```

`pubspec.yaml` specifies the Dart SDK constraint:

```yaml
environment:
  sdk: ^3.12.2
```

You can verify your local setup with:

```bash
flutter --version
```

## Packages Used

Main packages used in the project (with pinned versions from `pubspec.yaml`):

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `go_router` | ^14.2.0 | Application navigation |
| `firebase_core` | ^3.1.0 | Firebase initialization |
| `firebase_auth` | ^5.1.0 | User authentication |
| `cloud_firestore` | ^5.0.1 | User/application data |
| `firebase_messaging` | ^15.0.1 | Push notifications |
| `firebase_database` | ^11.3.10 | Realtime Database support |
| `zego_uikit_prebuilt_call` | ^4.24.4 | Audio/video calling and call UI |
| `zego_uikit_signaling_plugin` | ^2.8.21 | ZEGOCLOUD call invitation/signaling support |
| `permission_handler` | ^12.0.3 | Camera and microphone permissions |
| `image_picker` | ^1.2.0 | Picking profile/media images |
| `http` | ^1.5.0 | Fetching `version.json` |
| `dio` | ^5.8.0 | APK downloading |
| `package_info_plus` | ^8.3.0 | Reading the installed app version |
| `path_provider` | ^2.1.5 | Application storage paths |
| `flutter_app_installer` | ^2.0.0 | Opening the Android APK installer |
| `intl` | ^0.19.0 | Date/number formatting |
| `cached_network_image` | ^3.3.1 | Efficient image caching |
| `connectivity_plus` | ^6.0.3 | Network connectivity checks |
| `uuid` | ^4.5.1 | Unique ID generation |
| `flutter_native_splash` | ^2.4.6 | Native splash screen generation |
| `flutter_launcher_icons` | ^0.13.1 | App launcher icon generation |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

**Dev dependencies:**

| Package | Version | Purpose |
|---|---|---|
| `flutter_lints` | ^6.0.0 | Recommended lint rules |

> Exact dependency versions are defined in `pubspec.yaml`.

## Architecture

The project uses a layered Flutter architecture with separation between UI, state management, services, models, and configuration.

```text
lib/
├── core/
│   └── config/
├── models/
├── providers/
├── screens/
├── services/
├── widgets/
└── main.dart
```

### State Management

Riverpod is used for application state management and reactive UI updates.

### Navigation

GoRouter is used for route and navigation management.

### Services

Services handle external integrations and application-level operations such as Firebase, ZEGOCLOUD calling, and APK updates.

## Backend Used

### Firebase

ConnectCall uses Firebase services:

- **Firebase Authentication** — authentication
- **Cloud Firestore** — storing and retrieving user/application data

There is currently no custom Node.js/Express backend in the project.

## Calling SDK Used

### ZEGOCLOUD

ConnectCall uses **ZEGOCLOUD / ZegoUIKitPrebuiltCall** for real-time 1-to-1 audio and video calling.

It supports:

- Audio/video communication
- Call invitations
- Incoming calls
- Accept/reject actions
- Microphone controls
- Camera controls
- Camera switching
- Ending calls

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/Birangcoder/ConnectCall.git
cd ConnectCall/connectcall
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Configure the project with your Firebase project:

```bash
flutterfire configure
```

Enable the required Firebase services, especially Firebase Authentication and Cloud Firestore.

### 4. Configure ZEGOCLOUD

Create/configure a ZEGOCLOUD project and add the required ZEGOCLOUD configuration to the application.

Do not commit private secrets or sensitive credentials to a public repository.

### 5. Configure permissions

Camera and microphone permissions are required for audio/video calls. Make sure the Android/iOS platform configuration contains the required permissions.

### 6. Run the application

```bash
flutter run
```

### 7. Build a release APK

```bash
flutter build apk --release
```

The generated APK is normally located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Environment Variables / Configuration

The project uses configuration files for third-party services.

Configuration includes:

- Firebase configuration generated by FlutterFire
- ZEGOCLOUD calling configuration
- APK update information in `version.json`
- Android release-signing configuration

### Important

Never commit private API secrets, passwords, signing keys, or keystores to GitHub.

Keep files such as these out of the public repository:

```text
android/key.properties
*.jks
*.keystore
```

### APK Update System

Because ConnectCall is distributed outside Google Play, the project includes a custom Android APK update system.

The application checks:

```text
https://raw.githubusercontent.com/Birangcoder/ConnectCall/main/connectcall/version.json
```

Example `version.json`:

```json
{
  "latestVersion": "1.1.0",
  "minimumVersion": "1.0.0",
  "apkUrl": "https://github.com/Birangcoder/ConnectCall/releases/download/v1.1.0/connectcall-v1.1.0.apk",
  "releaseNotes": [
    "New features",
    "Bug fixes"
  ]
}
```

APK files are distributed through GitHub Releases.

For an APK to update an existing installation, the application must keep the same Android application ID and use the same release signing key.

## Known Limitations

- The application is currently distributed as an APK instead of through Google Play.
- Android may require the user to allow installation from unknown sources.
- Calling requires camera/microphone permissions and a suitable internet connection.
- The current APK update mechanism is intended for Android distribution.
- Release APKs must use the same signing key as the installed application for in-place updates.
- Firebase and ZEGOCLOUD configuration must be correctly configured before authentication and calling features work.
- There is no custom Node.js/server backend at present.

## AI Tools Used

AI tools were used during development for:

- Understanding Flutter and Dart concepts
- Generating and improving Flutter code
- Debugging build and Gradle issues
- Designing application architecture
- Troubleshooting Firebase and ZEGOCLOUD integration
- Improving documentation
- Designing and troubleshooting the APK update workflow

**AI tool used:**
- ChatGPT

## Assignment Coverage

The project includes:

- Authentication
- Contacts/user search
- User profile
- 1-to-1 audio calls
- 1-to-1 video calls
- Incoming calls
- Accept/reject calls
- Mute/unmute
- Camera toggle
- Camera switching
- End call
- Call history
- Permissions
- Loading/error/empty states
- Riverpod state management
- GoRouter navigation
- Firebase integration
- ZEGOCLOUD calling integration
- APK update system

## License

This project is developed for educational, internship, and demonstration purposes.
