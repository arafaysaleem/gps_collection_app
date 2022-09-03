// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

// Controllers
import '../../home/controllers/farmer_controller.dart';
import '../../home/controllers/paddocks_controller.dart';
import '../controllers/data_import_controller.dart';

// States
import '../../../global/states/future_state.codegen.dart';
import '../states/data_import_state.codegen.dart';

// Widgets
import '../../../global/widgets/custom_circular_loader.dart';
import '../../../global/widgets/custom_dialog.dart';
import '../../../global/widgets/custom_text_button.dart';
import '../../../global/widgets/labeled_widget.dart';

class DataImportScreen extends ConsumerWidget {
  const DataImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      body: Center(
        child: Column(
          children: const [
            // Farmer data importer
            _FarmerDataImportWidget(),

            Insets.gapH30,

            // Paddock data import button
            _PaddocksDataImportWidget(),
          ],
        ),
      ),
    );
  }
}

class _FarmerDataImportWidget extends ConsumerWidget {
  const _FarmerDataImportWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<FutureState<bool?>>(
      farmersController,
      (_, state) => state.whenOrNull(
        failed: (reason) => CustomDialog.showAlertDialog(
          context: context,
          reason: reason,
          dialogTitle: 'Operation Failed',
        ),
      ),
    );

    return LabeledWidget(
      label: 'Please import farmer data before proceeding.',
      crossAxisAlignment: CrossAxisAlignment.center,
      child: CustomTextButton(
        color: AppColors.primaryColor,
        width: double.infinity,
        disabled: ref.watch(
          farmersController.select(
            (value) => value.whenOrNull(
              data: (_) => true,
            ),
          ),
        ),
        onPressed: () {
          ref.read(farmersController.notifier).importFarmerData();
        },
        child: Consumer(
          builder: (context, ref, child) {
            final futureState = ref.watch(farmersController);
            return futureState.maybeWhen(
              loading: () => const CustomCircularLoader(
                color: Colors.white,
              ),
              data: (_) => const Icon(
                Icons.check,
                color: Colors.white,
              ),
              orElse: () => child!,
            );
          },
          child: Center(
            child: Text(
              'Import',
              style: AppTypography.secondary.body16.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaddocksDataImportWidget extends ConsumerWidget {
  const _PaddocksDataImportWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<FutureState<bool?>>(
      paddocksController,
      (_, state) => state.whenOrNull(
        failed: (reason) => CustomDialog.showAlertDialog(
          context: context,
          reason: reason,
          dialogTitle: 'Operation Failed',
        ),
      ),
    );

    final farmerLoaded = ref.watch(
      farmersController.select(
        (value) => value.maybeWhen(
          data: (_) => true,
          orElse: () => false,
        ),
      ),
    );

    final paddocksLoaded = ref.watch(
      paddocksController.select(
        (value) => value.maybeWhen(
          data: (_) => true,
          orElse: () => false,
        ),
      ),
    );

    return LabeledWidget(
      label: 'Please import paddock data before proceeding.',
      crossAxisAlignment: CrossAxisAlignment.center,
      child: CustomTextButton(
        color: AppColors.primaryColor,
        disabled: !farmerLoaded || paddocksLoaded,
        width: double.infinity,
        onPressed: () async {
          await ref.read(paddocksController.notifier).importPaddocksData();
          await ref
              .read(dataImportController.notifier)
              .saveIsImportedFlagToCache(true);
        },
        child: Consumer(
          builder: (context, ref, child) {
            final futureState = ref.watch(paddocksController);
            return futureState.maybeWhen(
              loading: () => const CustomCircularLoader(
                color: Colors.white,
              ),
              data: (_) => const Icon(
                Icons.check,
                color: Colors.white,
              ),
              orElse: () => child!,
            );
          },
          child: Center(
            child: Text(
              'Import',
              style: AppTypography.secondary.body16.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
