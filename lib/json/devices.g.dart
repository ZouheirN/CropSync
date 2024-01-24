// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DevicesAdapter extends TypeAdapter<Devices> {
  @override
  final int typeId = 2;

  @override
  Devices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Devices(
      id: fields[1] as String?,
      name: fields[2] as String?,
      code: fields[3] as String?,
      crop: fields[4] as Crop?,
    );
  }

  @override
  void write(BinaryWriter writer, Devices obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.code)
      ..writeByte(4)
      ..write(obj.crop);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      name: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Crop obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.name);
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
