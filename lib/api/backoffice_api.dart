import 'package:client_backoffice/api/response_models/environment_secrets_response.dart';
import 'package:client_common/api/lenra_http_client.dart';

class BackofficeApi {
  static Future<EnvironmentSecretsResponse> getEnvironmentSecrets(int appId, int envId) => LenraApi.instance.get(
        "/apps/$appId/environments/$envId/secrets",
        responseMapper: (json, header) => EnvironmentSecretsResponse.fromJson(json),
      );
}
