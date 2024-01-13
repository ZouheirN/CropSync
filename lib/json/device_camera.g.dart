// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_camera.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceCameraAdapter extends TypeAdapter<DeviceCamera> {
  @override
  final int typeId = 5;

  @override
  DeviceCamera read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceCamera(
      deviceId: fields[0] as int?,
      deviceName: fields[1] as String?,
      location: fields[2] as String?,
      image: fields[4] as String?,
    )..cropName = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, DeviceCamera obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.deviceName)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.cropName)
      ..writeByte(4)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceCameraAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
