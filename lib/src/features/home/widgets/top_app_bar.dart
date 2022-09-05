import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../global/widgets/custom_dialog.dart';
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

// Widgets
import '../../../global/widgets/custom_dropdown_field.dart';
import '../../../global/widgets/custom_popup_menu.dart';
import '../../../global/widgets/custom_text_field.dart';
import '../../../global/widgets/labeled_widget.dart';
import '../../../helpers/extensions/context_extensions.dart';
import '../controllers/farmer_controller.dart';
import '../controllers/paddocks_controller.dart';
import '../models/paddock_model.codegen.dart';
import 'note_icon.dart';

class TopAppBar extends HookConsumerWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddockTextController = useTextEditingController();
    final noteTextController = useTextEditingController();
    final nameTextController = useTextEditingController();

    useEffect(() {
      paddockTextController.text =
          ref.read(currentPaddockProvider)?.paddock ?? '';
      final currentFarmer = ref.read(currentFarmerProvider);
      nameTextController.text = currentFarmer != null
          ? '${currentFarmer.first} ${currentFarmer.last}'
          : '';
      return null;
    });

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
                    final paddocks =
                        ref.watch(paddocksController.notifier).getAllPaddocks();
                    return LabeledWidget(
                      label: 'Paddock',
                      child: CustomDropdownField<PaddockModel>.animated(
                        controller: paddockTextController,
                        selectedStyle: AppTypography.primary.body16.copyWith(
                          color: AppColors.textBlackColor,
                        ),
                        hintText: 'Choose paddock',
                        items: {for (var e in paddocks) e.paddock: e},
                        onSelected: (paddock) {
                          ref.read(currentPaddockProvider.notifier).state =
                              paddock;
                        },
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
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Insets.gapH15,

                // Coordinate Counter
                Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  child: const Center(
                    child: Text('25'),
                  ),
                ),

                Insets.expand,

                // Paddock Code
                if (paddockTextController.text.isNotEmpty)
                  Consumer(
                    builder: (_, ref, __) {
                      final currentPaddockCode =
                          ref.watch(currentPaddockProvider)!.code;
                      return Text(
                        currentPaddockCode,
                        style: AppTypography.primary.body16.copyWith(
                          color: AppColors.textWhite80Color,
                        ),
                      );
                    },
                  ),

                Insets.gapH5,

                // Paddock Note and Property Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Paddock note
                    NoteIcon(
                      noteTextController: noteTextController,
                    ),

                    // Farmer property picker
                    CustomPopupMenu(
                      initialValue: 2,
                      items: const {
                        'Farm 1': 1,
                        'Farm 2': 2,
                      },
                      onSelected: (_) {},
                      child: SvgPicture.asset(
                        AppAssets.gpsMultiFarmIcon,
                        width: 20,
                        height: 20,
                        color: Colors.yellow,
                      ),
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
