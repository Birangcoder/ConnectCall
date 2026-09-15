import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'app_avatar.dart';

class UserTile extends ConsumerWidget {
  final UserModel user;

  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;

  final VoidCallback? onTap;

  const UserTile({
    super.key,
    required this.user,
    required this.onAudioCall,
    required this.onVideoCall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref.watch(presenceProvider(user.id));

    final isOnline = presence.when(
      loading: () => false,
      error: (_, _) => false,
      data: (state) => state.isOnline,
    );

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // -----------------------------------------------------------------
              // AVATAR
              // -----------------------------------------------------------------
              AppAvatar(name: user.name, photoUrl: user.photoUrl, radius: 26),

              const SizedBox(width: 12),

              // -----------------------------------------------------------------
              // NAME + STATUS
              // -----------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline
                                ? AppColors.online
                                : AppColors.offline,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline
                                ? AppColors.online
                                : AppColors.offline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // -----------------------------------------------------------------
              // AUDIO CALL
              // -----------------------------------------------------------------
              IconButton(
                onPressed: isOnline ? onAudioCall : null,
                icon: const Icon(Icons.call),
                color: AppColors.primary,
              ),

              // -----------------------------------------------------------------
              // VIDEO CALL
              // -----------------------------------------------------------------
              IconButton(
                onPressed: isOnline ? onVideoCall : null,
                icon: const Icon(Icons.videocam),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
