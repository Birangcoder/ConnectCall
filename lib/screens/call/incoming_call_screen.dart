import 'package:flutter/material.dart';

/// ZEGOCLOUD handles incoming call UI.
///
/// This screen is intentionally kept as a placeholder so existing imports
/// don't break while migrating from the old custom/Stream implementation.
///
/// Do not navigate to this screen for incoming calls.
class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Incoming calls are handled by ZEGOCLOUD.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

const String kIncomingCallPath = '/incoming-call';
