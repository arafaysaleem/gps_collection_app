import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

// Widgets
import '../../../global/widgets/custom_dropdown_field.dart';
import '../../../global/widgets/custom_popup_menu.dart';
import '../../../global/widgets/custom_text_field.dart';
import '../../../global/widgets/labeled_widget.dart';
import '../../home/widgets/note_icon.dart';

// Controllers
import '../../home/controllers/coordinates_controller.dart';
import '../../home/controllers/properties_controller.dart';
import '../../home/controllers/farmer_controller.dart';
import '../../home/controllers/paddocks_controller.dart';

// Models
import '../../home/models/paddock_model.codegen.dart';

final _propertyPaddocksProvider = Provider<List<PaddockModel>>((ref) {
  final currentPropertyId = ref.watch(currentPropertyProvider);
  return ref
      .watch(paddocksMapProvider)
      .values
      .where((e) => e.propertyId == currentPropertyId)
      .toList();
});

class PlannedAppBar extends HookConsumerWidget {
  const PlannedAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddockTextController = useTextEditingController();
    final noteTextController = useTextEditingController();
    final nameTextController = useTextEditingController();
    final currentPaddock = ref.watch(currentPaddockProvider);

    useEffect(
      () {
        paddockTextController.text = currentPaddock?.paddock ?? '';
        final currentFarmer = ref.read(currentFarmerProvider);
        nameTextController.text = currentFarmer != null
            ? '${currentFarmer.first} ${currentFarmer.last}'
            : '';
        noteTextController.text = ref.read(currentPaddockNoteProvider);
        return null;
      },
      [currentPaddock],
    );

    return Container(
      height: 190,
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Farmer and paddock
          Expanded(
            child: Column(
              children: [
                // Farmer name
                LabeledWidget(
                  label: 'Farmer Name',
                  child: CustomTextField(
                    controller: nameTextController,
                    contentPadding: const EdgeInsets.fromLTRB(12, 15, 1, 15),
                    enabled: false,
                    inputStyle: AppTypography.primary.body16.copyWith(
                      color: AppColors.textBlackColor,
                    ),
                  ),
                ),

                Insets.gapH15,

                // Paddock Dropdowm
                Consumer(
                  builder: (_, ref, __) {
                    final paddocks = ref.watch(_propertyPaddocksProvider);
                    return LabeledWidget(
                      label: 'Paddock',
                      child: CustomDropdownField<PaddockModel>.animated(
                        controller: paddockTextController,
                        selectedStyle: AppTypography.primary.body16.copyWith(
                          color: AppColors.textBlackColor,
                        ),
                        hintText: 'Choose paddock',
                        items: {for (var e in paddocks) e.paddock: e},
                        onSelected: ref
                            .read(paddocksController.notifier)
                            .setCurrentPaddock,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Insets.gapW15,

          // Paddock and coords info
          SizedBox(
            width: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Insets.gapH15,

                // Coordinate Counter
                Consumer(
                  builder: (_, ref, __) {
                    final count = ref.watch(coordinateCountProvider);
                    return Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.2,
                        ),
                        color: count < 25
                            ? Colors.red
                            : count < 30
                                ? Colors.orange
                                : Colors.green,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                Insets.expand,

                // Paddock Code
                if (currentPaddock != null)
                  Text(
                    currentPaddock.code,
                    style: AppTypography.primary.body16.copyWith(
                      color: AppColors.textWhite80Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                Insets.gapH5,

                // Paddock Note and Property Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Paddock note
                    if (currentPaddock != null)
                      NoteIcon(
                        noteTextController: noteTextController,
                        onSave: () => ref
                            .read(paddocksController.notifier)
                            .setCurrentPaddockNote(noteTextController.text),
                        onCancel: () {
                          noteTextController.text =
                              ref.read(currentPaddockNoteProvider);
                        },
                      ),

                    // Farmer property picker
                    Consumer(
                      builder: (_, ref, __) {
                        final currentProperty =
                            ref.watch(currentPropertyProvider);
                        final properties =
                            ref.watch(propertiesController).getAllProperties();
                        return properties.length == 1
                            ? Insets.shrink
                            : CustomPopupMenu<String>(
                                initialValue: currentProperty,
                                items: {for (var e in properties) e: e},
                                onSelected: (property) => ref
                                    .read(propertiesController)
                                    .setCurrentProperty(property),
                                child: SvgPicture.asset(
                                  AppAssets.gpsMultiFarmIcon,
                                  width: 24,
                                  height: 24,
                                  color: Colors.yellow,
                                ),
                              );
                      },
                    ),
                  ],
                ),

                Insets.gapH5,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
