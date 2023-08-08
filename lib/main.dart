import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_backoffice/navigation/url_strategy/url_strategy.dart' show setUrlStrategyTo;
import 'package:client_common/config/config.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/models/build_model.dart';
import 'package:client_common/models/deployment_model.dart';
import 'package:client_common/models/store_model.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:client_common/oauth/oauth_model.dart';
import 'package:client_common/views/lenra_report_mode.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  setUrlStrategyTo('path');

  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  debugPrint("Starting main app[debugPrint]: ${Config.instance.application}");

  const environment = String.fromEnvironment('ENVIRONMENT');
  var reportMode = LenraReportMode();
  CatcherOptions debugOptions = CatcherOptions(
    reportMode,
    environment == "production" || environment == "staging"
        ? [
            SentryHandler(
              SentryClient(SentryOptions(dsn: Config.instance.sentryDsn)..environment = environment),
            ),
          ]
        : [],
    reportOccurrenceTimeout: 100,
  );

  Catcher(
    debugConfig: debugOptions,
    rootWidget: ErrorHandler(streamController: reportMode.streamController, child: Backoffice()),
  );
}

class ErrorHandler extends StatelessWidget {
  final Widget child;
  final StreamController<dynamic> streamController;

  const ErrorHandler({Key? key, required this.child, required this.streamController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Text(snapshot.data.toString()),
                      TextButton(
                        onPressed: () {
                          streamController.add(null);
                        },
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return child;
        },
        stream: streamController.stream);
  }
}

class Backoffice extends StatelessWidget {
  Backoffice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeData = LenraThemeData();
    return Container(
      color: Colors.white,
      child: MultiProvider(
          providers: [
            ChangeNotifierProvider<OAuthModel>(
              create: (context) => OAuthModel(
                '46d96ae1-a6f2-4f70-95ab-9960f64923d9',
                'http://localhost:10000/redirect.html',
                scopes: ['manage:account', 'manage:apps', 'store', 'profile', 'resources'],
              ),
            ),
            ChangeNotifierProvider<AuthModel>(create: (context) => AuthModel()),
            ChangeNotifierProvider<BuildModel>(create: (context) => BuildModel()),
            ChangeNotifierProvider<DeploymentModel>(create: (context) => DeploymentModel()),
            ChangeNotifierProvider<UserApplicationModel>(create: (context) => UserApplicationModel()),
            ChangeNotifierProvider<StoreModel>(create: (context) => StoreModel()),
          ],
          builder: (BuildContext context, _) {
            return LenraTheme(
              themeData: themeData,
              child: MaterialApp.router(
                routerConfig: BackofficeNavigator.router,
                title: 'Lenra',
                theme: ThemeData(
                  visualDensity: VisualDensity.standard,
                  textTheme: TextTheme(bodyMedium: themeData.lenraTextThemeData.bodyText),
                ),
              ),
            );
          }),
    );
  }
}
