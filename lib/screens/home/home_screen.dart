import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/date_formatter.dart';
import '../../providers/call_history_provider.dart';
import '../../providers/user_provider.dart';
import '../contacts/contacts_screen.dart';
import '../history/call_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const ContactsScreen(),
      const CallHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,

        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),

          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Calls',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).asData?.value;

    final history = ref.watch(callHistoryProvider).asData?.value ?? const [];

    final recent = history.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ConnectCall')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hello, ${profile?.name ?? 'there'} 👋',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 4),

          Text(
            'Connect with anyone, anywhere.',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 24),

          Text('Recent calls', style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 8),

          if (recent.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No calls yet — start one from Contacts.'),
                ),
              ),
            )
          else
            ...recent.map((call) {
              return Card(
                child: ListTile(
                  leading: Icon(
                    call.type.name == 'video' ? Icons.videocam : Icons.call,
                    color: call.isMissed ? Colors.red : null,
                  ),

                  title: Text(
                    call.otherUserName,
                    style: TextStyle(color: call.isMissed ? Colors.red : null),
                  ),

                  subtitle: Text(
                    '${call.isOutgoing ? 'Outgoing' : 'Incoming'}'
                    ' · '
                    '${DateFormatter.relativeCallTime(call.timestamp)}',
                  ),

                  trailing: call.isMissed
                      ? const Text(
                          'Missed',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        )
                      : Text(DateFormatter.callDuration(call.duration)),

                  onTap: () async {
                    debugPrint('profile tap: ${call.otherUserId}');

                    final user = await ref
                        .read(userServiceProvider)
                        .getUserById(call.otherUserId);

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
            }),
        ],
      ),
    );
  }
}
