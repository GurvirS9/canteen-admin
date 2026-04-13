import 'dart:convert';
import 'package:manager_app/data/models/shop.dart';
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/data/services/http_client.dart';
import 'package:manager_app/core/utils/logger.dart';

class ShopService {
  static const String _tag = 'ShopService';
  final HttpClient _api = HttpClient();

  Future<List<Shop>> fetchAll() async {
    AppLogger.i(_tag, 'fetchAll()');
    final response = await _api.get(AppConstants.shopsEndpoint);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final shops = data.map((e) => Shop.fromJson(e as Map<String, dynamic>)).toList();
      AppLogger.i(_tag, 'fetchAll() parsed ${shops.length} shops');
      return shops;
    }
    AppLogger.e(_tag, 'fetchAll() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch shops (${response.statusCode})');
  }

  Future<Shop> fetchById(String id) async {
    AppLogger.i(_tag, 'fetchById() id=$id');
    final response = await _api.get(AppConstants.shopEndpoint(id));
    if (response.statusCode == 200) {
      return Shop.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    AppLogger.e(_tag, 'fetchById() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch shop (${response.statusCode})');
  }

  Future<Shop> create(Shop shop) async {
    AppLogger.i(_tag, 'create() ${shop.name}');
    final response = await _api.post(AppConstants.shopsEndpoint, body: shop.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Shop.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create shop (${response.statusCode})');
  }

  Future<Shop> update(String id, Map<String, dynamic> fields) async {
    AppLogger.i(_tag, 'update() id=$id fields=$fields');
    final response = await _api.patch(AppConstants.shopEndpoint(id), body: fields);
    if (response.statusCode == 200) {
      return Shop.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update shop (${response.statusCode})');
  }

  Future<void> delete(String id) async {
    AppLogger.i(_tag, 'delete() id=$id');
    final response = await _api.delete(AppConstants.shopEndpoint(id));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete shop (${response.statusCode})');
    }
  }

  /// PATCH /shops/:id/status — update isOpen, openingTime, closingTime
  Future<Shop> updateStatus(
    String id, {
    bool? isOpen,
    String? openingTime,
    String? closingTime,
  }) async {
    AppLogger.i(_tag, 'updateStatus() id=$id isOpen=$isOpen');
    final body = <String, dynamic>{};
    if (isOpen != null) body['isOpen'] = isOpen;
    if (openingTime != null) body['openingTime'] = openingTime;
    if (closingTime != null) body['closingTime'] = closingTime;

    final response = await _api.patch(AppConstants.shopStatusEndpoint(id), body: body);
    if (response.statusCode == 200) {
      return Shop.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update shop status (${response.statusCode})');
  }
}
