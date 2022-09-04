import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';

// Widgets
import '../../../global/widgets/custom_popup_menu.dart';
import '../../../global/widgets/labeled_widget.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

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
