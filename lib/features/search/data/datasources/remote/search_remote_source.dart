import 'package:twizzle/core/api/dio_client.dart';

class SearchRemoteSource {
  final DioClient _client;

  SearchRemoteSource(this._client);

  Future<Map<String, dynamic>> search({
    required String query,
    required String filter,
    String? cursor,
    int? limit,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'q': query,
      'filter': filter,
    };
    if (cursor != null) queryParameters['cursor'] = cursor;
    if (limit != null) queryParameters['limit'] = limit;

    final res = await _client.get(
      'search',
      queryParameters: queryParameters,
    );
    return res.data;
  }
}
