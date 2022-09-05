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

class FarmerDataImportWidget extends ConsumerWidget {
  const FarmerDataImportWidget({super.key});

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
    final importComplete = ref.watch(
          farmersController.select(
            (value) => value.whenOrNull(
              data: (_) => true,
            ),
          ),
        ) ??
        false;
    return LabeledWidget(
      label: 'Import farmer data before proceeding.',
      labelGap: Insets.gapH15,
      labelStyle: AppTypography.primary.body16.copyWith(
        color: importComplete
            ? AppColors.textGreyColor
            : AppColors.textWhite80Color,
      ),
      crossAxisAlignment: CrossAxisAlignment.center,
      child: CustomTextButton(
        color: AppColors.primaryColor,
        width: double.infinity,
        disabled: importComplete,
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
                color: importComplete ? Colors.white30 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
