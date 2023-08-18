import 'package:client_common/api/response_models/api_response.dart';

class OAuthClientResponse extends ApiResponse {
  int id;

  OAuthClientResponse.fromJson(Map<String, dynamic> json) : id = json["id"];

  @override
  bool operator ==(Object other) {
    return other is OAuthClientResponse && other.id == id;
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
