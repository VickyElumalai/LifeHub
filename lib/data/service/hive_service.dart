import 'package:hive/hive.dart';

class HiveService {
  // Generic method to save data
  static Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
  }

  // Generic method to get data
  static Future<dynamic> getData(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    return box.get(key);
  }

  // Generic method to get all data
  static Future<List<dynamic>> getAllData(String boxName) async {
    final box = await Hive.openBox(boxName);
    return box.values.toList();
  }

  // Generic method to delete data
  static Future<void> deleteData(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }

  // Generic method to clear box
  static Future<void> clearBox(String boxName) async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}