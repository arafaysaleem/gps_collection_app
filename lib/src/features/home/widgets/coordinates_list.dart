import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_styles.dart';

// Widgets
import '../controllers/coordinates_controller.dart';
import 'note_icon.dart';

class CoordinatesList extends HookConsumerWidget {
  const CoordinatesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteController = useTextEditingController();
    final coordinates =
        ref.watch(coordinatesController.notifier).getAllCoordinates();
    return ListView.builder(
      itemCount: coordinates.length,
      padding: EdgeInsets.zero,
      itemBuilder: (_, i) => Container(
        color: i.isOdd ? Colors.white : Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),
        child: Row(
          children: [
            Text(
              '${coordinates[i].latitude}, ${coordinates[i].longitude}',
              style: const TextStyle(
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
              noteTextController: noteController,
            ),
          ],
        ),
      ),
    );
  }
}
