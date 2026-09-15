import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/block_service.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: StreamBuilder<List<String>>(
        stream: BlockService.instance.blockedUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load blocked users\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final blockedIds = snapshot.data ?? [];

          if (blockedIds.isEmpty) {
            return const Center(child: Text('No blocked users'));
          }

          return ListView.builder(
            itemCount: blockedIds.length,
            itemBuilder: (context, index) {
              final userId = blockedIds[index];

              return _BlockedUserTile(userId: userId);
            },
          );
        },
      ),
    );
  }
}

class _BlockedUserTile extends StatelessWidget {
  final String userId;

  const _BlockedUserTile({required this.userId});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUser() {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(child: CircularProgressIndicator()),
            title: Text('Loading...'),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Unknown User'),
            trailing: TextButton(
              onPressed: () async {
                await BlockService.instance.unblockUser(userId);
              },
              child: const Text('Unblock'),
            ),
          );
        }

        final data = snapshot.data!.data()!;

        final name = data['name'] as String? ?? 'Unknown User';

        final photoUrl = data['photoUrl'] as String?;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(name),
          trailing: OutlinedButton(
            onPressed: () async {
              await BlockService.instance.unblockUser(userId);

              if (!context.mounted) return;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$name unblocked')));
            },
            child: const Text('Unblock'),
          ),
        );
      },
    );
  }
}
