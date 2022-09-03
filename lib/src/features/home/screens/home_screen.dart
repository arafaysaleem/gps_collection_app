import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../global/widgets/custom_popup_menu.dart';
import '../../../global/widgets/custom_text_field.dart';
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

// Widgets
import '../../../global/widgets/custom_dropdown_field.dart';
import '../../../global/widgets/labeled_widget.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Paddock and Farmer name
          _TopAppBar(),

          // Coordinate table
          Expanded(
            child: _CoordinatesList(),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _CoordinatesList extends StatelessWidget {
  const _CoordinatesList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      padding: EdgeInsets.zero,
      itemBuilder: (_, i) => Container(
        color: i.isOdd ? Colors.white : Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),
        child: Row(
          children: [
            const Text(
              'long, lat',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),

            Insets.expand,

            // Delete
            const Icon(
              Icons.delete,
              color: Colors.grey,
            ),

            Insets.gapW10,

            // Note
            SvgPicture.asset(
              AppAssets.noteIcon,
              width: 24,
              height: 24,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}

class _TopAppBar extends HookConsumerWidget {
  static const paddocks = {
    'Paddock A': 'A12345',
    'Paddock B': 'B12345',
    'Paddock C': 'C12345',
    'Paddock D': 'D12345',
  };

  const _TopAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddockController = useTextEditingController();
    final nameController = useTextEditingController(text: 'Farmer Name');
    final currentPaddock = useState<String?>(null);
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
                    controller: nameController,
                    contentPadding: const EdgeInsets.fromLTRB(12, 15, 1, 15),
                    enabled: false,
                    inputStyle: AppTypography.primary.body16.copyWith(
                      color: AppColors.textBlackColor,
                    ),
                  ),
                ),

                Insets.gapH(7),

                // Paddock Dropdowm
                LabeledWidget(
                  label: 'Paddock',
                  child: CustomDropdownField<String>.animated(
                    controller: paddockController,
                    selectedStyle: AppTypography.primary.body16.copyWith(
                      color: AppColors.textBlackColor,
                    ),
                    hintText: 'Choose paddock',
                    items: paddocks,
                    onSelected: (paddock) {
                      if (paddock == null) {
                        paddockController.value = TextEditingValue.empty;
                      }
                      currentPaddock.value = paddock;
                    },
                  ),
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
                if (currentPaddock.value != null)
                  Text(
                    currentPaddock.value!,
                    style: AppTypography.primary.body16.copyWith(
                      color: AppColors.textWhite80Color,
                    ),
                  ),

                Insets.gapH5,

                // Paddock Note and Property Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Paddock note
                    SvgPicture.asset(
                      AppAssets.noteIcon,
                      width: 20,
                      height: 20,
                      color: Colors.white,
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GPS add
          const Padding(
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

          const VerticalDivider(
            color: Colors.white,
          ),

          // Tool chooser
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: CustomPopupMenu(
              initialValue: 2,
              items: const {
                'Pogo': 1,
                'Auger': 2,
              },
              onSelected: (_) {},
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
          Padding(
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

          const VerticalDivider(
            color: Colors.white,
          ),

          // Close icon
          Padding(
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
        ],
      ),
    );
  }
}
