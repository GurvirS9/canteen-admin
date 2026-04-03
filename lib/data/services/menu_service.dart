import 'dart:convert';
import 'package:manager_app/data/models/menu_item.dart';
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/data/services/http_client.dart';
import 'package:manager_app/core/utils/logger.dart';

class MenuService {
  static const String _tag = 'MenuService';
  final HttpClient _api = HttpClient();

  Future<List<MenuItem>> fetchAll() async {
    AppLogger.i(_tag, 'fetchAll()');
    final response = await _api.get(AppConstants.menuEndpoint);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final items = data.map((e) => MenuItem.fromJson(e)).toList();
      AppLogger.i(_tag, 'fetchAll() parsed ${items.length} items from API');
      return items;
    }
    AppLogger.e(_tag, 'fetchAll() failed with status ${response.statusCode}');
    throw Exception('Failed to fetch menu (${response.statusCode})');
  }

  Future<MenuItem> create(MenuItem item, {String? localImagePath}) async {
    AppLogger.i(_tag, 'create() ${item.name} | hasImage=${localImagePath != null}');
    final fields = _toFields(item);
    final response = await _api.postMultipart(
      AppConstants.menuEndpoint,
      fields: fields,
      filePath: localImagePath,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final created = MenuItem.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'create() item created: ${created.id}');
      return created;
    }
    AppLogger.e(_tag, 'create() failed with status ${response.statusCode}: ${response.body}');
    throw Exception('Failed to create menu item (${response.statusCode})');
  }

  Future<MenuItem> update(MenuItem item, {String? localImagePath}) async {
    AppLogger.i(_tag, 'update() ${item.id} | hasImage=${localImagePath != null}');
    final fields = _toFields(item);
    final response = await _api.putMultipart(
      AppConstants.menuItemEndpoint(item.id),
      fields: fields,
      filePath: localImagePath,
    );
    if (response.statusCode == 200) {
      final updated = MenuItem.fromJson(jsonDecode(response.body));
      AppLogger.i(_tag, 'update() item updated: ${updated.id}');
      return updated;
    }
    AppLogger.e(_tag, 'update() failed with status ${response.statusCode}: ${response.body}');
    throw Exception('Failed to update menu item (${response.statusCode})');
  }

  Future<void> delete(String id) async {
    AppLogger.i(_tag, 'delete() $id');
    final response = await _api.delete(AppConstants.menuItemEndpoint(id));
    if (response.statusCode != 200 && response.statusCode != 204) {
      AppLogger.e(_tag, 'delete() failed with status ${response.statusCode}');
      throw Exception('Failed to delete menu item (${response.statusCode})');
    }
    AppLogger.i(_tag, 'delete() $id deleted');
  }

  Future<MenuItem> deleteImage(String id) async {
    AppLogger.i(_tag, 'deleteImage() $id');
    final response = await _api.delete(AppConstants.menuItemImageEndpoint(id));
    if (response.statusCode == 200) {
      final updated = MenuItem.fromJson(jsonDecode(response.body)['item']);
      AppLogger.i(_tag, 'deleteImage() image removed for ${updated.id}');
      return updated;
    }
    AppLogger.e(_tag, 'deleteImage() failed with status ${response.statusCode}');
    throw Exception('Failed to delete image (${response.statusCode})');
  }

  Future<MenuItem> toggleAvailability(String id, MenuItem currentItem) async {
    final updatedItem = currentItem.copyWith(isAvailable: !currentItem.isAvailable);
    return update(updatedItem);
  }

  Map<String, String> _toFields(MenuItem item) => {
        'name': item.name,
        'description': item.description,
        'price': item.price.toStringAsFixed(2),
        'prepTime': item.prepTime.toString(),
        'isVeg': item.isVeg.toString(),
        'avgDemand': '0',
      };
}
