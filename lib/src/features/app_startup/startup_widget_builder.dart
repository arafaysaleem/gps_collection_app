import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Controllers
import '../../global/widgets/custom_circular_loader.dart';
import '../data_import/controllers/data_import_controller.dart';

// Screens
import '../data_import/screens/data_import_screen.dart';
import '../home/screens/home_screen.dart';

class StartupWidgetBuilder extends HookConsumerWidget {
  const StartupWidgetBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(dataImportController);
    return importState.maybeWhen(
      done: () => const HomeScreen(),
      loading: () => const Scaffold(
        body: CustomCircularLoader(),
      ),
      orElse: () => const DataImportScreen(),
    );
  }
}
