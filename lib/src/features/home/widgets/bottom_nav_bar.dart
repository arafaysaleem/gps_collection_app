import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
import '../../data_import/controllers/data_import_controller.dart';
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
          failed: (reason) => CustomDialog.showAlertDialog(
            context: context,
            reason: reason,
            dialogTitle: 'GPS Operation Failed',
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
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GPS add
          Consumer(
            builder: (_, _ref, __) {
              return _ref.watch(coordinatesController).maybeWhen(
                    loading: () => const CustomCircularLoader(),
                    orElse: () => InkWell(
                      onTap: () => _ref
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
                            size: 22,
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
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const VerticalDivider(
            color: Colors.white,
          ),

          // Email send
          Consumer(
            builder: (_, _ref, __) {
              final state = ref.watch(dataExportController);
              return state.maybeWhen(
                loading: () => const CustomCircularLoader(),
                orElse: () => InkWell(
                  onTap: () => _ref
                      .read(dataExportController.notifier)
                      .exportCoordinatesToExcel(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: LabeledWidget(
                      label: 'Send',
                      labelPosition: LabelPosition.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      child: SvgPicture.asset(
                        AppAssets.emailIcon,
                        width: 20,
                        height: 20,
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

          // Close icon
          InkWell(
            onTap: () {
              ref.read(dataImportController.notifier).erase();
              // if (defaultTargetPlatform == TargetPlatform.android) {
              //   SystemNavigator.pop();
              // } else {
              //   debugger();
              //   exit(0);
              // }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: LabeledWidget(
                label: 'Close',
                labelPosition: LabelPosition.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                child: SvgPicture.asset(
                  AppAssets.closeIcon,
                  width: 20,
                  height: 20,
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
