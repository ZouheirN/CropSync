// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageObjectAdapter extends TypeAdapter<ImageObject> {
  @override
  final int typeId = 0;

  @override
  ImageObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageObject(
      image: fields[1] as Uint8List,
      result: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.result);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
