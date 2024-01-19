import 'package:client_common/api/request_models/api_request.dart';

class CreateEnvironmentSecretRequest extends ApiRequest {
  String key;
  String value;
  bool isObfuscated;

  CreateEnvironmentSecretRequest({
    required this.key,
    required this.value,
    this.isObfuscated = true,
  });

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
        "is_obfuscated": isObfuscated,
      };
}
