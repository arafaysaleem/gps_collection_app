import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../config/routes/app_router.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

// Controllers
import '../../sampling_modes/controllers/sampling_controller.dart';
import '../controllers/ad_hoc_controller.dart';

// Widgets
import '../../../global/widgets/custom_circular_loader.dart';
import '../../../global/widgets/custom_text_button.dart';
import '../../../global/widgets/custom_dialog.dart';
import '../../../global/widgets/custom_text_field.dart';

class AdHocScreen extends HookConsumerWidget {
  const AdHocScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();

    ref
      ..listen(
        adHocController,
        (_, state) => state.whenOrNull(
          failed: (reason) => CustomDialog.showAlertDialog(
            context: context,
            reason: reason,
            dialogTitle: 'Operation Failed',
          ),
        ),
      )
      ..listen(
        samplingController,
        (_, next) => next.whenOrNull(
          done: (_) => AppRouter.pop(),
        ),
      );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Insets.gapH10,

                // Back arrow
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        AppRouter.pop();
                      },
                    ),

                    Insets.gapW10,

                    // Screen Title
                    Text(
                      'Ad Hoc Sampling',
                      style: AppTypography.primary.heading34.copyWith(
                        color: AppColors.lightPrimaryColor,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),

                Insets.gapH(100),

                // Farmer first name input
                CustomTextField(
                  controller: firstNameController,
                  floatingText: 'First name',
                  floatingStyle: AppTypography.secondary.body16.copyWith(
                    color: Colors.white,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                  ],
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),

                Insets.gapH(45),

                // Farmer last name input
                CustomTextField(
                  controller: lastNameController,
                  floatingText: 'Last name',
                  floatingStyle: AppTypography.secondary.body16.copyWith(
                    color: Colors.white,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                  ],
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),

                Insets.expand,

                // Save Button
                Consumer(
                  builder: (_, ref, child) {
                    final state = ref.watch(adHocController);
                    return CustomTextButton.gradient(
                      width: double.infinity,
                      onPressed: () {
                        if (firstNameController.text.isEmpty ||
                            lastNameController.text.isEmpty) {
                          CustomDialog.showAlertDialog(
                            context: context,
                            reason: 'Please fill all fields',
                            dialogTitle: 'Operation Failed',
                          );
                        } else {
                          ref.read(adHocController.notifier).saveNewFarmer(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                              );
                        }
                      },
                      gradient: AppColors.buttonGradientPrimary,
                      child: state.maybeWhen(
                        loading: () => const CustomCircularLoader(
                          color: Colors.white,
                        ),
                        orElse: () => child!,
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Create',
                      style: AppTypography.secondary.body16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Insets.bottomInsetsLow,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
