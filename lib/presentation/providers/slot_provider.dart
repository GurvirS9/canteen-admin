import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/slot.dart';
import 'package:manager_app/data/services/slot_service.dart';
import 'package:manager_app/presentation/providers/shop_provider.dart';

final slotServiceProvider = Provider<SlotService>((ref) => SlotService());

final slotProvider =
    StateNotifierProvider<SlotNotifier, AsyncValue<List<Slot>>>((ref) {
      return SlotNotifier(
        ref.read(slotServiceProvider),
        ref,
      );
    });

class SlotNotifier extends StateNotifier<AsyncValue<List<Slot>>> {
  final SlotService _service;
  final Ref _ref;

  SlotNotifier(this._service, this._ref) : super(const AsyncLoading()) {
    fetchAll();
  }

  String? get _shopId => _ref.read(shopProvider).myShop?.id;

  Future<void> fetchAll() async {
    state = const AsyncLoading();
    try {
      final slots = await _service.fetchAll(shopId: _shopId);
      state = AsyncData(_sortSlots(slots));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  List<Slot> _sortSlots(List<Slot> slots) {
    final sorted = List<Slot>.from(slots);
    sorted.sort((a, b) {
      // 1. Current slots first
      if (a.isCurrent && !b.isCurrent) return -1;
      if (!a.isCurrent && b.isCurrent) return 1;

      // 2. Upcoming slots next
      if (a.isUpcoming && !b.isUpcoming) return -1;
      if (!a.isUpcoming && b.isUpcoming) return 1;

      // 3. Passed slots last
      if (a.isPassed && !b.isPassed) return 1;
      if (!a.isPassed && b.isPassed) return -1;

      // Fallback: sort by start time
      return a.startTime.compareTo(b.startTime);
    });
    return sorted;
  }

  Future<void> update(Slot slot) async {
    try {
      final updated = await _service.update(slot);
      final currentSlots = state.valueOrNull ?? [];
      final newList = currentSlots.map((s) => s.id == updated.id ? updated : s).toList();
      state = AsyncData(_sortSlots(newList));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleOpen(String slotId) async {
    final currentSlots = state.valueOrNull ?? [];
    final slotToUpdate = currentSlots.where((s) => s.id == slotId).firstOrNull;
    if (slotToUpdate == null) return;

    // Optimistic update — flip immediately so the switch feels instant
    final optimistic = slotToUpdate.copyWith(isOpen: !slotToUpdate.isOpen);
    state = AsyncData(_sortSlots(
      currentSlots.map((s) => s.id == slotId ? optimistic : s).toList(),
    ));

    try {
      final confirmed = await _service.toggleOpen(slotId, slotToUpdate);
      final latest = state.valueOrNull ?? [];
      state = AsyncData(_sortSlots(
        latest.map((s) => s.id == confirmed.id ? confirmed : s).toList(),
      ));
    } catch (e, _) {
      // Revert optimistic change on failure
      state = AsyncData(_sortSlots(currentSlots));
    }
  }

  Future<void> create(Slot slot) async {
    try {
      // Auto-populate shopId if not provided
      final slotWithShop = _shopId != null && slot.shopId == null
          ? slot.copyWith(shopId: _shopId)
          : slot;
      final created = await _service.create(slotWithShop);
      final currentSlots = state.valueOrNull ?? [];
      state = AsyncData(_sortSlots([...currentSlots, created]));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _service.delete(id);
      final currentSlots = state.valueOrNull ?? [];
      state = AsyncData(currentSlots.where((s) => s.id != id).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
