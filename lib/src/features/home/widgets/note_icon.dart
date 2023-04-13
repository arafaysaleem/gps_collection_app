import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Widgets
import '../../../global/widgets/custom_dialog.dart';
import '../../../global/widgets/custom_text_field.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/extensions/context_extensions.dart';

class NoteIcon extends ConsumerWidget {
  final TextEditingController noteTextController;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final double? size;

  const NoteIcon({
    required this.noteTextController,
    super.key,
    this.onCancel,
    this.size,
    this.onSave,
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
          onTrueButtonPressed: onSave,
          onFalseButtonPressed: onCancel,
          child: SizedBox(
            height: context.screenHeight * 0.31,
            child: CustomTextField(
              controller: noteTextController,
              showFocusedBorder: false,
              textAlignVertical: TextAlignVertical.top,
              autofocus: true,
              multiline: true,
              expands: true,
              height: context.screenHeight * 0.30,
              hintText: 'Enter message...',
            ),
          ),
        );
      },
      child: SvgPicture.asset(
        AppAssets.noteIcon,
        width: size ?? 28,
        height: size ?? 28,
        theme: SvgTheme(
          currentColor: noteTextController.text.isEmpty
              ? Colors.grey
              : AppColors.primaryColor,
        ),
      ),
    );
  }
}
