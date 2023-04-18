import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

// Models
import '../../home/models/farmer_model.codegen.dart';

// Controllers
import '../../home/controllers/farmer_controller.dart';

// States
import '../../../global/states/future_state.codegen.dart';

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
      () => _ref.read(farmersController).saveFarmerInCache(farmer),
    );
  }
}
