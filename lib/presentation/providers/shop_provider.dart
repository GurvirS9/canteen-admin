import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/shop.dart';
import 'package:manager_app/data/services/shop_service.dart';
import 'package:manager_app/core/utils/logger.dart';

class ShopState {
  final AsyncValue<List<Shop>> shops;
  final Shop? myShop; // The shop this manager owns

  const ShopState({
    this.shops = const AsyncLoading(),
    this.myShop,
  });

  ShopState copyWith({
    AsyncValue<List<Shop>>? shops,
    Shop? myShop,
    bool clearMyShop = false,
  }) {
    return ShopState(
      shops: shops ?? this.shops,
      myShop: clearMyShop ? null : (myShop ?? this.myShop),
    );
  }
}

final shopServiceProvider = Provider<ShopService>((ref) => ShopService());

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref.read(shopServiceProvider));
});

class ShopNotifier extends StateNotifier<ShopState> {
  static const String _tag = 'ShopNotifier';
  final ShopService _service;

  ShopNotifier(this._service) : super(const ShopState());

  /// Getter shortcut used by all scoped providers
  String? get shopId => state.myShop?.id;

  Future<void> fetchAll() async {
    state = state.copyWith(shops: const AsyncLoading());
    try {
      final shops = await _service.fetchAll();
      state = state.copyWith(shops: AsyncData(shops));
      AppLogger.i(_tag, 'fetchAll() loaded ${shops.length} shops');
    } catch (e, st) {
      AppLogger.e(_tag, 'fetchAll() failed', e, st);
      state = state.copyWith(shops: AsyncError(e, st));
    }
  }

  /// Load and set myShop by filtering on ownerId
  Future<void> loadMyShop(String ownerId) async {
    AppLogger.i(_tag, 'loadMyShop() ownerId=$ownerId');
    try {
      final shops = state.shops.valueOrNull ?? await _loadShopsIfNeeded();
      final myShop = shops.where((s) => s.ownerId == ownerId).firstOrNull;
      state = state.copyWith(myShop: myShop);
      if (myShop != null) {
        AppLogger.i(_tag, 'loadMyShop() found: ${myShop.name}');
      } else {
        AppLogger.w(_tag, 'loadMyShop() no shop for ownerId=$ownerId');
      }
    } catch (e, st) {
      AppLogger.e(_tag, 'loadMyShop() failed', e, st);
    }
  }

  Future<List<Shop>> _loadShopsIfNeeded() async {
    if (state.shops.valueOrNull != null) return state.shops.valueOrNull!;
    final shops = await _service.fetchAll();
    state = state.copyWith(shops: AsyncData(shops));
    return shops;
  }

  Future<void> toggleShopOpen(String shopId, bool isOpen) async {
    AppLogger.i(_tag, 'toggleShopOpen() $shopId → $isOpen');
    // Optimistic update
    if (state.myShop?.id == shopId) {
      state = state.copyWith(myShop: state.myShop!.copyWith(isOpen: isOpen));
    }
    try {
      final updated = await _service.updateStatus(shopId, isOpen: isOpen);
      if (state.myShop?.id == shopId) {
        state = state.copyWith(myShop: updated);
      }
      // Also update in the shops list
      final list = state.shops.valueOrNull ?? [];
      final newList = list.map((s) => s.id == shopId ? updated : s).toList();
      state = state.copyWith(shops: AsyncData(newList));
    } catch (e, st) {
      AppLogger.e(_tag, 'toggleShopOpen() failed, reverting', e, st);
      // Revert optimistic
      if (state.myShop?.id == shopId) {
        state = state.copyWith(myShop: state.myShop!.copyWith(isOpen: !isOpen));
      }
    }
  }

  Future<void> updateShopHours(
    String shopId, {
    required String openingTime,
    required String closingTime,
  }) async {
    AppLogger.i(_tag, 'updateShopHours() $shopId $openingTime-$closingTime');
    try {
      final updated = await _service.updateStatus(
        shopId,
        openingTime: openingTime,
        closingTime: closingTime,
      );
      if (state.myShop?.id == shopId) {
        state = state.copyWith(myShop: updated);
      }
    } catch (e, st) {
      AppLogger.e(_tag, 'updateShopHours() failed', e, st);
      rethrow;
    }
  }

  Future<void> updateShopDetails(String id, Map<String, dynamic> fields) async {
    AppLogger.i(_tag, 'updateShopDetails() $id');
    try {
      final updated = await _service.update(id, fields);
      if (state.myShop?.id == id) {
        state = state.copyWith(myShop: updated);
      }
    } catch (e, st) {
      AppLogger.e(_tag, 'updateShopDetails() failed', e, st);
      rethrow;
    }
  }
}
