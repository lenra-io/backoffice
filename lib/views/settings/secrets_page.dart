import 'package:client_backoffice/api/backoffice_api.dart';
import 'package:client_backoffice/api/request_models/create_environment_secret_request.dart';
import 'package:client_backoffice/api/response_models/environment_secret_response.dart';
import 'package:client_backoffice/api/response_models/environment_secrets_response.dart';
import 'package:client_common/api/response_models/get_main_env_response.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/component/lenra_button.dart';
import 'package:lenra_components/component/lenra_text.dart';
import 'package:lenra_components/layout/lenra_flex.dart';
import 'package:lenra_components/theme/lenra_theme.dart';
import 'package:lenra_components/theme/lenra_theme_data.dart';
import 'package:provider/provider.dart';

class SecretsPage extends StatefulWidget {
  final int appId;

  const SecretsPage({required this.appId, Key? key}) : super(key: key);

  @override
  State<SecretsPage> createState() => _SecretsPageState();
}

class _SecretsPageState extends State<SecretsPage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;

    return LenraFlex(
      spacing: 16,
      direction: Axis.vertical,
      children: [
        LenraText(text: "Secrets", style: lenraTextThemeData.headline3),
        LenraText(text: "Create secrets for your application."),
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Secrets", style: lenraTextThemeData.headline3),
            LenraButton(
              onPressed: () {
                showEditDialog(null);
              },
              text: "New secret",
            )
          ],
        ),
        Divider(),
        FutureBuilder<EnvironmentSecretsResponse>(
          future: Future.wait([
            context.read<UserApplicationModel>().getMainEnv(widget.appId),
          ]).then(
            (envResponse) => BackofficeApi.getEnvironmentSecrets(widget.appId, envResponse[0].mainEnv.id),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return CircularProgressIndicator();
            }

            List<EnvironmentSecretResponse> secrets = snapshot.data!.secrets;

            return DataTable(
              showCheckboxColumn: false,
              horizontalMargin: 4,
              columnSpacing: 16,
              columns: <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text('Name', style: lenraTextThemeData.headlineBody),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('Value', style: lenraTextThemeData.headlineBody),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(''),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                secrets.length,
                (index) {
                  EnvironmentSecretResponse secret = secrets[index];
                  return DataRow(cells: <DataCell>[
                    DataCell(
                      Text(secret.key),
                    ),
                    // TODO: How to handle obfuscated value ? Does the server return null ?
                    DataCell(
                      Text(secret.value),
                    ),
                    DataCell(Flex(
                      direction: Axis.horizontal,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showEditDialog(secret);
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            GetMainEnvResponse mainEnvResponse =
                                await context.read<UserApplicationModel>().getMainEnv(widget.appId);
                            await BackofficeApi.deleteEnvironmentSecret(
                              widget.appId,
                              mainEnvResponse.mainEnv.id,
                              secret.id,
                            );
                            setState(() {});
                          },
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      ],
                    )),
                  ]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void showEditDialog(EnvironmentSecretResponse? secret) {
    final nameController = TextEditingController(text: secret?.key);
    final valueController = TextEditingController(text: secret?.value);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit secret"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Name",
                  ),
                  controller: nameController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Value",
                  ),
                  controller: valueController,
                ),
              ],
            ),
          ),
          actions: [
            LenraButton(
              type: LenraComponentType.secondary,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              text: "Cancel",
            ),
            LenraButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  GetMainEnvResponse mainEnvResponse =
                      await context.read<UserApplicationModel>().getMainEnv(widget.appId);

                  if (secret == null) {
                    await BackofficeApi.createEnvironmentSecret(
                      widget.appId,
                      mainEnvResponse.mainEnv.id,
                      CreateEnvironmentSecretRequest(
                        key: nameController.text,
                        value: valueController.text,
                      ),
                    );
                  } else {
                    await BackofficeApi.updateEnvironmentSecret(
                      widget.appId,
                      mainEnvResponse.mainEnv.id,
                      EnvironmentSecretResponse.fromJson({
                        "id": secret.id,
                        "key": nameController.text,
                        "value": valueController.text,
                        "is_obfuscated": secret.isObfuscated,
                        "environment_id": secret.environmentId,
                      }),
                    );
                  }

                  Navigator.of(context, rootNavigator: true).pop();

                  setState(() {});
                }
              },
              text: "Save",
            ),
          ],
        );
      },
    );
  }

  Future<void> editSecret(Map<String, dynamic> secret) async {}

  Future<void> deleteSecret(int id) async {}
}
