import 'dart:convert';

import 'package:http/http.dart' as http;

class MockHttpClient extends http.BaseClient {
  final List<http.BaseRequest> requests = [];
  final List<http.Response> _responses;
  int _callCount = 0;

  MockHttpClient(this._responses);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (_callCount < _responses.length) {
      final r = _responses[_callCount++];
      return http.StreamedResponse(
        Stream.value(utf8.encode(r.body)),
        r.statusCode,
        headers: r.headers,
      );
    }
    return http.StreamedResponse(const Stream.empty(), 404);
  }
}
