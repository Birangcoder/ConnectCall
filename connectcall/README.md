# ConnectCall — Flutter Calling Internship Assignment

A Flutter 1-to-1 calling application matching the supplied internship assignment.

## Stack

- Flutter
- Riverpod
- Firebase Authentication
- Cloud Firestore
- Stream Video Flutter
- GoRouter
- permission_handler

## No custom backend

This version intentionally does **not** contain a Node.js/server folder.
For this internship/demo build, Stream development tokens are configured per
Firebase UID in `lib/core/config/stream_config.dart`.

Do **not** put the Stream API Secret in Flutter.

## Setup

1. Configure Firebase for your own Firebase project:

```bash
flutterfire configure
```

2. Put your Stream API key in:

`lib/core/config/stream_config.dart`

```dart
static const String apiKey = 'YOUR_STREAM_API_KEY';
```

3. Generate development tokens for the test users and add them using their
   Firebase UIDs:

```dart
static const Map<String, String> userTokens = {
  'firebaseUidUserA': 'streamTokenForUserA',
  'firebaseUidUserB': 'streamTokenForUserB',
};
```

The Stream API key is shared by all users. The development token is tied to
the Stream user ID, which is the Firebase UID in this project.

4. Install packages:

```bash
flutter pub get
```

5. If the archive does not contain generated platform folders, create them:

```bash
flutter create .
```

6. Run:

```bash
flutter run
```

## Android / iOS permissions

The Stream SDK requires microphone and camera permissions for calls. Ensure
the generated Android/iOS platform files contain the required permissions.

## Important

The project source can be checked with:

```bash
flutter analyze
```

An installable APK must be built on a local Flutter/Android environment:

```bash
flutter build apk --release
```

## Assignment coverage

Authentication, contacts/search, profile, 1-to-1 audio/video calls, incoming
calls, accept/reject, mute, camera toggle, camera switch, end call, call
history, permissions, loading/error/empty states, Riverpod state management,
and Stream Video integration are included.
