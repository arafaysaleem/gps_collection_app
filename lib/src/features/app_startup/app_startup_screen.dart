import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Providers

// Widgets
import '../../helpers/constants/app_utils.dart';
import '../../global/widgets/custom_circular_loader.dart';
import 'auth_widget_builder.dart';

final _cacheLoaderFutureProvider = FutureProvider.autoDispose<void>(
  (ref) async {
    await Future.wait<void>([
      // ref.watch(authProvider.notifier).loadUserAuthDataInMemory(),
      // ref.watch(interestsProvider).loadInterestsInMemory(),
      // ref.watch(hobbiesProvider).loadHobbiesInMemory(),
      // ref.watch(campusesProvider).loadCampusesInMemory(),
      // ref.watch(programsProvider).loadProgramsInMemory(),
      // ref.watch(studentStatusesProvider).loadStudentStatusesInMemory(),
      // ref.watch(reactionTypesProvider).loadReactionTypesInMemory(),
      // ref.watch(campusSpotsProvider).loadCampusSpotsInMemory(),
      Future.delayed(Durations.slower),
    ]);
  },
);

class AppStartupScreen extends ConsumerWidget {
  const AppStartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheLoaderFuture = ref.watch(_cacheLoaderFutureProvider);
    return cacheLoaderFuture.when(
      data: (_) => const AuthWidgetBuilder(),
      loading: () => const CustomCircularLoader(),
      error: (error, st) => const Scaffold(
        body: Center(
          child: Text('Failed to load farmer data'),
        ),
      ),
    );
  }
}
