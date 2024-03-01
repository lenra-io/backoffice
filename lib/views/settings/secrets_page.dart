import 'package:client_backoffice/api/backoffice_api.dart';
import 'package:client_backoffice/api/request_models/create_environment_secret_request.dart';
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
        FutureBuilder<List<String>>(
          future: Future.wait([
            context.read<UserApplicationModel>().getMainEnv(widget.appId),
          ]).then(
            (envResponse) => BackofficeApi.getEnvironmentSecrets(widget.appId, envResponse[0].mainEnv.id),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return CircularProgressIndicator();
            }

            List<String> secrets = snapshot.data!;

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
                    child: Text(''),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                secrets.length,
                (index) {
                  String secretKey = secrets[index];
                  return DataRow(cells: <DataCell>[
                    DataCell(
                      Text(secretKey),
                    ),
                    DataCell(Flex(
                      direction: Axis.horizontal,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showEditDialog(secretKey);
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            GetMainEnvResponse mainEnvResponse =
                                await context.read<UserApplicationModel>().getMainEnv(widget.appId);
                            await BackofficeApi.deleteEnvironmentSecret(
                              widget.appId,
                              mainEnvResponse.mainEnv.id,
                              secretKey,
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

  void showEditDialog(String? secretKey) {
    final nameController = TextEditingController(text: secretKey);
    final valueController = TextEditingController(text: "");

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

                  if (secretKey == null) {
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
                      EnvironmentSecret(
                        key: nameController.text,
                        value: valueController.text,
                      ),
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
