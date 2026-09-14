import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_uikit/zego_uikit.dart';
import '../core/config/app_config.dart';
import '../models/call_model.dart';
import '../models/user_model.dart';
import 'call_history_service.dart';
import 'call_permission_service.dart';

class CallingService {
  CallingService._();

  static final CallingService instance = CallingService._();

  bool _initialized = false;

  UserModel? _currentUser;

  final Uuid _uuid = const Uuid();

  // ---------------------------------------------------------------------------
  // INITIALIZE ZEGOCLOUD
  // ---------------------------------------------------------------------------

  Future<void> connect(UserModel user) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    // Firebase Auth UID is the single source of truth.
    final firebaseUid = firebaseUser.uid;

    // Keep the latest user model.
    _currentUser = user;

    // If already initialized for this same user, nothing to do.
    if (_initialized) {
      return;
    }

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: AppConfig.zegoAppId,
      appSign: AppConfig.zegoAppSign,

      // IMPORTANT:
      // Use Firebase Auth UID as ZEGOCLOUD user ID.
      userID: firebaseUid,

      userName: user.name,

      plugins: [ZegoUIKitSignalingPlugin()],

      // -----------------------------------------------------------------------
      // INVITATION UI CONFIG
      // -----------------------------------------------------------------------
      uiConfig: ZegoCallInvitationUIConfig(
        inviter: ZegoCallInvitationInviterUIConfig(
          defaultCameraOn: false,
          defaultMicrophoneOn: true,
          defaultSpeakerOn: true,
        ),
        invitee: ZegoCallInvitationInviteeUIConfig(
          defaultCameraOn: false,
          defaultMicrophoneOn: true,
          defaultSpeakerOn: true,
        ),
      ),

      // -----------------------------------------------------------------------
      // CALL CONFIGURATION
      // -----------------------------------------------------------------------
      requireConfig: (ZegoCallInvitationData data) {
        if (data.type == ZegoCallInvitationType.videoCall) {
          final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
          config.layout = ZegoLayout.pictureInPicture(
            isSmallViewDraggable: true,
            switchLargeOrSmallViewByClick: true,
          );
          config.turnOnCameraWhenJoining = true;
          config.bottomMenuBarConfig.buttons = [
            ZegoMenuBarButtonName.toggleMicrophoneButton,
            ZegoMenuBarButtonName.toggleCameraButton,
            ZegoMenuBarButtonName.hangUpButton,
            ZegoMenuBarButtonName.switchCameraButton,
            ZegoMenuBarButtonName.switchAudioOutputButton,
          ];
          return config;
        }

        final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        // Remove the PiP-style floating avatar box for a classic audio-call look
        config.layout = ZegoLayout.pictureInPicture(smallViewSize: Size.zero);
        config.turnOnCameraWhenJoining = false;
        config.useSpeakerWhenJoining = false;
        config.audioVideoViewConfig.showSoundWavesInAudioMode = false;

        config.bottomMenuBarConfig.buttons = [
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.hangUpButton,
          ZegoMenuBarButtonName.switchAudioOutputButton,
        ];
        return config;
      },

      // -----------------------------------------------------------------------
      // INVITATION EVENTS
      // -----------------------------------------------------------------------
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        // Incoming call.
        onIncomingCallReceived:
            (
              String callID,
              ZegoCallUser caller,
              ZegoCallInvitationType callType,
              List<ZegoCallUser> callees,
              String customData,
            ) async {
              print('INCOMING CALL');
              print('Call ID: $callID');
              print('Caller Zego ID: ${caller.id}');
              print('Caller name: ${caller.name}');

              // IMPORTANT:
              // Do NOT create another Firestore call here.
              //
              // The person who initiated the call already created it.
            },

        // Incoming invitation timed out.
        onIncomingCallTimeout: (String callID, ZegoCallUser caller) async {
          await CallHistoryService.instance.markMissed(callID);
        },

        // Outgoing call accepted.
        onOutgoingCallAccepted: (String callID, ZegoCallUser callee) async {
          await CallHistoryService.instance.markConnected(callID);
        },

