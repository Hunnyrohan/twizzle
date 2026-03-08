import 'dart:io';
import 'package:dio/dio.dart';
import 'package:twizzle/core/api/dio_client.dart';

class ApiRemoteSource {
  final DioClient _client;

  ApiRemoteSource(this._client);

  // ✅ REGISTER (MATCHES BACKEND)
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String username,
  ) async {
    final res = await _client.post(
      'auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'username': username,
      },
    );
    return res.data;
  }

  // ✅ LOGIN
  Future<Map<String, dynamic>> login(String identifier, String password, {bool confirmReactivate = false}) async {
    final res = await _client.post(
      'auth/login',
      data: {
        'identifier': identifier,
        'password': password,
        'confirmReactivate': confirmReactivate,
      },
    );
    return res.data;
  }

  // ✅ GET CURRENT USER
  Future<Map<String, dynamic>> getMe() async {
    final res = await _client.get('auth/me');
    return res.data;
  }

  // ✅ FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _client.post(
      'auth/forgot-password',
      data: {'email': email},
    );
    return res.data;
  }

  // ✅ RESET PASSWORD
  Future<Map<String, dynamic>> resetPassword(String resetCode, String newPassword) async {
    final res = await _client.post(
      'auth/reset-password',
      data: {
        'resetCode': resetCode,
        'newPassword': newPassword,
      },
    );
    return res.data;
  }

  // ✅ GOOGLE LOGIN
  Future<Map<String, dynamic>> googleLogin(String idToken, {bool confirmReactivate = false}) async {
    final res = await _client.post(
      'auth/google-login',
      data: {
        'idToken': idToken,
        'confirmReactivate': confirmReactivate,
      },
    );
    return res.data;
  }

  // ✅ GET USER PROFILE
  Future<Map<String, dynamic>> getUserProfile(String username) async {
    final res = await _client.get('users/$username');
    return res.data;
  }

  // ✅ TOGGLE FOLLOW
  Future<Map<String, dynamic>> toggleFollow(String userId) async {
    final res = await _client.post('users/$userId/follow');
    return res.data;
  }

  // ✅ GET FOLLOWERS
  Future<Map<String, dynamic>> getFollowers(String username) async {
    final res = await _client.get('users/$username/followers');
    return res.data;
  }

  // ✅ GET FOLLOWING
  Future<Map<String, dynamic>> getFollowing(String username) async {
    final res = await _client.get('users/$username/following');
    return res.data;
  }

  // ✅ UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? bio,
    String? location,
    String? website,
  }) async {
    final res = await _client.put(
      'users/profile',
      data: {
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (website != null) 'website': website,
      },
    );
    return res.data;
  }

  // ✅ UPLOAD AVATAR
  Future<Map<String, dynamic>> uploadAvatar(File image) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path),
    });
    final res = await _client.post('users/me/avatar', data: formData);
    return res.data;
  }

  // ✅ UPLOAD COVER
  Future<Map<String, dynamic>> uploadCover(File image) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path),
    });
    final res = await _client.post('users/me/cover', data: formData);
    return res.data;
  }

  // ✅ TOGGLE BLOCK
  Future<Map<String, dynamic>> toggleBlock(String userId) async {
    final res = await _client.post('blocks/$userId');
    return res.data;
  }

  // ✅ GET BLOCKS
  Future<Map<String, dynamic>> getBlocks() async {
    final res = await _client.get('blocks/');
    return res.data;
  }

  // ✅ CHANGE PASSWORD
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final res = await _client.post(
      'auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return res.data;
  }

  // ✅ DEACTIVATE ACCOUNT
  Future<Map<String, dynamic>> deactivateAccount() async {
    final res = await _client.post('auth/deactivate');
    return res.data;
  }

  // ✅ LOGOUT ALL SESSIONS
  Future<Map<String, dynamic>> logoutAllSessions() async {
    final res = await _client.post('auth/logout-all');
    return res.data;
  }
}
