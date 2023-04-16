import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../sampling_modes/enums/sampling_mode.dart';

// Controllers
import '../../sampling_modes/controllers/sampling_controller.dart';

// Widgets
import '../widgets/bottom_nav_bar.dart';
import '../widgets/coordinates_list.dart';
import '../../ad_hoc_sampling/widgets/ad_hoc_app_bar.dart';
import '../../planned_sampling/widgets/planned_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paddock and Farmer name
            Consumer(
              builder: (_, ref, child) {
                final isAdHoc = ref.watch(
                  samplingController.select(
                    (state) => state.maybeWhen(
                      done: (current) => current == SamplingMode.adHoc,
                      orElse: () => false,
                    ),
                  ),
                );
                return isAdHoc ? const AdHocAppBar() : child!;
              },
              child: const PlannedAppBar(),
            ),

            // Coordinate table
            const Expanded(
              child: CoordinatesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
