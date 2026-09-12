import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../core/config/app_config.dart';
import '../models/user_model.dart';

class CallingService {
  CallingService._();

  static final CallingService instance =
  CallingService._();

  bool _initialized = false;

  // ---------------------------------------------------------------------------
  // INITIALIZE ZEGOCLOUD FOR LOGGED-IN USER
  // ---------------------------------------------------------------------------

  Future<void> connect(UserModel user) async {
    if (_initialized) {
      return;
    }

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: AppConfig.zegoAppId,
      appSign: AppConfig.zegoAppSign,
      userID: user.id,
      userName: user.name,
      plugins: [
        ZegoUIKitSignalingPlugin(),
      ],
    );

    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // CHECK INITIALIZATION
  // ---------------------------------------------------------------------------

  bool get isInitialized => _initialized;

  // ---------------------------------------------------------------------------
  // START CALL
  // ---------------------------------------------------------------------------

  Future<bool> callUser({
    required String receiverId,
    required String receiverName,
    required bool isVideoCall,
  }) async {
    if (!_initialized) {
      return false;
    }

    try {
      final result =
      await ZegoUIKitPrebuiltCallInvitationService()
          .send(
        invitees: [
          ZegoCallUser(
            receiverId,
            receiverName,
          ),
        ],
        isVideoCall: isVideoCall,
        timeoutSeconds: 60,
      );

      return result;
    } catch (e) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    if (!_initialized) {
      return;
    }

    try {
      await ZegoUIKitPrebuiltCallInvitationService()
          .uninit();
    } finally {
      _initialized = false;
    }
  }
}