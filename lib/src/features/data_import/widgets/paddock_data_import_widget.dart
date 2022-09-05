import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// States
import '../../../global/states/future_state.codegen.dart';

// Widgets
import '../../../global/widgets/custom_circular_loader.dart';
import '../../../global/widgets/custom_dialog.dart';
import '../../../global/widgets/custom_text_button.dart';
import '../../../global/widgets/labeled_widget.dart';

// Helpers
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

// Controllers
import '../../home/controllers/farmer_controller.dart';
import '../../home/controllers/paddocks_controller.dart';
import '../controllers/data_import_controller.dart';

class PaddocksDataImportWidget extends ConsumerWidget {
  const PaddocksDataImportWidget({super.key});

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

    final disablePaddockImport = !farmerLoaded || paddocksLoaded;

    return LabeledWidget(
      label: 'Import paddock data before proceeding.',
      labelGap: Insets.gapH15,
      labelStyle: AppTypography.primary.body16.copyWith(
        color: disablePaddockImport
            ? AppColors.textGreyColor
            : AppColors.textWhite80Color,
      ),
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
                color: disablePaddockImport ? Colors.white30 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
