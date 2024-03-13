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
    );
  }

  @override
  void write(BinaryWriter writer, Crop obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.profile);
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
