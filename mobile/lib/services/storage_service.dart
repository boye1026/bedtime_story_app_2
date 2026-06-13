// mobile/lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';
import '../models/user.dart';

class StorageService {
  SharedPreferences? _prefs;
  static const String _keyFavorites = 'favorites_stories';
  static const String _keyUser = 'user_info';
  static const String _keyChildInfo = 'child_info';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<Story>> getFavorites() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_keyFavorites);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Story.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveFavorites(List<Story> stories) async {
    try {
      final prefs = await _preferences;
      final jsonString = jsonEncode(stories.map((s) => s.toJson()).toList());
      return prefs.setString(_keyFavorites, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<bool> addFavorite(Story story) async {
    try {
      final favorites = await getFavorites();
      if (favorites.any((s) => s.id == story.id)) return true;
      final favoritedStory = story.copyWith(isFavorited: true);
      favorites.insert(0, favoritedStory);
      return saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(String storyId) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((s) => s.id == storyId);
      return saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFavorited(String storyId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((s) => s.id == storyId);
    } catch (e) {
      return false;
    }
  }

  Future<User?> getUser() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_keyUser);
      if (jsonString == null || jsonString.isEmpty) return null;
      return User.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveUser(User user) async {
    try {
      final prefs = await _preferences;
      final jsonString = jsonEncode(user.toJson());
      return prefs.setString(_keyUser, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUser(Map<String, dynamic> updates) async {
    try {
      final user = await getUser();
      if (user == null) return false;
      if (updates.containsKey('nickname')) user.nickname = updates['nickname'] as String;
      if (updates.containsKey('isVip')) user.isVip = updates['isVip'] as bool;
      if (updates.containsKey('vipExpireDate')) user.vipExpireDate = updates['vipExpireDate'] as DateTime?;
      if (updates.containsKey('freeCountToday')) user.freeCountToday = updates['freeCountToday'] as int;
      return saveUser(user);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getChildInfo() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_keyChildInfo);
      if (jsonString == null || jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveChildInfo(Map<String, dynamic> childInfo) async {
    try {
      final prefs = await _preferences;
      final jsonString = jsonEncode(childInfo);
      return prefs.setString(_keyChildInfo, jsonString);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAll() async {
    final prefs = await _preferences;
    return prefs.clear();
  }
}
