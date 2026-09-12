import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/helper/permission_helper.dart';
import '../../models/user_model.dart';
import '../../providers/call_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/presence_service.dart';
import '../../widgets/user_tile.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() =>
      _ContactsScreenState();
}

class _ContactsScreenState
    extends ConsumerState<ContactsScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // AUDIO CALL
  // ---------------------------------------------------------------------------

  Future<void> _startAudioCall(
      UserModel user,
      ) async {
    await _startCall(
      user,
      isVideoCall: false,
    );
  }

  // ---------------------------------------------------------------------------
  // VIDEO CALL
  // ---------------------------------------------------------------------------

  Future<void> _startVideoCall(
      UserModel user,
      ) async {
    await _startCall(
      user,
      isVideoCall: true,
    );
  }

  // ---------------------------------------------------------------------------
  // START CALL
  // ---------------------------------------------------------------------------

  Future<void> _startCall(
      UserModel user, {
        required bool isVideoCall,
      }) async {
    final presence =
    await ref.read(
      presenceProvider(user.id).future,
    );

    if (!presence.isOnline) {
      _showCallError(
        'This user is currently offline.',
      );
      return;
    }

    final success = await ref
        .read(callControllerProvider.notifier)
        .startCall(
      receiverId: user.id,
      receiverName: user.name,
      isVideoCall: isVideoCall,
    );

    if (!mounted) return;

    if (!success) {
      final error =
          ref.read(callControllerProvider).error ??
              AppStrings.errCallFailed;

      _showCallError(error);
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  void _showCallError(
      String message,
      ) {
    final permanentlyDenied =
        message ==
            AppStrings
                .errPermissionPermanentlyDenied;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: permanentlyDenied
            ? SnackBarAction(
          label: 'Settings',
          onPressed:
          PermissionHelper.openSettings,
        )
            : null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final users =
    ref.watch(filteredUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        children: [
          // -------------------------------------------------------------------
          // SEARCH
          // -------------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              4,
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search people...',
                prefixIcon: Icon(
                  Icons.search,
                ),
                isDense: true,
              ),
              onChanged: (value) {
                ref
                    .read(
                  searchQueryProvider.notifier,
                )
                    .state = value;
              },
            ),
          ),

          // -------------------------------------------------------------------
          // USERS
          // -------------------------------------------------------------------

          Expanded(
            child: users.when(
              loading: () {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              },

              error: (
                  error,
                  stackTrace,
                  ) {
                return Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(24),
                    child: Text(
                      'Could not load users.\n$error',
                      textAlign:
                      TextAlign.center,
                    ),
                  ),
                );
              },

              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder:
                      (context, index) {
                    final user =
                    list[index];

                    return UserTile(
                      user: user,
                      onAudioCall: () =>
                          _startAudioCall(user),
                      onVideoCall: () =>
                          _startVideoCall(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}