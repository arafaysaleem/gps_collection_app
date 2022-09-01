import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_colors.dart';
import '../../../helpers/constants/app_typography.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 65),

            // Log out icon
            RotatedBox(
              quarterTurns: 2,
              child: InkResponse(
                radius: 26,
                child: const Icon(
                  Icons.logout,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 20),

            // Welcome
            Text(
              'Welcome',
              style: AppTypography.primary.heading34.copyWith(
                color: AppColors.primaryColor,
                fontSize: 45,
              ),
            ),

            const SizedBox(height: 50),

            // User Details
            const Flexible(
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
