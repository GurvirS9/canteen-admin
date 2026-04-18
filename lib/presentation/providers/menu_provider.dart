import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/menu_item.dart';
import 'package:manager_app/data/services/menu_service.dart';
import 'package:manager_app/presentation/providers/shop_provider.dart';


final menuServiceProvider = Provider<MenuService>((ref) => MenuService());

final menuProvider =
    StateNotifierProvider<MenuNotifier, AsyncValue<List<MenuItem>>>((ref) {
      final shopId = ref.watch(shopProvider).myShop?.id;
      return MenuNotifier(ref.read(menuServiceProvider), shopId);
    });

class MenuNotifier extends StateNotifier<AsyncValue<List<MenuItem>>> {
  final MenuService _service;
  final String? shopId;

  MenuNotifier(this._service, this.shopId) : super(const AsyncLoading()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    state = const AsyncLoading();
    try {
      if (shopId == null) {
        state = const AsyncData([]);
        return;
      }
      final items = await _service.fetchAll(shopId: shopId);
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// [localImagePath] — absolute path to a locally picked image file (nullable).
  Future<void> create(MenuItem item, {String? localImagePath}) async {
    try {
      final created = await _service.create(item, localImagePath: localImagePath);
      final currentItems = state.valueOrNull ?? [];
      state = AsyncData([...currentItems, created]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// [localImagePath] — absolute path to a locally picked image file (nullable).
  /// Null means "don't change the image".
  Future<void> update(MenuItem item, {String? localImagePath}) async {
    try {
      final updated = await _service.update(item, localImagePath: localImagePath);
      final currentItems = state.valueOrNull ?? [];
      state = AsyncData(
        currentItems.map((i) => i.id == updated.id ? updated : i).toList(),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _service.delete(id);
      final currentItems = state.valueOrNull ?? [];
      state = AsyncData(currentItems.where((i) => i.id != id).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteImage(String id) async {
    try {
      final updated = await _service.deleteImage(id);
      final currentItems = state.valueOrNull ?? [];
      state = AsyncData(
        currentItems.map((i) => i.id == updated.id ? updated : i).toList(),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleAvailability(String id) async {
    final currentItems = state.valueOrNull ?? [];
    final itemToUpdate = currentItems.where((i) => i.id == id).firstOrNull;
    if (itemToUpdate == null) return;

    // Optimistic update — flip immediately so the switch feels instant
    final optimistic = itemToUpdate.copyWith(isAvailable: !itemToUpdate.isAvailable);
    state = AsyncData(
      currentItems.map((i) => i.id == id ? optimistic : i).toList(),
    );

    try {
      final confirmed = await _service.toggleAvailability(id, itemToUpdate);
      final latest = state.valueOrNull ?? [];
      state = AsyncData(
        latest.map((i) => i.id == confirmed.id ? confirmed : i).toList(),
      );
    } catch (e, _) {
      // Revert optimistic change on failure
      state = AsyncData(currentItems);
    }
  }
}
