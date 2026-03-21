import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manager_app/data/models/menu_item.dart';
import 'package:manager_app/core/utils/demo_data.dart';
import 'package:manager_app/data/services/api_config.dart';

class MenuService {
  List<MenuItem>? _demoItems;

  List<MenuItem> get _items {
    _demoItems ??= List.from(DemoData.menuItems);
    return _demoItems!;
  }

  Future<List<MenuItem>> fetchAll() async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return List.from(_items);
    }

    final response = await http.get(Uri.parse(ApiConfig.url('/menu')));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MenuItem.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch menu');
  }

  Future<MenuItem> create(MenuItem item) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final newItem = item.copyWith(
        id: 'mi-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      _items.add(newItem);
      return newItem;
    }

    final response = await http.post(
      Uri.parse(ApiConfig.url('/menu')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode == 201) {
      return MenuItem.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create menu item');
  }

  Future<MenuItem> update(MenuItem item) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final idx = _items.indexWhere((e) => e.id == item.id);
      if (idx != -1) {
        _items[idx] = item;
      }
      return item;
    }

    final response = await http.put(
      Uri.parse(ApiConfig.url('/menu/${item.id}')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode == 200) {
      return MenuItem.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update menu item');
  }

  Future<void> delete(String id) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      _items.removeWhere((e) => e.id == id);
      return;
    }

    final response = await http.delete(Uri.parse(ApiConfig.url('/menu/$id')));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete menu item');
    }
  }

  Future<MenuItem> toggleAvailability(String id) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(
          isAvailable: !_items[idx].isAvailable,
        );
        return _items[idx];
      }
      throw Exception('Item not found');
    }

    final response = await http.put(
      Uri.parse(ApiConfig.url('/menu/$id/toggle')),
    );
    if (response.statusCode == 200) {
      return MenuItem.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to toggle availability');
  }
}
