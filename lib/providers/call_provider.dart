import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/helper/permission_helper.dart';
import '../models/user_model.dart';
import '../services/calling_service.dart';

final callingServiceProvider = Provider<CallingService>((ref) {
  return CallingService.instance;
});

final callControllerProvider = NotifierProvider<CallController, CallUiState>(
  CallController.new,
);

class CallUiState {
  final bool isLoading;
  final String? error;

  const CallUiState({this.isLoading = false, this.error});

  CallUiState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CallUiState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CallController extends Notifier<CallUiState> {
  CallingService get _callingService => ref.read(callingServiceProvider);

  @override
  CallUiState build() {
    return const CallUiState();
  }

  // ---------------------------------------------------------------------------
  // START CALL
  // ---------------------------------------------------------------------------

  Future<bool> startCall({
    required String receiverId,
    required String receiverName,
    required bool isVideoCall,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // ---------------------------------------------------------------
      // REQUEST PERMISSIONS
      // ---------------------------------------------------------------

      final permissionsGranted = isVideoCall
          ? await PermissionHelper.requestForVideoCall()
          : await PermissionHelper.requestForAudioCall();

      if (!permissionsGranted) {
        state = state.copyWith(
          isLoading: false,
          error: isVideoCall
              ? 'Camera and microphone permission are required.'
              : 'Microphone permission is required.',
        );

        return false;
      }

      // ---------------------------------------------------------------
      // CHECK ZEGOCLOUD INITIALIZATION
      // ---------------------------------------------------------------

      if (!_callingService.isInitialized) {
        state = state.copyWith(
          isLoading: false,
          error: 'Calling service is not initialized.',
        );

        return false;
      }

      // ---------------------------------------------------------------
      // SEND ZEGOCLOUD INVITATION
      // ---------------------------------------------------------------

      final success = await _callingService.callUser(
        context: context,
        receiverId: receiverId,
        receiverName: receiverName,
        isVideoCall: isVideoCall,
      );

      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to start the call.',
        );

        return false;
      }

      state = state.copyWith(isLoading: false, clearError: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to start the call: $e',
      );

      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
