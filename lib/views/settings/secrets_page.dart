import 'package:flutter/material.dart';
import 'package:lenra_components/component/lenra_button.dart';
import 'package:lenra_components/component/lenra_text.dart';
import 'package:lenra_components/layout/lenra_flex.dart';
import 'package:lenra_components/theme/lenra_theme.dart';
import 'package:lenra_components/theme/lenra_theme_data.dart';

class SecretsPage extends StatefulWidget {
  const SecretsPage({Key? key}) : super(key: key);

  @override
  State<SecretsPage> createState() => _SecretsPageState();
}

class _SecretsPageState extends State<SecretsPage> {
  @override
  Widget build(BuildContext context) {
    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;

    // TODO: Delete this
    List<Map<String, dynamic>> secrets = [
      {"name": "APP_SECRET_EXAMPLE", "id": "1"},
      {"name": "OTHER_APP_SECRET", "id": "2"},
      {"name": "SHORT", "id": "2"},
      {"name": "VERY_LONG_APP_SECRET_EXAMPLE_TEST", "id": "2"},
    ];

    return LenraFlex(
      spacing: 16,
      direction: Axis.vertical,
      children: [
        LenraText(text: "Secrets", style: lenraTextThemeData.headline3),
        LenraText(text: "Create secrets for your application."),
        DataTable(
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
                      showEditDialog({"name": "", "value": ""});
                    },
                    text: "Add new secret",
                  ),
                ),
              ),
            ],
            rows: List<DataRow>.generate(secrets.length, (index) {
              Map<String, dynamic> secret = secrets[index];
              return DataRow(cells: <DataCell>[
                DataCell(
                  Text(secret["name"]!),
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
                        await deleteSecret(secret["id"]);
                        setState(() {});
                      },
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                )),
              ]);
            })),
      ],
    );
  }

  void showEditDialog(Map<String, dynamic> secret) {
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
                controller: TextEditingController(text: secret["name"]),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Value",
                ),
                controller: TextEditingController(text: secret["value"]),
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
                if (formKey.currentState!.validate()) {
                  GetMainEnvResponse res = await context.read<UserApplicationModel>().getMainEnv(widget.appId);

                  if (client == null) {
                    await LenraApi.instance.post(
                      '/environments/${res.mainEnv.id}/oauth2',
                      body: {
                        'name': nameController.text,
                        'scopes': ['app:websocket'],
                        'redirect_uris': redirectUrisController.text.split('\n').map((e) => e.trim()).toList(),
                        'allowed_origins': allowedOriginsController.text.split('\n').map((e) => e.trim()).toList(),
                      },
                    );
                  } else {
                    await LenraApi.instance.put(
                      '/environments/${res.mainEnv.id}/oauth2/${client.clientId}',
                      body: {
                        'name': nameController.text,
                        'scopes': ['app:websocket'],
                        'redirect_uris': redirectUrisController.text.split('\n'),
                        'allowed_origins': allowedOriginsController.text.split('\n')
                      },
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
