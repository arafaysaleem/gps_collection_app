import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../global/widgets/custom_dialog.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';

// Widgets
import '../../../helpers/constants/app_typography.dart';
import '../controllers/data_import_controller.dart';
import '../states/data_import_state.codegen.dart';
import '../widgets/farmer_data_import_widget.dart';
import '../widgets/paddock_data_import_widget.dart';

class PlannedSamplingScreen extends HookConsumerWidget {
  const PlannedSamplingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(dataImportController.notifier).initImportedData();
        });
        return null;
      },
      [],
    );

    ref.listen<DataImportState>(
      dataImportController,
      (_, importState) => importState.whenOrNull(
        failed: (reason) => CustomDialog.showAlertDialog(
          context: context,
          reason: reason,
          dialogTitle: 'Operation Failed',
        ),
      ),
    );

    final importState = ref.watch(dataImportController);
    return Scaffold(
      body: SafeArea(
        child: importState.maybeWhen(
          orElse: () => Padding(
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
      ),
    );
  }
}
