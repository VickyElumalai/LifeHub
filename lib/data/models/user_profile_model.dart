class UserProfileModel {
  final String id;
  String name;
  String? profilePhotoPath;
  final DateTime createdAt;
  DateTime updatedAt;

  UserProfileModel({
    required this.id,
    required this.name,
    this.profilePhotoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  String get initials {
    final names = name.trim().split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : '?';
    }
    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePhotoPath': profilePhotoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'],
      profilePhotoPath: json['profilePhotoPath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? profilePhotoPath,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}