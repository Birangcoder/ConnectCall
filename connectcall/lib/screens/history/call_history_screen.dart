import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/call_history_model.dart';
import '../../providers/call_history_provider.dart';
import '../../widgets/app_avatar.dart';

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  IconData _icon(CallHistoryEntry e) =>
      e.type.name == 'video' ? Icons.videocam : Icons.call;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(callHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Call History')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Could not load history.\n$e', textAlign: TextAlign.center)),
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('No calls yet'))
            : ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            final missedColor =
            e.isMissed ? AppColors.error : AppColors.textSecondaryLight;
            return Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: AppAvatar(
                    name: e.otherUserName,
                    photoUrl: e.otherUserPhotoUrl,
                    radius: 22),
                title: Text(e.otherUserName,
                    style: TextStyle(
                        color: e.isMissed ? AppColors.error : null)),
                subtitle: Text(
                  '${e.type.name == 'video' ? 'Video Call' : 'Audio Call'} · '
                      '${DateFormatter.relativeCallTime(e.timestamp)} · '
                      '${e.isOutgoing ? 'Outgoing' : 'Incoming'}',
                  style: TextStyle(fontSize: 12, color: missedColor),
                ),
                trailing: e.isMissed
                    ? const Text('Missed',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600))
                    : Text(DateFormatter.callDuration(e.duration)),
                // leadingAndTrailingTextStyle: null,
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}