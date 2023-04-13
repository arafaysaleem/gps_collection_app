import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time/time.dart';

// States
import '../../../global/states/future_state.codegen.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';

// Widgets
import '../../../global/widgets/custom_circular_loader.dart';
import '../../../global/widgets/custom_dialog.dart';
import '../../../global/widgets/custom_popup_menu.dart';
import '../../../global/widgets/labeled_widget.dart';

// Controllers
import '../../../helpers/constants/app_utils.dart';
import '../../planned_sampling/controllers/data_import_controller.dart';
import '../controllers/coordinates_controller.dart';
import '../controllers/data_export_controller.dart';
import '../controllers/farmer_controller.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..listen<FutureState<bool>>(
        coordinatesController,
        (_, state) => state.whenOrNull(
          failed: (reason) => AppUtils.showFlushBar(
            context: context,
            message: reason,
          ),
        ),
      )
      ..listen<FutureState<void>>(
        dataExportController,
        (_, state) => state.whenOrNull(
          failed: (reason) => CustomDialog.showAlertDialog(
            context: context,
            reason: reason,
            dialogTitle: 'Data Export Failed',
          ),
        ),
      );
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GPS add
          Consumer(
            builder: (_, ref, __) {
              return ref.watch(coordinatesController).maybeWhen(
                    loading: () => const CustomCircularLoader(),
                    orElse: () => InkWell(
                      onTap: () => ref
                          .read(coordinatesController.notifier)
                          .fetchAndSaveCoordinate(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: LabeledWidget(
                          label: 'Point',
                          labelPosition: LabelPosition.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          child: Icon(
                            Icons.place,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
            },
          ),

          const VerticalDivider(
            color: Colors.white,
          ),

          // Tool chooser
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: CustomPopupMenu<String>(
              initialValue: ref.watch(currentToolProvider),
              items: const {
                'Pogo': 'Pogo',
                'Auger': 'Auger',
              },
              onSelected: (tool) =>
                  ref.read(currentToolProvider.notifier).state = tool,
              child: LabeledWidget(
                label: 'Tool',
                labelPosition: LabelPosition.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                child: SvgPicture.asset(
                  AppAssets.toolsIcon,
                  width: 34,
                  height: 34,
                  theme: const SvgTheme(
                    currentColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const VerticalDivider(
            color: Colors.white,
          ),

          // Email send
          Consumer(
            builder: (_, ref, __) {
              final state = ref.watch(dataExportController);
              return state.maybeWhen(
                loading: () => const CustomCircularLoader(),
                orElse: () => InkWell(
                  onTap: () async {
                    AppUtils.showFlushBar(
                      context: context,
                      message:
                          'Converting to excel. This might take a few minutes',
                      icon: Icons.restore_page_outlined,
                      iconColor: Colors.green.shade600,
                    );
                    await Future.delayed(
                      2.seconds,
                      () => ref
                          .read(dataExportController.notifier)
                          .exportCoordinatesToExcel(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: LabeledWidget(
                      label: 'Send',
                      labelPosition: LabelPosition.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      child: SvgPicture.asset(
                        AppAssets.emailIcon,
                        width: 34,
                        height: 34,
                        theme: const SvgTheme(
                          currentColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const VerticalDivider(
            color: Colors.white,
          ),

          // Reset icon
          InkWell(
            onTap: () {
              CustomDialog.showConfirmDialog(
                context: context,
                dialogTitle: 'Reset All Data',
                reason:
                    "This will erase all data you have collected and prepare the app for a fresh soil sampling program.\n\nAre you sure you want to delete all data? You can't undo this.",
                trueButtonText: 'Reset',
                falseButtonText: 'Cancel',
                isDanger: true,
                flipButtons: true,
                onTrueButtonPressed: () {
                  ref.read(dataImportController.notifier).erase();
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: LabeledWidget(
                label: 'Reset',
                labelPosition: LabelPosition.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                child: Icon(
                  Icons.restart_alt,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
