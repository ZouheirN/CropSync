// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CropAdapter extends TypeAdapter<Crop> {
  @override
  final int typeId = 3;

  @override
  Crop read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Crop(
      name: fields[0] as String?,
      profile: fields[1] as String?,
      alerts: fields[2] as Alerts?,
    );
  }

  @override
  void write(BinaryWriter writer, Crop obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.profile)
      ..writeByte(2)
      ..write(obj.alerts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertsAdapter extends TypeAdapter<Alerts> {
  @override
  final int typeId = 4;

  @override
  Alerts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alerts(
      soil: fields[0] as Soil?,
      leaf: fields[1] as Leaf?,
    );
  }

  @override
  void write(BinaryWriter writer, Alerts obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.soil)
      ..writeByte(1)
      ..write(obj.leaf);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LeafAdapter extends TypeAdapter<Leaf> {
  @override
  final int typeId = 5;

  @override
  Leaf read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Leaf(
      message: (fields[0] as List?)?.cast<String>(),
      action: (fields[1] as List?)?.cast<String>(),
      status: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Leaf obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeafAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SoilAdapter extends TypeAdapter<Soil> {
  @override
  final int typeId = 6;

  @override
  Soil read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Soil(
      nutrient: (fields[0] as List?)?.cast<String>(),
      severity: (fields[1] as List?)?.cast<String>(),
      message: (fields[2] as List?)?.cast<String>(),
      action: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Soil obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nutrient)
      ..writeByte(1)
      ..write(obj.severity)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.action);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoilAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
