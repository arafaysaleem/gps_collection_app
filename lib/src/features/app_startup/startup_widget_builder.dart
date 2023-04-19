import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Controllers
import '../sampling_modes/controllers/sampling_controller.dart';

// Screens
import '../home/screens/home_screen.dart';
import '../sampling_modes/screens/sampling_modes_screen.dart';

// Widgets
import '../../global/widgets/custom_circular_loader.dart';

class StartupWidgetBuilder extends HookConsumerWidget {
  const StartupWidgetBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(samplingController);
    return state.maybeWhen(
      loading: () => const Scaffold(
        body: Center(
          child: CustomCircularLoader(
            color: Colors.white,
          ),
        ),
      ),
      done: (_) => const HomeScreen(),
      orElse: () => const SamplingModesScreen(),
    );
  }
}
