import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_assets.dart';
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_styles.dart';
import '../../../helpers/constants/app_typography.dart';
import '../../../helpers/constants/app_utils.dart';
import '../../../helpers/extensions/int_extension.dart';

// Controllers
import '../controllers/data_export_controller.dart';

// Widgets
import '../../../global/widgets/labeled_widget.dart';

class SharePopupMenu extends ConsumerWidget {
  const SharePopupMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<void>(
      elevation: 2,
      padding: EdgeInsets.zero,
      color: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: Corners.rounded20,
      ),
      itemBuilder: (_) => [
        // Email
        PopupMenuItem(
          height: 38,
          onTap: () async {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppUtils.showFlushBar(
                context: context,
                blockBackgroundInteraction: true,
                message: 'Converting to excel. This might take a few minutes',
                icon: Icons.restore_page_outlined,
                iconColor: Colors.green.shade600,
              );
            });
            await Future.delayed(
              2.seconds,
              () => ref.read(dataExportController.notifier).sendEmail(),
            );
          },
          child: Text(
            'Email',
            style: AppTypography.primary.body14,
            maxLines: 1,
          ),
        ),

        // Download
        PopupMenuItem(
          height: 38,
          onTap: () async {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppUtils.showFlushBar(
                context: context,
                blockBackgroundInteraction: true,
                message: 'Converting to excel. This might take a few minutes',
                icon: Icons.restore_page_outlined,
                iconColor: Colors.green.shade600,
              );
            });
            await Future.delayed(
              2.seconds,
              () => ref.read(dataExportController.notifier).downloadFile(),
            );
          },
          child: Text(
            'Download',
            style: AppTypography.primary.body14,
            maxLines: 1,
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: LabeledWidget(
          label: 'Share',
          labelPosition: LabelPosition.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          child: SvgPicture.asset(
            AppAssets.emailIcon,
            width: 34,
            height: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
