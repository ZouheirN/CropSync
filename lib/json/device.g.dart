// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceAdapter extends TypeAdapter<Device> {
  @override
  final int typeId = 2;

  @override
  Device read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Device(
      isConnected: fields[0] as bool?,
      deviceId: fields[1] as String?,
      location: fields[2] as String?,
      name: fields[3] as String?,
      code: fields[4] as String?,
      crop: fields[5] as Crop?,
      soilFrequency: fields[6] as int?,
      imageFrequency: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Device obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.isConnected)
      ..writeByte(1)
      ..write(obj.deviceId)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.code)
      ..writeByte(5)
      ..write(obj.crop)
      ..writeByte(6)
      ..write(obj.soilFrequency)
      ..writeByte(7)
      ..write(obj.imageFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
