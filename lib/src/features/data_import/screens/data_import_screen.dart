import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';

// Widgets
import '../../../helpers/constants/app_typography.dart';
import '../widgets/farmer_data_import_widget.dart';
import '../widgets/paddock_data_import_widget.dart';

class DataImportScreen extends ConsumerWidget {
  const DataImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Screen Title
            Text(
              'Welcome to GPS Collection App',
              style: AppTypography.primary.heading34.copyWith(
                color: AppColors.lightPrimaryColor,
              ),
            ),

            Insets.gapH(70),

            // Farmer data importer
            const FarmerDataImportWidget(),

            Insets.gapH(45),

            // Paddock data import button
            const PaddocksDataImportWidget(),

            Insets.expand,
          ],
        ),
      ),
    );
  }
}
