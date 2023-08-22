import 'package:client_backoffice/api/response_models/oauth_client_response.dart';
import 'package:client_backoffice/api/response_models/oauth_clients_response.dart';
import 'package:client_common/api/lenra_http_client.dart';
import 'package:client_common/api/response_models/get_main_env_response.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class ExternalClientsPage extends StatefulWidget {
  final int appId;
  ExternalClientsPage({required this.appId});

  @override
  State<StatefulWidget> createState() {
    return _ExternalClientsPageState();
  }
}

class _ExternalClientsPageState extends State<ExternalClientsPage> {
  final logger = Logger("ExternalClientsPage");
  final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;

    return FutureBuilder(
      future: getOauthClients(),
      builder: (context, snapshot) {
        if (!snapshot.hasError && snapshot.hasData) {
          return LenraFlex(
            spacing: 8,
            direction: Axis.vertical,
            children: [
              Text("OAuth2 external clients", style: lenraTextThemeData.headline3),
              Text(
                  "Manage your OAuth2 external clients. It is recommended to create one OAuth client for each platform (web, windows, linux, android, ...)."),
              SizedBox(height: 8),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Clients", style: lenraTextThemeData.headline3),
                  LenraButton(
                    onPressed: () {
                      showCreateDialog();
                    },
                    text: "Add new client",
                  )
                ],
              ),
              Divider(),
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
                        child: Text('Client ID', style: lenraTextThemeData.headlineBody),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(''),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(snapshot.data!.clients.length, (index) {
                    OAuthClientResponse client = snapshot.data!.clients[index];
                    return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(client.name),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Text(client.clientId),
                                Tooltip(
                                  // We need to set this waitDuration because the triggerMode manual does not remove the hover
                                  waitDuration: Duration(days: 200),
                                  key: tooltipKey,
                                  triggerMode: TooltipTriggerMode.manual,
                                  showDuration: const Duration(seconds: 1),
                                  message: 'Copied to clipboard.',
                                  child: IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: client.clientId));
                                      tooltipKey.currentState?.ensureTooltipVisible();
                                    },
                                    icon: Icon(Icons.copy),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Flex(
                            direction: Axis.horizontal,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await deleteOauthClient(client.clientId);
                                  setState(() {});
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          )),
                        ],
                        onSelectChanged: (bool? selected) {
                          if (selected ?? false) {
                            showEditDialog(client);
                          }
                        });
                  })),
            ],
          );
        }

        print(snapshot.error);

        return CircularProgressIndicator();
      },
    );
  }

  Future<OAuthClientsResponse> getOauthClients() async {
    GetMainEnvResponse res = await context.read<UserApplicationModel>().getMainEnv(widget.appId);

    var getResponse = await LenraApi.instance.get('/environments/${res.mainEnv.id}/oauth2');
    return OAuthClientsResponse.fromJson(getResponse);
  }

  Future deleteOauthClient(String clientId) async {
    GetMainEnvResponse res = await context.read<UserApplicationModel>().getMainEnv(widget.appId);

    await LenraApi.instance.delete('/environments/${res.mainEnv.id}/oauth2/$clientId');
  }

  void showCreateDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return buildDialog();
      },
    );
  }

  void showEditDialog(OAuthClientResponse client) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return buildDialog(client: client);
      },
    );
  }

  Widget buildDialog({OAuthClientResponse? client}) {
    final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController();
    final redirectUrisController = TextEditingController();
    final allowedOriginsController = TextEditingController();

    if (client != null) {
      nameController.text = client.name;
      redirectUrisController.text = client.redirectUris.join('\n');
      allowedOriginsController.text = client.allowedOrigins.join('\n');
    }

    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(24),
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${client == null ? 'Create' : 'Edit'} client", style: lenraTextThemeData.headline3),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        label: Text('Name'),
                      ),
                    ),
                    SizedBox(height: 16),
                    client != null
                        ? Flex(
                            direction: Axis.horizontal,
                            children: [
                              Text('Client ID: ', style: lenraTextThemeData.headlineBody),
                              Text(client.clientId),
                              Tooltip(
                                // We need to set this waitDuration because the triggerMode manual does not remove the hover
                                waitDuration: Duration(days: 200),
                                key: tooltipKey,
                                triggerMode: TooltipTriggerMode.manual,
                                showDuration: const Duration(seconds: 1),
                                message: 'Copied to clipboard.',
                                child: IconButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: client.clientId));
                                    tooltipKey.currentState?.ensureTooltipVisible();
                                  },
                                  icon: Icon(Icons.copy),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: redirectUrisController,
                      decoration: InputDecoration(
                        label: Text('Redirect URIs'),
                        helperText: 'Use one line per URI',
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: allowedOriginsController,
                      maxLines: null,
                      decoration: InputDecoration(
                        label: Text('Allowed origins'),
                        helperText: 'Use one line per origin',
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 24),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LenraButton(
                          type: LenraComponentType.secondary,
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          text: "Cancel",
                        ),
                        SizedBox(width: 16),
                        LenraButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              GetMainEnvResponse res =
                                  await context.read<UserApplicationModel>().getMainEnv(widget.appId);

                              if (client == null) {
                                await LenraApi.instance.post(
                                  '/environments/${res.mainEnv.id}/oauth2',
                                  body: {
                                    'name': nameController.text,
                                    'scopes': ['manage:apps'],
                                    'redirect_uris':
                                        redirectUrisController.text.split('\n').map((e) => e.trim()).toList(),
                                    'allowed_origins':
                                        allowedOriginsController.text.split('\n').map((e) => e.trim()).toList(),
                                  },
                                );
                              } else {
                                await LenraApi.instance.put(
                                  '/environments/${res.mainEnv.id}/oauth2/${client.clientId}',
                                  body: {
                                    'name': nameController.text,
                                    'scopes': ['manage:apps'],
                                    'redirect_uris': redirectUrisController.text.split('\n'),
                                    'allowed_origins': allowedOriginsController.text.split('\n')
                                  },
                                );
                              }

                              Navigator.pop(context);

                              setState(() {});
                            }
                          },
                          text: "Save",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
