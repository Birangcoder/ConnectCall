import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/call_history_model.dart';
import '../../providers/call_history_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_avatar.dart';

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  String _callType(CallHistoryEntry entry) {
    return entry.type.name == 'video' ? 'Video Call' : 'Audio Call';
  }

  String _direction(CallHistoryEntry entry) {
    return entry.isOutgoing ? 'Outgoing' : 'Incoming';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(callHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Call History')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Could not load history.\n$error',
              textAlign: TextAlign.center,
            ),
          );
        },

        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No calls yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              final statusColor = entry.isMissed
                  ? AppColors.error
                  : AppColors.textSecondaryLight;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  leading: AppAvatar(
                    name: entry.otherUserName,
                    photoUrl: entry.otherUserPhotoUrl,
                    radius: 22,
                  ),

                  title: Text(
                    entry.otherUserName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: entry.isMissed ? AppColors.error : null,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_callType(entry)} · '
                        '${DateFormatter.relativeCallTime(entry.timestamp)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: statusColor),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        _direction(entry),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: statusColor),
                      ),
                    ],
                  ),

                  trailing: entry.isMissed
                      ? Text(
                          'Missed',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Text(
                          DateFormatter.callDuration(entry.duration),
                          style: const TextStyle(fontSize: 11),
                        ),

                  onTap: () async {
                    debugPrint('profile tap: ${entry.otherUserId}');

                    final user = await ref
                        .read(userServiceProvider)
                        .getUserById(entry.otherUserId);

                    if (!context.mounted) return;

                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User profile not found')),
                      );
                      return;
                    }

                    context.push('/user-profile', extra: user);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
