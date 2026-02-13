class PhotoLocation {
  final double? latitude;
  final double? longitude;
  final String? placeName;

  const PhotoLocation({this.latitude, this.longitude, this.placeName});

  factory PhotoLocation.fromJson(Map<String, dynamic> json) {
    return PhotoLocation(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      placeName: json['placeName'] as String?,
    );
  }
}