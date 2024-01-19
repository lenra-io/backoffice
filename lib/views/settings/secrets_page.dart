import 'package:client_backoffice/api/backoffice_api.dart';
import 'package:client_backoffice/api/response_models/environment_secret_response.dart';
import 'package:client_backoffice/api/response_models/environment_secrets_response.dart';
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
  @override
  Widget build(BuildContext context) {
    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;

    return LenraFlex(
      spacing: 16,
      direction: Axis.vertical,
      children: [
        LenraText(text: "Secrets", style: lenraTextThemeData.headline3),
        LenraText(text: "Create secrets for your application."),
        FutureBuilder<EnvironmentSecretsResponse>(
          future: Future.wait([
            context.read<UserApplicationModel>().getMainEnv(widget.appId),
          ]).then(
            (env) => BackofficeApi.getEnvironmentSecrets(widget.appId, env[0].mainEnv.id),
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
                    child: LenraButton(
                      onPressed: () {
                        showEditDialog(null);
                      },
                      text: "Add new secret",
                    ),
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
                            await deleteSecret(secret.id);
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit secret"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                ),
                controller: TextEditingController(text: secret?.key),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Value",
                ),
                controller: TextEditingController(text: secret?.value),
              ),
            ],
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
                // if (formKey.currentState!.validate()) {
                //   GetMainEnvResponse res = await context.read<UserApplicationModel>().getMainEnv(widget.appId);

                //   if (client == null) {
                //     await LenraApi.instance.post(
                //       '/environments/${res.mainEnv.id}/oauth2',
                //       body: {
                //         'name': nameController.text,
                //         'scopes': ['app:websocket'],
                //         'redirect_uris': redirectUrisController.text.split('\n').map((e) => e.trim()).toList(),
                //         'allowed_origins': allowedOriginsController.text.split('\n').map((e) => e.trim()).toList(),
                //       },
                //     );
                //   } else {
                //     await LenraApi.instance.put(
                //       '/environments/${res.mainEnv.id}/oauth2/${client.clientId}',
                //       body: {
                //         'name': nameController.text,
                //         'scopes': ['app:websocket'],
                //         'redirect_uris': redirectUrisController.text.split('\n'),
                //         'allowed_origins': allowedOriginsController.text.split('\n')
                //       },
                //     );
                //   }

                //   Navigator.of(context, rootNavigator: true).pop();

                //   setState(() {});
                // }
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
