import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_styles.dart';

// Widgets
import 'note_icon.dart';

class CoordinatesList extends HookWidget {
  const CoordinatesList({super.key});

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
            SvgPicture.asset(
              AppAssets.deleteIcon,
              width: 24,
              height: 24,
              color: Colors.grey,
            ),

            Insets.gapW10,

            // Note
            NoteIcon(
              noteTextController: useTextEditingController(),
            ),
          ],
        ),
      ),
    );
  }
}
