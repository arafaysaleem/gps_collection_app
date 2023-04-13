import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Controllers
import '../planned_sampling/controllers/data_import_controller.dart';

// Screens
import '../planned_sampling/screens/sampling_modes_screen.dart';
import '../home/screens/home_screen.dart';

final farmerExistsProvider = Provider.autoDispose<bool>((ref) {
  final isDataImported = ref.watch(
    dataImportController.select(
      (value) => value.maybeWhen(
        done: () => true,
        orElse: () => false,
      ),
    ),
  );
  // TODO(arafaysaleem): Check if new farmer initiated
  const isNewFarmerInitiated = false;
  return isDataImported || isNewFarmerInitiated;
});

class StartupWidgetBuilder extends HookConsumerWidget {
  const StartupWidgetBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmerExists = ref.watch(farmerExistsProvider);
    return farmerExists ? const HomeScreen() : const SamplingModesScreen();
  }
}
