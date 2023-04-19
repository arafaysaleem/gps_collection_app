import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../config/routes/app_router.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_typography.dart';
import '../../../helpers/constants/app_styles.dart';

// Controllers
import '../../sampling_modes/controllers/sampling_controller.dart';

// Widgets
import '../widgets/data_import_widget.dart';

class PlannedSamplingScreen extends ConsumerWidget {
  const PlannedSamplingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      samplingController,
      (_, next) => next.whenOrNull(
          done: (_) => AppRouter.pop(),
        ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Insets.gapH10,

              // Back arrow
              Row(
                children: [
                  const IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: AppRouter.pop,
                  ),

                  Insets.gapW10,

                  // Screen Title
                  Text(
                    'Planned Sampling',
                    style: AppTypography.primary.heading34.copyWith(
                      color: AppColors.lightPrimaryColor,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),

              Insets.gapH(100),

              // Data importer
              const DataImportWidget(),

              Insets.expand,
            ],
          ),
        ),
      ),
    );
  }
}
