import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manager_app/data/models/slot.dart';
import 'package:manager_app/core/utils/demo_data.dart';
import 'package:manager_app/data/services/api_config.dart';

class SlotService {
  List<Slot>? _demoSlots;

  List<Slot> get _slots {
    _demoSlots ??= List.from(DemoData.slots);
    return _demoSlots!;
  }

  Future<List<Slot>> fetchAll() async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return List.from(_slots);
    }

    final response = await http.get(Uri.parse(ApiConfig.url('/slots')));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Slot.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch slots');
  }

  Future<Slot> create(Slot slot) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newSlot = slot.copyWith(
        id: 'slot_${DateTime.now().millisecondsSinceEpoch}',
      );
      _slots.add(newSlot);
      return newSlot;
    }

    final response = await http.post(
      Uri.parse(ApiConfig.url('/slots')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(slot.toJson()),
    );
    if (response.statusCode == 201) {
      return Slot.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create slot');
  }

  Future<Slot> update(Slot slot) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _slots.indexWhere((s) => s.id == slot.id);
      if (idx != -1) {
        _slots[idx] = slot;
      }
      return slot;
    }

    final response = await http.put(
      Uri.parse(ApiConfig.url('/slots/${slot.id}')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(slot.toJson()),
    );
    if (response.statusCode == 200) {
      return Slot.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update slot');
  }

  Future<Slot> toggleOpen(String slotId) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final idx = _slots.indexWhere((s) => s.id == slotId);
      if (idx != -1) {
        _slots[idx] = _slots[idx].copyWith(isOpen: !_slots[idx].isOpen);
        return _slots[idx];
      }
      throw Exception('Slot not found');
    }

    final response = await http.put(
      Uri.parse(ApiConfig.url('/slots/$slotId/toggle')),
    );
    if (response.statusCode == 200) {
      return Slot.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to toggle slot');
  }
}
