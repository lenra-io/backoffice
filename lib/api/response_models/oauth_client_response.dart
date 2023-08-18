import 'package:client_common/api/response_models/api_response.dart';

class OAuthClientResponse extends ApiResponse {
  String clientId;
  int environmentId;
  String name;
  List<String> scopes;
  List<String> redirectUris;
  List<String> allowedOrigins;

  OAuthClientResponse.fromJson(Map<String, dynamic> json)
      : clientId = json["oauth2_client_id"],
        environmentId = json["environment_id"],
        name = json['name'],
        scopes = json['scopes'],
        redirectUris = json['redirect_uris'],
        allowedOrigins = json['allowed_origins'];

  @override
  bool operator ==(Object other) {
    return other is OAuthClientResponse && other.clientId == clientId;
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
