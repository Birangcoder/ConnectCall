import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(rootNavigatorKey);

  runApp(const ProviderScope(child: ConnectCallApp()));
}

class ConnectCallApp extends ConsumerWidget {
  const ConnectCallApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start presence + ZEGOCLOUD when a Firebase user is available.
    ref.watch(authSessionProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ConnectCall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppDarkTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
