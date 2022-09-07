import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Controllers
import '../controllers/coordinates_controller.dart';

// Widgets
import 'coordinate_list_item.dart';

class CoordinatesList extends HookConsumerWidget {
  const CoordinatesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinates = ref.watch(coordinatesListProvider);
    return ColoredBox(
      color: Colors.white,
      child: ListView.builder(
        itemCount: coordinates.length,
        padding: EdgeInsets.zero,
        itemBuilder: (_, i) => CoordinateListItem(i: i),
      ),
    );
  }
}
