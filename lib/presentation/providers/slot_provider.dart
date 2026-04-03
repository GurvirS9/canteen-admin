import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/slot.dart';
import 'package:manager_app/data/services/slot_service.dart';

final slotServiceProvider = Provider<SlotService>((ref) => SlotService());

final slotProvider =
    StateNotifierProvider<SlotNotifier, AsyncValue<List<Slot>>>((ref) {
      return SlotNotifier(ref.read(slotServiceProvider));
    });

class SlotNotifier extends StateNotifier<AsyncValue<List<Slot>>> {
  final SlotService _service;

  SlotNotifier(this._service) : super(const AsyncLoading()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    state = const AsyncLoading();
    try {
      final slots = await _service.fetchAll();
      state = AsyncData(slots);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> update(Slot slot) async {
    try {
      final updated = await _service.update(slot);
      final currentSlots = state.valueOrNull ?? [];
      state = AsyncData(
        currentSlots.map((s) => s.id == updated.id ? updated : s).toList(),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleOpen(String slotId) async {
    try {
      final currentSlots = state.valueOrNull ?? [];
      final slotToUpdate = currentSlots.firstWhere((s) => s.id == slotId);
      final updated = await _service.toggleOpen(slotId, slotToUpdate);
      state = AsyncData(
        currentSlots.map((s) => s.id == updated.id ? updated : s).toList(),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> create(Slot slot) async {
    try {
      final created = await _service.create(slot);
      final currentSlots = state.valueOrNull ?? [];
      state = AsyncData([...currentSlots, created]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
