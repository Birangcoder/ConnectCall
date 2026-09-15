import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/block_service.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/call_actions.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isBlocked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockStatus();
  }

  Future<void> _loadBlockStatus() async {
    try {
      final blocked = await BlockService.instance.isUserBlocked(widget.user.id);

      if (!mounted) return;

      setState(() {
        _isBlocked = blocked;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _blockUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Block User?'),
          content: Text(
            'You will no longer receive calls from '
            '${widget.user.name}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Block'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await BlockService.instance.blockUser(widget.user.id);

      if (!mounted) return;

      setState(() {
        _isBlocked = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.user.name} blocked')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to block user: $e')));
    }
  }

  Future<void> _unblockUser() async {
    try {
      await BlockService.instance.unblockUser(widget.user.id);

      if (!mounted) return;

      setState(() {
        _isBlocked = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.user.name} unblocked')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unblock user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final presence = ref.watch(presenceProvider(widget.user.id));

    final isOnline = presence.when(
      loading: () => false,
      error: (_, _) => false,
      data: (state) => state.isOnline,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 32),

                Center(
                  child: AppAvatar(
                    name: widget.user.name,
                    photoUrl: widget.user.photoUrl,
                    radius: 50,
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Column(
                    children: [
                      Text(
                        widget.user.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline
                              ? AppColors.online
                              : AppColors.offline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_isBlocked)
                        CallActions(user: widget.user),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Divider(),

                ListTile(
                  leading: Icon(
                    _isBlocked ? Icons.block : Icons.block_outlined,
                  ),
                  title: Text(_isBlocked ? 'Unblock User' : 'Block User'),
                  subtitle: Text(
                    _isBlocked
                        ? 'Allow calls from this user again'
                        : 'Prevent this user from calling you',
                  ),
                  onTap: _isBlocked ? _unblockUser : _blockUser,
                ),
              ],
            ),
    );
  }
}
