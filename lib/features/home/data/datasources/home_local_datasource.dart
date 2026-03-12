import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/item_model.dart';

abstract class HomeLocalDataSource {
  Future<List<ItemModel>> getCachedItems();
  Future<void> cacheItems(List<ItemModel> items);
}

const _cachedItemsKey = 'CACHED_ITEMS';

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences prefs;
  HomeLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<ItemModel>> getCachedItems() async {
    final jsonString = prefs.getString(_cachedItemsKey);
    if (jsonString == null) throw const CacheException(message: 'No cached items found');
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((e) => ItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> cacheItems(List<ItemModel> items) async {
    await prefs.setString(_cachedItemsKey, json.encode(items.map((i) => i.toJson()).toList()));
  }
}
