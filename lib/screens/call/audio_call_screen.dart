import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../core/config/app_config.dart';

class AudioCallScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String callId;

  const AudioCallScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.callId,
  });

  @override
  Widget build(BuildContext context) {
    final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: AppConfig.zegoAppId,
          appSign: AppConfig.zegoAppSign,
          userID: userId,
          userName: userName,
          callID: callId,
          config: config,
        ),
      ),
    );
  }
}