        // Outgoing call declined.
        onOutgoingCallDeclined:
            (String callID, ZegoCallUser callee, String customData) async {
              await CallHistoryService.instance.markRejected(callID);
            },

        // Callee busy.
        onOutgoingCallRejectedCauseBusy:
            (String callID, ZegoCallUser callee, String customData) async {
              await CallHistoryService.instance.markBusy(callID);
            },

        // Outgoing invitation timeout.
        onOutgoingCallTimeout:
            (
              String callID,
              List<ZegoCallUser> callees,
              bool isVideoCall,
            ) async {
              await CallHistoryService.instance.markMissed(callID);
            },
      ),

      // -----------------------------------------------------------------------
      // CALL EVENTS
      // -----------------------------------------------------------------------
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) async {
          await CallHistoryService.instance.markEnded(event.callID);

          // defaultAction returns void.
          defaultAction();
        },
      ),
    );

    _initialized = true;

    print('ZEGOCLOUD INITIALIZED');
    print('Firebase UID: $firebaseUid');
    print('User name: ${user.name}');
  }

  // ---------------------------------------------------------------------------
  // CHECK INITIALIZATION
  // ---------------------------------------------------------------------------

  bool get isInitialized => _initialized;

  // ---------------------------------------------------------------------------
  // START CALL
  // ---------------------------------------------------------------------------

  Future<bool> callUser({
    required BuildContext context,
    required String receiverId,
    required String receiverName,
    required bool isVideoCall,
  }) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (!_initialized || _currentUser == null || firebaseUser == null) {
      return false;
    }

    // ALWAYS use Firebase Auth UID as caller ID.
    final callerId = firebaseUser.uid;

    print('----------------------------------------');
    print('STARTING CALL');
    print('Caller ID: $callerId');
    print('Caller name: ${_currentUser!.name}');
    print('Receiver ID: $receiverId');
    print('Receiver name: $receiverName');
    print('Video call: $isVideoCall');
    print('----------------------------------------');

    // -------------------------------------------------------------------------
    // REQUEST PERMISSION
    // -------------------------------------------------------------------------

    final permissionGranted = isVideoCall
        ? await CallPermissionService.instance.requestVideoPermission(context)
        : await CallPermissionService.instance.requestAudioPermission(context);

    if (!permissionGranted) {
      return false;
    }

    try {
      // -----------------------------------------------------------------------
      // GENERATE ONE CALL ID
      // -----------------------------------------------------------------------

      final callId = _uuid.v4();

      final callType = isVideoCall ? CallType.video : CallType.audio;

      // -----------------------------------------------------------------------
      // CREATE FIRESTORE HISTORY
      // -----------------------------------------------------------------------

      await CallHistoryService.instance.createCall(
        callId: callId,

        // IMPORTANT:
        // This is the person who actually pressed Call.
        callerId: callerId,
        callerName: _currentUser!.name,
        callerPhotoUrl: _currentUser!.photoUrl,

        // This is the person being called.
        calleeId: receiverId,
        calleeName: receiverName,

        type: callType,
      );

      print('CALL HISTORY CREATED');
      print('Firestore callerId: $callerId');
      print('Firestore calleeId: $receiverId');

      // -----------------------------------------------------------------------
      // SEND ZEGOCLOUD INVITATION
      // -----------------------------------------------------------------------

      final result = await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [ZegoCallUser(receiverId, receiverName)],

        isVideoCall: isVideoCall,

        // SAME ID AS FIRESTORE
        callID: callId,

        timeoutSeconds: 60,
      );

      // -----------------------------------------------------------------------
      // SEND FAILED
      // -----------------------------------------------------------------------

      if (!result) {
        await CallHistoryService.instance.markMissed(callId);
      }

      return result;
    } catch (e) {
      print('CALL ERROR: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    if (!_initialized) {
      _currentUser = null;
      return;
    }

    try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
    } finally {
      _initialized = false;
      _currentUser = null;
    }
  }
}
