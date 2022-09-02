import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../global/widgets/custom_dropdown_field.dart';
import '../../../global/widgets/labeled_widget.dart';
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});
  static const paddocks = {
    'Paddock A': 'A12345',
    'Paddock B': 'B12345',
    'Paddock C': 'C12345',
    'Paddock D': 'D12345',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programController = useTextEditingController();
    final currentPaddock = useState<String?>(null);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paddock and Farmer name
          Padding(
            padding: const EdgeInsets.all(20),
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
                        child: CustomDropdownField<String>.animated(
                          controller: programController,
                          hintText: 'Farmer name',
                          items: paddocks,
                          onSelected: (_) {},
                        ),
                      ),

                      Insets.gapH10,

                      // Paddock Dropdowm
                      LabeledWidget(
                        label: 'Paddock',
                        child: CustomDropdownField<String>.animated(
                          controller: programController,
                          hintText: 'Choose paddock',
                          items: paddocks,
                          onSelected: (paddock) {
                            if (paddock == null) {
                              programController.value = TextEditingValue.empty;
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
                      // Coordinate Counter

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
                          SvgPicture.asset(
                            AppAssets.gpsMultiFarmIcon,
                            width: 20,
                            height: 20,
                            color: Colors.yellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          // GPS add
          const BottomNavigationBarItem(
            label: 'Point',
            icon: Icon(
              Icons.place,
              size: 20,
              color: Colors.white,
            ),
          ),

          // Tool chooser
          BottomNavigationBarItem(
            label: 'Tool',
            icon: SvgPicture.asset(
              AppAssets.toolsIcon,
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),

          // Email send
          BottomNavigationBarItem(
            label: 'Send',
            icon: SvgPicture.asset(
              AppAssets.emailIcon,
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),

          // Close icon
          BottomNavigationBarItem(
            label: 'Close',
            icon: SvgPicture.asset(
              AppAssets.closeIcon,
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
