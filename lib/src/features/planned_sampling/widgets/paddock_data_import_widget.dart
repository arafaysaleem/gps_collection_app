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

    final farmerLoaded = ref.watch(farmersController).maybeWhen(
          data: (isImported) => isImported,
          orElse: () => false,
        );

    final importState = ref.watch(paddocksController);
    final paddocksLoaded = importState.maybeWhen(
      data: (isImported) => isImported,
      orElse: () => false,
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
        disabled: disablePaddockImport,
        width: double.infinity,
        onPressed: () {
          ref.read(paddocksController.notifier).importPaddocksData();
        },
        child: importState.maybeWhen(
          loading: () => const CustomCircularLoader(
            color: Colors.white,
          ),
          orElse: () => !paddocksLoaded
              ? Center(
                  child: Text(
                    'Import',
                    style: AppTypography.secondary.body16.copyWith(
                      color:
                          disablePaddockImport ? Colors.white30 : Colors.white,
                    ),
                  ),
                )
              : const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
