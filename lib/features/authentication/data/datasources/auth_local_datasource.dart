import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
  Future<bool> isUserLoggedIn();
  Future<void> setUserLoggedIn(bool isLoggedIn);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(AppConstants.cachedUser);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return UserModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(AppConstants.cachedUser, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(AppConstants.cachedUser);
      await sharedPreferences.setBool(AppConstants.isUserLoggedIn, false);
    } catch (e) {
      throw CacheException('Failed to clear cached user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return sharedPreferences.getBool(AppConstants.isUserLoggedIn) ?? false;
    } catch (e) {
      throw CacheException('Failed to check login status: ${e.toString()}');
    }
  }

  @override
  Future<void> setUserLoggedIn(bool isLoggedIn) async {
    try {
      await sharedPreferences.setBool(AppConstants.isUserLoggedIn, isLoggedIn);
    } catch (e) {
      throw CacheException('Failed to set login status: ${e.toString()}');
    }
  }
}
