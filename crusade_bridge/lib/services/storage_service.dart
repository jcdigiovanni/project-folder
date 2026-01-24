import 'package:hive_flutter/hive_flutter.dart';

import '../models/crusade_models.dart';

class StorageService {
  static late Box<Crusade> crusadeBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CrusadeAdapter());
    Hive.registerAdapter(UnitOrGroupAdapter());

    crusadeBox = await Hive.openBox<Crusade>('crusades');
  }

  static Future<void> saveCrusade(Crusade crusade) async {
    await crusadeBox.put(crusade.id, crusade);
  }

  static Crusade? loadCrusade(String id) {
    return crusadeBox.get(id);
  }

  static List<Crusade> loadAllCrusades() {
    return crusadeBox.values.toList();
  }
}