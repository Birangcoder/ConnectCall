import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/calling_service.dart';

class CallActions extends ConsumerWidget {
  final UserModel user;

  const CallActions({
    super.key,
    required this.user,
  });

  Future<void> _audioCall(BuildContext context) async {
    await CallingService.instance.callUser(
      context: context,
      receiverId: user.id,
      receiverName: user.name,
      isVideoCall: false,
    );
  }

  Future<void> _videoCall(BuildContext context) async {
    await CallingService.instance.callUser(
      context: context,
      receiverId: user.id,
      receiverName: user.name,
      isVideoCall: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(
      presenceProvider(user.id),
    );

    final isOnline = presence.when(
      loading: () => false,
      error: (_, _) => false,
      data: (state) => state.isOnline,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: isOnline
              ? 'Audio call'
              : 'User is offline',
          onPressed: isOnline
              ? () => _audioCall(context)
              : null,
          icon: const Icon(Icons.call),
          color: AppColors.primary,
          iconSize: 35,
        ),

        IconButton(
          tooltip: isOnline
              ? 'Video call'
              : 'User is offline',
          onPressed: isOnline
              ? () => _videoCall(context)
              : null,
          icon: const Icon(Icons.videocam),
          color: Colors.green,
          iconSize: 35,
        ),
      ],
    );
  }
}