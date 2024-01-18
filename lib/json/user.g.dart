// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      token: fields[1] as String?,
      profilePicture: fields[2] as Uint8List?,
      uploadProgress: fields[3] as double?,
      fullName: fields[4] as String?,
      email: fields[5] as String?,
      isVerified: fields[6] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.token)
      ..writeByte(2)
      ..write(obj.profilePicture)
      ..writeByte(3)
      ..write(obj.uploadProgress)
      ..writeByte(4)
      ..write(obj.fullName)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.isVerified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
