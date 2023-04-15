import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_typography.dart';
import '../../../helpers/constants/app_styles.dart';

// Widgets
import '../widgets/farmer_data_import_widget.dart';
import '../widgets/paddock_data_import_widget.dart';

class PlannedSamplingScreen extends ConsumerWidget {
  const PlannedSamplingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Insets.gapH10,

              // Screen Title
              Text(
                'Planned Sampling',
                style: AppTypography.primary.heading34.copyWith(
                  color: AppColors.lightPrimaryColor,
                  fontSize: 45,
                ),
              ),

              Insets.gapH(100),

              // Farmer data importer
              const FarmerDataImportWidget(),

              Insets.gapH(45),

              // Paddock data import button
              const PaddocksDataImportWidget(),

              Insets.expand,
            ],
          ),
        ),
      ),
    );
  }
}
