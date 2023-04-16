import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Controllers
import '../sampling_modes/controllers/sampling_controller.dart';

// Enums
import '../sampling_modes/enums/sampling_mode.dart';

// Screens
import '../ad_hoc_sampling/screens/ad_hoc_screen.dart';
import '../planned_sampling/screens/planned_sampling_screen.dart';
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
      done: (current) => current == SamplingMode.planned
          ? const PlannedSamplingScreen()
          : const AdHocScreen(),
      orElse: () => const SamplingModesScreen(),
    );
  }
}
