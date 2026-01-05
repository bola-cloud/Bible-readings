class Profile {
  final int? id;
  final String name;
  final String? phone;
  final String? church;
  final String? schoolYear;
  final String? sponsor;
  final String? favoriteColor;
  final String? favoriteProgram;
  final String? favoriteGame;
  final String? favoriteHymn;
  final String? hobby;
  final String? createdAt;
  final String? updatedAt;

  Profile({
    this.id,
    required this.name,
    this.phone,
    this.church,
    this.schoolYear,
    this.sponsor,
    this.favoriteColor,
    this.favoriteProgram,
    this.favoriteGame,
    this.favoriteHymn,
    this.hobby,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      phone: json['phone'] as String?,
      church: json['church'] as String?,
      schoolYear: json['school_year'] as String?,
      sponsor: json['sponsor'] as String?,
      favoriteColor: json['favorite_color'] as String?,
      favoriteProgram: json['favorite_program'] as String?,
      favoriteGame: json['favorite_game'] as String?,
      favoriteHymn: json['favorite_hymn'] as String?,
      hobby: json['hobby'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'church': church,
      'school_year': schoolYear,
      'sponsor': sponsor,
      'favorite_color': favoriteColor,
      'favorite_program': favoriteProgram,
      'favorite_game': favoriteGame,
      'favorite_hymn': favoriteHymn,
      'hobby': hobby,
    };
  }
}
