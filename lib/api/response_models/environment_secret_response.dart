import 'package:client_common/api/response_models/api_response.dart';

class EnvironmentSecretResponse extends ApiResponse {
  int id;
  int environmentId;

  String key;
  String value;
  bool isObfuscated;

  EnvironmentSecretResponse.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        environmentId = json["environment_id"],
        key = json['key'],
        value = json['value'],
        isObfuscated = json['is_obfuscated'];
}
