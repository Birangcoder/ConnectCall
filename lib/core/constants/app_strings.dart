class AppStrings {
  AppStrings._();

  static const String appName = 'ConnectCall';
  static const String tagline = 'Connect with anyone, anywhere.';

  // Auth
  static const String login = 'Login';
  static const String createAccount = 'Create Account';
  static const String emailOrPhone = 'Email / Phone';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String email = 'Email';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';

  // Errors
  static const String errNoInternet =
      'No internet connection. Please check your network and try again.';
  static const String errMicPermission =
      'Microphone permission is required to make calls.';
  static const String errCameraPermission =
      'Camera permission is required for video calls.';
  static const String errPermissionPermanentlyDenied =
      'Permission was permanently denied. Please enable it from Settings.';
  static const String errCallFailed =
      'Could not connect the call. Please try again.';
  static const String errUserOffline = 'This user is currently offline.';
  static const String errGeneric = 'Something went wrong. Please try again.';

  // Call states
  static const String calling = 'Calling…';
  static const String ringing = 'Ringing…';
  static const String connected = 'Connected';
  static const String callEnded = 'Call ended';
  static const String callRejected = 'Call rejected';
  static const String callMissed = 'Missed call';
  static const String callBusy = 'User is busy';
}
