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
    );
  }

  @override
  void write(BinaryWriter writer, Crusade obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.lastModified);
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
      xp: fields[8] as int?,
      honours: (fields[9] as List?)?.cast<String>(),
      scars: (fields[10] as List?)?.cast<String>(),
      enhancements: (fields[17] as List?)?.cast<String>(),
      crusadePoints: fields[11] as int?,
      tallies: (fields[12] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UnitOrGroup obj) {
    writer
      ..writeByte(18)
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
      ..write(obj.enhancements);
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
