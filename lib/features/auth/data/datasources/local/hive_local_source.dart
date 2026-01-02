// lib/data/datasources/local/hive_local_source.dart
import 'package:hive/hive.dart';
import '../../models/user_model.dart';

const String _boxName = 'userBox';

class HiveLocalSource {
  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox(_boxName);
    await box.put('user', user.toJson());
  }

  Future<UserModel?> getUser() async {
    final box = await Hive.openBox(_boxName);
    final json = box.get('user');
    return json == null ? null : UserModel.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> clearUser() async {
    final box = await Hive.openBox(_boxName);
    await box.delete('user');
  }
}