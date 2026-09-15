import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/update_checker.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(rootNavigatorKey);

  runApp(const ProviderScope(child: ConnectCallApp()));
}

class ConnectCallApp extends ConsumerStatefulWidget {
  const ConnectCallApp({super.key});

  @override
  ConsumerState<ConnectCallApp> createState() => _ConnectCallAppState();
}

class _ConnectCallAppState extends ConsumerState<ConnectCallApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      UpdateChecker.check(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
