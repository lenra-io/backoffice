import 'package:client_backoffice/api/response_models/environment_secret_response.dart';
import 'package:client_common/api/response_models/api_response.dart';

class EnvironmentSecretsResponse extends ApiResponse {
  List<EnvironmentSecretResponse> secrets;

  EnvironmentSecretsResponse.fromJson(List<dynamic> json)
      : secrets = json.map<EnvironmentSecretResponse>((secret) => EnvironmentSecretResponse.fromJson(secret)).toList();
}
