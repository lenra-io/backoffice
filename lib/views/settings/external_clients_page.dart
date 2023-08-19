import 'package:client_backoffice/api/response_models/oauth_clients_response.dart';
import 'package:client_common/api/lenra_http_client.dart';
import 'package:client_common/api/response_models/get_main_env_response.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
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
                    Text("Clients"),
                    LenraButton(
                      onPressed: () {
                        openModal();
                      },
                      text: "Add new client",
                    )
                  ],
                ),
                Flex(
                  direction: Axis.vertical,
                  children: snapshot.data!.clients.map((client) {
                    return Flex(
                      direction: Axis.horizontal,
                      children: [
                        Text(client.name),
                        Text(client.clientId),
                        Text(client.allowedOrigins.toString()),
                      ],
                    );
                  }).toList(),
                ),
              ],
            );
          }

          print(snapshot.error);

          return CircularProgressIndicator();
        });
  }

  Future<OAuthClientsResponse> getOauthClients() async {
    GetMainEnvResponse res = await context.read<UserApplicationModel>().getMainEnv(widget.appId);

    var res2 = await LenraApi.instance.get('/environments/${res.mainEnv.id}/oauth2');
    return OAuthClientsResponse.fromJson(res2);
  }

  void openModal() {
    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;
    showDialog(
        context: context,
        useRootNavigator: true,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 400,
                child: Form(
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Text("New client", style: lenraTextThemeData.headline3),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('Name'),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('Redirect URIs'),
                          helperText: 'Use one line per URI',
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('Allowed origins'),
                          helperText: 'comma separated origins',
                        ),
                      ),
                      SizedBox(height: 16),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LenraButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: "Cancel",
                          ),
                          LenraButton(
                            onPressed: () async {
                              GetMainEnvResponse res =
                                  await context.read<UserApplicationModel>().getMainEnv(widget.appId);

                              await LenraApi.instance.post(
                                '/environments/${res.mainEnv.id}/oauth2',
                                body: {
                                  'name': 'test',
                                  'scopes': ['manage:apps'],
                                  'redirect_uris': ['http://localhost:10000/redirect.html'],
                                  'allowed_origins': ['http://localhost:10000']
                                },
                              );

                              Navigator.pop(context);

                              setState(() {});
                            },
                            text: "Save",
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
