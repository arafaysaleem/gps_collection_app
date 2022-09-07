import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_styles.dart';

// Controllers
import '../controllers/coordinates_controller.dart';

// Widgets
import 'note_icon.dart';

class CoordinateListItem extends HookConsumerWidget {
  final int i;
  const CoordinateListItem({
    super.key,
    required this.i,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteController = useTextEditingController();
    final coordinate = ref.watch(coordinatesListProvider)[i];

    useEffect(() {
      noteController.text = ref.read(coordinatesListProvider)[i].note;
      return null;
    });

    return Container(
      color: i.isOdd ? Colors.white : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 6,
      ),
      child: Row(
        children: [
          Text(
            '${coordinate.latitude.toStringAsPrecision(8)}, ${coordinate.longitude.toStringAsPrecision(8)}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),

          Insets.expand,

          // Delete
          InkWell(
            onTap: () =>
                ref.read(coordinatesController.notifier).deleteCoordinate(i),
            child: SvgPicture.asset(
              AppAssets.deleteIcon,
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
          ),

          Insets.gapW10,

          // Note
          NoteIcon(
            noteTextController: noteController,
            onSave: () {
              ref.read(coordinatesController.notifier).saveCoordinateNote(
                    index: i,
                    note: noteController.text,
                  );
            },
          ),
        ],
      ),
    );
  }
}
