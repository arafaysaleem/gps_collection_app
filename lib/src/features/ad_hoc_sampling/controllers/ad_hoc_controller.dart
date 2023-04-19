import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

// Models
import '../../home/models/farmer_model.codegen.dart';

// Controllers
import '../../home/controllers/farmer_controller.dart';

// States
import '../../../global/states/future_state.codegen.dart';
import '../../sampling_modes/controllers/sampling_controller.dart';
import '../../sampling_modes/enums/sampling_mode.dart';

final adHocController =
    StateNotifierProvider<AdHocController, FutureState<void>>(
  (ref) {
    return AdHocController(ref);
  },
);

class AdHocController extends StateNotifier<FutureState<void>> {
  final Ref _ref;

  AdHocController(this._ref) : super(const FutureState.idle());

  Future<void> saveNewFarmer({
    required String firstName,
    required String lastName,
  }) async {
    state = const FutureState.loading();

    final farmer = FarmerModel(
      pkCID: const Uuid().v4(),
      first: firstName,
      last: lastName,
    );

    state = await FutureState.makeGuardedRequest(
      () async {
        final isSaved =
            await _ref.read(farmersController).saveFarmerInCache(farmer);

        if (!isSaved) {
          throw Exception('Farmer could not be saved');
        }
        
        _ref.read(currentFarmerProvider.notifier).state = farmer;

        return _ref
            .read(samplingController.notifier)
            .saveSamplingInCache(SamplingMode.adHoc);
      },
    );
  }
}
