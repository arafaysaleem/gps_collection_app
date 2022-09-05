import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Widgets
import '../../../global/widgets/custom_dialog.dart';
import '../../../global/widgets/custom_text_field.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/extensions/context_extensions.dart';

class NoteIcon extends ConsumerWidget {
  final TextEditingController noteTextController;
  const NoteIcon({
    super.key,
    required this.noteTextController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        CustomDialog.showConfirmDialog(
          context: context,
          dialogTitle: 'Add note',
          trueButtonText: 'Save',
          falseButtonText: 'Cancel',
          onTrueButtonPressed: () {},
          onFalseButtonPressed: () {},
          child: CustomTextField(
            controller: noteTextController,
            showFocusedBorder: false,
            autofocus: true,
            multiline: true,
            textAlignVertical: TextAlignVertical.top,
            expands: true,
            height: context.screenHeight * 0.31,
            hintText: "What's the important message?",
            validator: (body) {
              if (body == null || body.isEmpty) {
                return 'Please enter some message';
              }
              return null;
            },
          ),
        );
      },
      child: SvgPicture.asset(
        AppAssets.noteIcon,
        width: 24,
        height: 24,
        color: Colors.grey,
      ),
    );
  }
}
