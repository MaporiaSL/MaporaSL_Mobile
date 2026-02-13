/// Photo location data
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

  Map<String, dynamic> toJson() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeName != null) 'placeName': placeName,
    };
  }
}