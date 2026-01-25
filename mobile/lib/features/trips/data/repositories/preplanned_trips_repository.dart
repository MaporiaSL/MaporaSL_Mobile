import '../datasources/preplanned_trips_api.dart';
import '../models/preplanned_trip_model.dart';
import '../models/trip_model.dart';

/// Repository wrapper for pre-planned (template) trips
class PrePlannedTripsRepository {
  final PrePlannedTripsApi _api;

  PrePlannedTripsRepository(this._api);

  Future<List<PrePlannedTripModel>> fetchTemplates({
    String? duration,
    String? type,
    String? startingPoint,
    String? difficulty,
    List<String>? tags,
    int limit = 20,
    int skip = 0,
  }) {
    return _api.fetchTemplates(
      duration: duration,
      type: type,
      startingPoint: startingPoint,
      difficulty: difficulty,
      tags: tags,
      limit: limit,
      skip: skip,
    );
  }

  Future<PrePlannedTripModel> getTemplate(String id) {
    return _api.fetchTemplateById(id);
  }

  Future<TripModel> cloneTemplate({
    required String templateId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _api.cloneTemplate(
      templateId: templateId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
