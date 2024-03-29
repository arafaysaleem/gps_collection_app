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
import '../controllers/data_import_controller.dart';

class DataImportWidget extends ConsumerWidget {
  const DataImportWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<FutureState<bool?>>(
      dataImportController,
      (_, state) => state.whenOrNull(
        failed: (reason) => CustomDialog.showAlertDialog(
          context: context,
          reason: reason,
          dialogTitle: 'Operation Failed',
        ),
      ),
    );
    final dataImportState = ref.watch(dataImportController);
    final importComplete = dataImportState.maybeWhen(
      data: (isImported) => isImported,
      orElse: () => false,
    );
    return LabeledWidget(
      label: 'Import data before proceeding.',
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
        onPressed: ref.read(dataImportController.notifier).importData,
        child: dataImportState.maybeWhen(
          loading: () => const CustomCircularLoader(
            color: Colors.white,
          ),
          orElse: () => !importComplete
              ? Center(
                  child: Text(
                    'Import',
                    style: AppTypography.secondary.body16.copyWith(
                      color: importComplete ? Colors.white30 : Colors.white,
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
