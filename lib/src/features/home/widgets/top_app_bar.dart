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
import '../controllers/coordinates_controller.dart';
import 'note_icon.dart';

// Controllers
import '../controllers/properties_controller.dart';
import '../controllers/farmer_controller.dart';
import '../controllers/paddocks_controller.dart';

// Models
import '../models/paddock_model.codegen.dart';

final _propertyPaddocksProvider = Provider<List<PaddockModel>>((ref) {
  final currentPropertyId = ref.watch(currentPropertyProvider);
  return ref
      .watch(paddocksController.notifier)
      .getAllPaddocks()
      .where((e) => e.propertyId == currentPropertyId)
      .toList();
});

class TopAppBar extends HookConsumerWidget {
  const TopAppBar({super.key});

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
        noteTextController.text = ref.read(coreNoteProvider);
        return null;
      },
      [currentPaddock],
    );

    return Container(
      height: 173,
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

                Insets.gapH(7),

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
                        onSelected: (paddock) => ref
                            .read(currentPaddockProvider.notifier)
                            .state = paddock,
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
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Insets.gapH15,

                // Coordinate Counter
                Consumer(
                  builder: (_, ref, __) {
                    final count = ref.watch(coordinateCountProvider);
                    return Container(
                      height: 50,
                      width: 50,
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
                    style: AppTypography.primary.subtitle13.copyWith(
                      color: AppColors.textWhite80Color,
                    ),
                  ),

                Insets.gapH5,

                // Paddock Note and Property Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Paddock note
                    NoteIcon(
                      noteTextController: noteTextController,
                      onSave: () {
                        ref.read(coreNoteProvider.notifier).state =
                            noteTextController.text;
                      },
                      onCancel: () {
                        noteTextController.text = ref.read(coreNoteProvider);
                      },
                    ),

                    // Farmer property picker
                    Consumer(
                      builder: (_, ref, __) {
                        final currentProperty =
                            ref.watch(currentPropertyProvider);
                        final properties =
                            ref.watch(propertiesController).getAllProperties();
                        return CustomPopupMenu<String>(
                          initialValue: currentProperty,
                          items: {for (var e in properties) e: e},
                          onSelected: (property) {
                            ref.read(currentPropertyProvider.notifier).state =
                                property;
                            ref.invalidate(currentPaddockProvider);
                          },
                          child: SvgPicture.asset(
                            AppAssets.gpsMultiFarmIcon,
                            width: 20,
                            height: 20,
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
