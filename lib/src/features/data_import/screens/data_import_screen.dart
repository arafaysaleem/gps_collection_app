import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Helpers
import '../../../helpers/constants/app_styles.dart';

// Widgets
import '../widgets/farmer_data_import_widget.dart';
import '../widgets/paddock_data_import_widget.dart';

class DataImportScreen extends ConsumerWidget {
  const DataImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Farmer data importer
            FarmerDataImportWidget(),

            Insets.gapH30,

            // Paddock data import button
            PaddocksDataImportWidget(),
          ],
        ),
      ),
    );
  }
}
