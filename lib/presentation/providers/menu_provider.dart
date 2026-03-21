import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/menu_item.dart';
import 'package:manager_app/data/services/menu_service.dart';

final menuServiceProvider = Provider<MenuService>((ref) => MenuService());

final menuProvider =
    StateNotifierProvider<MenuNotifier, AsyncValue<List<MenuItem>>>((ref) {
      return MenuNotifier(ref.read(menuServiceProvider));
    });

class MenuNotifier extends StateNotifier<AsyncValue<List<MenuItem>>> {
  final MenuService _service;

  MenuNotifier(this._service) : super(const AsyncLoading()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    state = const AsyncLoading();
    try {
      final items = await _service.fetchAll();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> create(MenuItem item) async {
    try {
      final created = await _service.create(item);
      final currentItems = state.valueOrNull ?? [];
      state = AsyncData([...currentItems, created]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> update(MenuItem item) async {
    try {
      final updated = await _service.update(item);
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

  Future<void> toggleAvailability(String id) async {
    try {
      final updated = await _service.toggleAvailability(id);
      final currentItems = state.valueOrNull ?? [];
      state = AsyncData(
        currentItems.map((i) => i.id == updated.id ? updated : i).toList(),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
