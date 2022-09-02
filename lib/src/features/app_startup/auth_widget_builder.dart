import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Providers

// Screens
import '../home/screens/home_screen.dart';

class AuthWidgetBuilder extends HookConsumerWidget {
  const AuthWidgetBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HomeScreen();
    // final authState = ref.watch(authProvider);
    // return authState.maybeWhen(
    //   data: (_) => const HomeScreen(),
    //   orElse: () => const WelcomeScreen(),
    // );
  }
}
