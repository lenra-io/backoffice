import 'package:client_backoffice/api/request_models/create_environment_secret_request.dart';
import 'package:client_backoffice/api/response_models/environment_secret_response.dart';
import 'package:client_backoffice/api/response_models/environment_secrets_response.dart';
import 'package:client_common/api/lenra_http_client.dart';

class BackofficeApi {
  static Future<EnvironmentSecretsResponse> getEnvironmentSecrets(int appId, int envId) => LenraApi.instance.get(
        "/apps/$appId/environments/$envId/secrets",
        responseMapper: (json, header) => EnvironmentSecretsResponse.fromJson(json),
      );

  static Future<EnvironmentSecretResponse> createEnvironmentSecret(
    int appId,
    int envId,
    CreateEnvironmentSecretRequest envSecret,
  ) =>
      LenraApi.instance.post(
        "/apps/$appId/environments/$envId/secrets",
        body: envSecret,
        responseMapper: (json, header) => EnvironmentSecretResponse.fromJson(json),
      );

  static Future<EnvironmentSecretResponse> updateEnvironmentSecret(
    int appId,
    int envId,
    EnvironmentSecretResponse envSecret,
  ) =>
      LenraApi.instance.put(
        "/apps/$appId/environments/$envId/secrets/${envSecret.id}",
        body: envSecret,
        responseMapper: (json, header) => EnvironmentSecretResponse.fromJson(json),
      );

  static Future<EnvironmentSecretResponse> deleteEnvironmentSecret(int appId, int envId, int secretId) =>
      LenraApi.instance.delete(
        "/apps/$appId/environments/$envId/secrets/$secretId",
        responseMapper: (json, header) => EnvironmentSecretResponse.fromJson(json),
      );
}
