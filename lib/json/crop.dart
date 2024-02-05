class Crop {
  String? name;

  Crop({
    this.name,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}