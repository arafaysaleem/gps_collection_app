import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Widgets
import '../widgets/bottom_nav_bar.dart';
import '../widgets/coordinates_list.dart';
import '../widgets/top_app_bar.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // Paddock and Farmer name
            TopAppBar(),
      
            // Coordinate table
            Expanded(
              child: CoordinatesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
