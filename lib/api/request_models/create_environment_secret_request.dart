import 'package:client_common/api/request_models/api_request.dart';

class CreateEnvironmentSecretRequest extends ApiRequest {
  String key;
  String value;

  CreateEnvironmentSecretRequest({
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
      };
}
