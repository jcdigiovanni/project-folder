// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crusade_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CrusadeAdapter extends TypeAdapter<Crusade> {
  @override
  final int typeId = 0;

  @override
  Crusade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Crusade(
      id: fields[0] as String,
      name: fields[1] as String,
      faction: fields[2] as String,
      detachment: fields[3] as String,
      supplyLimit: fields[4] as int,
      rp: fields[5] as int,
      armyIconPath: fields[6] as String?,
      factionIconAsset: fields[7] as String?,
      oob: (fields[8] as List?)?.cast<UnitOrGroup>(),
      templates: (fields[9] as List?)?.cast<UnitOrGroup>(),
      lastModified: fields[10] as int?,
      usedFirstCharacterEnhancement: fields[11] as bool?,
      history: (fields[12] as List?)?.cast<CrusadeEvent>(),
      rosters: (fields[13] as List?)?.cast<Roster>(),
      games: (fields[14] as List?)?.cast<Game>(),
    );
  }

  @override
  void write(BinaryWriter writer, Crusade obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.faction)
      ..writeByte(3)
      ..write(obj.detachment)
      ..writeByte(4)
      ..write(obj.supplyLimit)
      ..writeByte(5)
      ..write(obj.rp)
      ..writeByte(6)
      ..write(obj.armyIconPath)
      ..writeByte(7)
      ..write(obj.factionIconAsset)
      ..writeByte(8)
      ..write(obj.oob)
      ..writeByte(9)
      ..write(obj.templates)
      ..writeByte(10)
      ..write(obj.lastModified)
      ..writeByte(11)
      ..write(obj.usedFirstCharacterEnhancement)
      ..writeByte(12)
      ..write(obj.history)
      ..writeByte(13)
      ..write(obj.rosters)
      ..writeByte(14)
      ..write(obj.games);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrusadeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitOrGroupAdapter extends TypeAdapter<UnitOrGroup> {
  @override
  final int typeId = 1;

  @override
  UnitOrGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitOrGroup(
      id: fields[0] as String,
      type: fields[1] as String,
      name: fields[2] as String,
      points: fields[4] as int,
      customName: fields[3] as String?,
      components: (fields[5] as List?)?.cast<UnitOrGroup>(),
      modelsCurrent: fields[6] as int,
      modelsMax: fields[7] as int,
      notes: fields[13] as String?,
      statsText: fields[14] as String?,
      isWarlord: fields[15] as bool?,
      isEpicHero: fields[16] as bool?,
      isCharacter: fields[18] as bool?,
      xp: fields[8] as int?,
      honours: (fields[9] as List?)?.cast<String>(),
      scars: (fields[10] as List?)?.cast<String>(),
      enhancements: (fields[17] as List?)?.cast<String>(),
      crusadePoints: fields[11] as int?,
      tallies: (fields[12] as Map?)?.cast<String, int>(),
      pendingRankUp: fields[19] as bool?,
      battleTraits: (fields[20] as List?)?.cast<String>(),
      weaponEnhancements: (fields[21] as List?)?.cast<String>(),
      crusadeRelic: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UnitOrGroup obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.customName)
      ..writeByte(4)
      ..write(obj.points)
      ..writeByte(5)
      ..write(obj.components)
      ..writeByte(6)
      ..write(obj.modelsCurrent)
      ..writeByte(7)
      ..write(obj.modelsMax)
      ..writeByte(8)
      ..write(obj.xp)
      ..writeByte(9)
      ..write(obj.honours)
      ..writeByte(10)
      ..write(obj.scars)
      ..writeByte(11)
      ..write(obj.crusadePoints)
      ..writeByte(12)
      ..write(obj.tallies)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.statsText)
      ..writeByte(15)
      ..write(obj.isWarlord)
      ..writeByte(16)
      ..write(obj.isEpicHero)
      ..writeByte(17)
      ..write(obj.enhancements)
      ..writeByte(18)
      ..write(obj.isCharacter)
      ..writeByte(19)
      ..write(obj.pendingRankUp)
      ..writeByte(20)
      ..write(obj.battleTraits)
      ..writeByte(21)
      ..write(obj.weaponEnhancements)
      ..writeByte(22)
      ..write(obj.crusadeRelic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitOrGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CrusadeEventAdapter extends TypeAdapter<CrusadeEvent> {
  @override
  final int typeId = 2;

  @override
  CrusadeEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CrusadeEvent(
      id: fields[0] as String,
      timestamp: fields[1] as int,
      type: fields[2] as String,
      description: fields[3] as String,
      unitId: fields[4] as String?,
      unitName: fields[5] as String?,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CrusadeEvent obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.unitId)
      ..writeByte(5)
      ..write(obj.unitName)
      ..writeByte(6)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrusadeEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RosterAdapter extends TypeAdapter<Roster> {
  @override
  final int typeId = 3;

  @override
  Roster read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Roster(
      id: fields[0] as String,
      name: fields[1] as String,
      unitIds: (fields[2] as List?)?.cast<String>(),
      createdAt: fields[3] as int?,
      lastModified: fields[4] as int?,
      timesDeployed: fields[5] as int,
      wins: fields[6] as int,
      losses: fields[7] as int,
      draws: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Roster obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unitIds)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.lastModified)
      ..writeByte(5)
      ..write(obj.timesDeployed)
      ..writeByte(6)
      ..write(obj.wins)
      ..writeByte(7)
      ..write(obj.losses)
      ..writeByte(8)
      ..write(obj.draws);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RosterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CrusadeCampaignLinkAdapter extends TypeAdapter<CrusadeCampaignLink> {
  @override
  final int typeId = 8;

  @override
  CrusadeCampaignLink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CrusadeCampaignLink(
      crusadeId: fields[0] as String,
      crusadeName: fields[1] as String,
      faction: fields[2] as String,
      gamesPlayed: fields[3] as int,
      wins: fields[4] as int,
      losses: fields[5] as int,
      draws: fields[6] as int,
      joinedAt: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CrusadeCampaignLink obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.crusadeId)
      ..writeByte(1)
      ..write(obj.crusadeName)
      ..writeByte(2)
      ..write(obj.faction)
      ..writeByte(3)
      ..write(obj.gamesPlayed)
      ..writeByte(4)
      ..write(obj.wins)
      ..writeByte(5)
      ..write(obj.losses)
      ..writeByte(6)
      ..write(obj.draws)
      ..writeByte(7)
      ..write(obj.joinedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrusadeCampaignLinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CampaignAdapter extends TypeAdapter<Campaign> {
  @override
  final int typeId = 4;

  @override
  Campaign read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Campaign(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as int?,
      lastModified: fields[4] as int?,
      crusadeLinks: (fields[5] as List?)?.cast<CrusadeCampaignLink>(),
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Campaign obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.lastModified)
      ..writeByte(5)
      ..write(obj.crusadeLinks)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampaignAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameAgendaAdapter extends TypeAdapter<GameAgenda> {
  @override
  final int typeId = 5;

  @override
  GameAgenda read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameAgenda(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      description: fields[3] as String?,
      completed: fields[4] as bool,
      tier: fields[5] as int,
      maxTier: fields[6] as int,
      unitTallies: (fields[7] as Map?)?.cast<String, int>(),
      maxUnits: fields[8] as int?,
      assignedUnitIds: (fields[9] as List?)?.cast<String>(),
      xpPerTally: fields[10] as int?,
      tallyDivisor: fields[11] as int?,
      maxXp: fields[12] as int?,
      xpPerTier: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, GameAgenda obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.completed)
      ..writeByte(5)
      ..write(obj.tier)
      ..writeByte(6)
      ..write(obj.maxTier)
      ..writeByte(7)
      ..write(obj.unitTallies)
      ..writeByte(8)
      ..write(obj.maxUnits)
      ..writeByte(9)
      ..write(obj.assignedUnitIds)
      ..writeByte(10)
      ..write(obj.xpPerTally)
      ..writeByte(11)
      ..write(obj.tallyDivisor)
      ..writeByte(12)
      ..write(obj.maxXp)
      ..writeByte(13)
      ..write(obj.xpPerTier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAgendaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitGameStateAdapter extends TypeAdapter<UnitGameState> {
  @override
  final int typeId = 6;

  @override
  UnitGameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitGameState(
      unitId: fields[0] as String,
      unitName: fields[1] as String,
      kills: fields[2] as int,
      wasDestroyed: fields[3] as bool,
      markedForGreatness: fields[4] as bool,
      notes: fields[5] as String?,
      groupId: fields[6] as String?,
      groupName: fields[7] as String?,
      ooaTestResolved: fields[8] as bool,
      ooaTestRoll: fields[9] as int?,
      ooaTestPassed: fields[10] as bool?,
      ooaOutcome: fields[11] as String?,
      battleScarGained: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UnitGameState obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.unitId)
      ..writeByte(1)
      ..write(obj.unitName)
      ..writeByte(2)
      ..write(obj.kills)
      ..writeByte(3)
      ..write(obj.wasDestroyed)
      ..writeByte(4)
      ..write(obj.markedForGreatness)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.groupId)
      ..writeByte(7)
      ..write(obj.groupName)
      ..writeByte(8)
      ..write(obj.ooaTestResolved)
      ..writeByte(9)
      ..write(obj.ooaTestRoll)
      ..writeByte(10)
      ..write(obj.ooaTestPassed)
      ..writeByte(11)
      ..write(obj.ooaOutcome)
      ..writeByte(12)
      ..write(obj.battleScarGained);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitGameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 7;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      id: fields[0] as String,
      name: fields[1] as String,
      rosterId: fields[3] as String,
      battleSize: fields[4] as String,
      rosterPoints: fields[5] as int,
      rosterCrusadePoints: fields[6] as int,
      campaignId: fields[2] as String?,
      createdAt: fields[7] as int?,
      completedAt: fields[8] as int?,
      result: fields[9] as String,
      agendas: (fields[10] as List?)?.cast<GameAgenda>(),
      unitStates: (fields[11] as List?)?.cast<UnitGameState>(),
      opponentName: fields[12] as String?,
      opponentFaction: fields[13] as String?,
      notes: fields[14] as String?,
      playerScore: fields[15] as int?,
      opponentScore: fields[16] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.campaignId)
      ..writeByte(3)
      ..write(obj.rosterId)
      ..writeByte(4)
      ..write(obj.battleSize)
      ..writeByte(5)
      ..write(obj.rosterPoints)
      ..writeByte(6)
      ..write(obj.rosterCrusadePoints)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.result)
      ..writeByte(10)
      ..write(obj.agendas)
      ..writeByte(11)
      ..write(obj.unitStates)
      ..writeByte(12)
      ..write(obj.opponentName)
      ..writeByte(13)
      ..write(obj.opponentFaction)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.playerScore)
      ..writeByte(16)
      ..write(obj.opponentScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
