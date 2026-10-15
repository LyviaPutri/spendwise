class CategoryModel {
  final int? id;
  final String name;
  final String iconName;
  final String colorHex;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      iconName: json['icon_name'] as String,
      colorHex: json['color_hex'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
    };
  }
}