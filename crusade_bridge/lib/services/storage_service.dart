import 'package:hive_flutter/hive_flutter.dart';

import '../models/crusade_models.dart';

class StorageService {
  static late Box<Crusade> crusadeBox;
  static late Box<Campaign> campaignBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Crusade adapters
    Hive.registerAdapter(CrusadeAdapter());
    Hive.registerAdapter(UnitOrGroupAdapter());
    Hive.registerAdapter(CrusadeEventAdapter());
    Hive.registerAdapter(RosterAdapter());

    // Register Campaign adapters
    Hive.registerAdapter(CampaignAdapter());
    Hive.registerAdapter(CrusadeCampaignLinkAdapter());

    // Register Game adapters
    Hive.registerAdapter(GameAdapter());
    Hive.registerAdapter(GameAgendaAdapter());
    Hive.registerAdapter(UnitGameStateAdapter());

    crusadeBox = await Hive.openBox<Crusade>('crusades');
    campaignBox = await Hive.openBox<Campaign>('campaigns');
  }

  // Crusade operations
  static Future<void> saveCrusade(Crusade crusade) async {
    await crusadeBox.put(crusade.id, crusade);
  }

  static Crusade? loadCrusade(String id) {
    return crusadeBox.get(id);
  }

  static List<Crusade> loadAllCrusades() {
    return crusadeBox.values.toList();
  }

  static Future<void> deleteCrusade(String id) async {
    await crusadeBox.delete(id);
  }

  // Campaign operations
  static Future<void> saveCampaign(Campaign campaign) async {
    await campaignBox.put(campaign.id, campaign);
  }

  static Campaign? loadCampaign(String id) {
    return campaignBox.get(id);
  }

  static List<Campaign> loadAllCampaigns() {
    return campaignBox.values.toList();
  }

  static Future<void> deleteCampaign(String id) async {
    await campaignBox.delete(id);
  }
}