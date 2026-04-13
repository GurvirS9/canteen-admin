import 'dart:convert';
import 'package:manager_app/data/models/slot.dart';
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/data/services/http_client.dart';
import 'package:manager_app/core/utils/logger.dart';

class SlotService {
  static const String _tag = 'SlotService';
  final HttpClient _api = HttpClient();

  Future<List<Slot>> fetchAll({String? shopId}) async {
    AppLogger.i(_tag, 'fetchAll() shopId=${shopId ?? 'all'}');
    final endpoint = shopId != null
        ? '${AppConstants.slotsEndpoint}?shopId=$shopId'
        : AppConstants.slotsEndpoint;
    final response = await _api.get(endpoint);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final slots = data.map((e) => Slot.fromJson(e)).toList();
      AppLogger.i(_tag, 'fetchAll() parsed ${slots.length} slots');
      return slots;
    }
    AppLogger.e(_tag, 'fetchAll() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch slots (${response.statusCode})');
  }

  Future<Slot> create(Slot slot) async {
    AppLogger.i(_tag, 'create() ${slot.label}');
    final response = await _api.post(AppConstants.slotsEndpoint, body: slot.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      final created = Slot.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'create() slot created: ${created.id}');
      return created;
    }
    AppLogger.e(_tag, 'create() failed with status ${response.statusCode}');
    throw Exception('Failed to create slot (${response.statusCode})');
  }

  Future<Slot> update(Slot slot) async {
    AppLogger.i(_tag, 'update() ${slot.id}');
    final response = await _api.put(
      AppConstants.slotEndpoint(slot.id),
      body: slot.toJson(),
    );
    if (response.statusCode == 200) {
      final updated = Slot.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'update() slot updated: ${updated.id}');
      return updated;
    }
    AppLogger.e(_tag, 'update() failed with status ${response.statusCode}');
    throw Exception('Failed to update slot (${response.statusCode})');
  }

  Future<Slot> toggleOpen(String slotId, Slot currentSlot) async {
    final newStatus = currentSlot.isOpen ? 'closed' : 'open';
    AppLogger.i(_tag, 'toggleOpen() $slotId → $newStatus');
    final response = await _api.patch(
      AppConstants.slotStatusEndpoint(slotId),
      body: {'status': newStatus},
    );
    if (response.statusCode == 200) {
      final updated = Slot.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'toggleOpen() done: ${updated.id} is now $newStatus');
      return updated;
    }
    AppLogger.e(_tag, 'toggleOpen() failed with status ${response.statusCode}: ${response.body}');
    throw Exception('Failed to toggle slot status (${response.statusCode})');
  }

  Future<void> delete(String id) async {
    AppLogger.i(_tag, 'delete() $id');
    final response = await _api.delete(AppConstants.slotEndpoint(id));
    if (response.statusCode != 200 && response.statusCode != 204) {
      AppLogger.e(_tag, 'delete() failed with status ${response.statusCode}');
      throw Exception('Failed to delete slot (${response.statusCode})');
    }
    AppLogger.i(_tag, 'delete() $id deleted');
  }
}
