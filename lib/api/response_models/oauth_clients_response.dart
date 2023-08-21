import 'package:client_backoffice/api/response_models/oauth_client_response.dart';
import 'package:client_common/api/response_models/api_response.dart';

class OAuthClientsResponse extends ApiResponse {
  List<OAuthClientResponse> clients;

  OAuthClientsResponse.fromJson(List<dynamic> json)
      : clients = json.map<OAuthClientResponse>((client) => OAuthClientResponse.fromJson(client)).toList();
}
