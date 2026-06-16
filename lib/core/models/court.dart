enum CourtType {
  badminton,
  pickleball,
  basketball,
}

extension CourtTypeDisplay on CourtType {
  String get label {
    switch (this) {
      case CourtType.badminton:
        return 'BADMINTON';
      case CourtType.pickleball:
        return 'PICKLEBALL';
      case CourtType.basketball:
        return 'BASKETBALL';
    }
  }

  String get shortLabel {
    switch (this) {
      case CourtType.badminton:
        return 'Badminton';
      case CourtType.pickleball:
        return 'Pickleball';
      case CourtType.basketball:
        return 'Basketball';
    }
  }
}

class Court {
  const Court({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.price,
    required this.rating,
    required this.numberOfCourts,
    required this.amenities,
    required this.image,
    this.description = '',
    this.phone,
    this.email,
    this.mapUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final CourtType type;
  final String location;
  final double price;
  final double rating;
  final int numberOfCourts;
  final List<String> amenities;
  final String image;
  final String description;
  final String? phone;
  final String? email;
  final String? mapUrl;
  final double? latitude;
  final double? longitude;
}
