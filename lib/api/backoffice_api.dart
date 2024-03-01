import 'package:client_backoffice/api/request_models/create_environment_secret_request.dart';
import 'package:client_common/api/lenra_http_client.dart';

class BackofficeApi {
  static Future<List<String>> getEnvironmentSecrets(int appId, int envId) => LenraApi.instance.get(
        "/apps/$appId/environments/$envId/secrets",
        responseMapper: (json, header) => json,
      );

  static Future<String> createEnvironmentSecret(
    int appId,
    int envId,
    CreateEnvironmentSecretRequest envSecret,
  ) =>
      LenraApi.instance.post(
        "/apps/$appId/environments/$envId/secrets",
        body: envSecret,
        responseMapper: (json, header) => json,
      );

  static Future<String> updateEnvironmentSecret(
    int appId,
    int envId,
    EnvironmentSecret envSecret,
  ) =>
      LenraApi.instance.put(
        "/apps/$appId/environments/$envId/secrets/${envSecret.key}",
        body: envSecret,
        responseMapper: (json, header) => json,
      );

  static Future<String> deleteEnvironmentSecret(int appId, int envId, String secretKey) => LenraApi.instance.delete(
        "/apps/$appId/environments/$envId/secrets/$secretKey",
        responseMapper: (json, header) => json,
      );
}

class EnvironmentSecret {
  String key;
  String value;

  EnvironmentSecret({
    required this.key,
    required this.value,
  });
}
