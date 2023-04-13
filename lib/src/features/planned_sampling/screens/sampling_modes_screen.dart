import 'package:flutter/material.dart';

// Router
import '../../../config/routes/app_router.dart';
import '../../../config/routes/routes.dart';

// Helpers
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

// Widgets
import '../../../global/widgets/custom_text_button.dart';
import '../../../global/widgets/labeled_widget.dart';

class SamplingModesScreen extends StatelessWidget {
  const SamplingModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Insets.gapH10,

              // Screen Title
              Text(
                'Welcome to GPS Collection App',
                style: AppTypography.primary.heading34.copyWith(
                  color: AppColors.lightPrimaryColor,
                  fontSize: 45,
                ),
              ),

              Insets.gapH(100),

              // Planned sampling button
              LabeledWidget(
                label: 'Choose if you want to import existing data',
                labelGap: Insets.gapH15,
                labelStyle: AppTypography.primary.body16.copyWith(
                  color: AppColors.textWhite80Color,
                ),
                crossAxisAlignment: CrossAxisAlignment.center,
                child: CustomTextButton(
                  color: AppColors.primaryColor,
                  width: double.infinity,
                  onPressed: () {
                    // Navigate to farmer import screen
                    AppRouter.pushNamed(Routes.PlannedSamplingRoute);
                  },
                  child: Center(
                    child: Text(
                      'Planned Sampling',
                      style: AppTypography.secondary.body16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              Insets.gapH(45),

              // Ad hoc sampling button
              LabeledWidget(
                label: 'Choose if you want to setup new farmer data',
                labelGap: Insets.gapH15,
                labelStyle: AppTypography.primary.body16.copyWith(
                  color: AppColors.textWhite80Color,
                ),
                crossAxisAlignment: CrossAxisAlignment.center,
                child: CustomTextButton(
                  color: AppColors.primaryColor,
                  width: double.infinity,
                  onPressed: () {
                    // Navigate to farmer import screen
                    AppRouter.pushNamed(Routes.AddNewFarmerRoute);
                  },
                  child: Center(
                    child: Text(
                      'Ad-hoc Sampling',
                      style: AppTypography.secondary.body16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              Insets.expand,
            ],
          ),
        ),
      ),
    );
  }
}
