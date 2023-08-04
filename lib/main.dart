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
import 'package:client_common/views/auth/oauth_page.dart';
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
  // TODO: Récupération de variables d'environnement ne doit pas marcher
  const environment = String.fromEnvironment('ENVIRONMENT');

  CatcherOptions debugOptions = CatcherOptions(
    LenraReportMode(),
    environment == "production" || environment == "staging"
        ? [
            SentryHandler(
              SentryClient(SentryOptions(dsn: Config.instance.sentryDsn)..environment = environment),
            ),
          ]
        : [],
  );

  Catcher(
    debugConfig: debugOptions,
    rootWidget: Backoffice(),
  );
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
              '81c40207-6dde-4b9b-9c3f-7b4811a059e1',
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
        builder: (BuildContext context, _) => LenraTheme(
          themeData: themeData,
          child: MaterialApp.router(
            routerConfig: BackofficeNavigator.router,
            title: 'Lenra',
            theme: ThemeData(
              visualDensity: VisualDensity.standard,
              textTheme: TextTheme(bodyMedium: themeData.lenraTextThemeData.bodyText),
            ),
            builder: (context, widget) {
              return OAuthPage(child: widget!);
            },
          ),
        ),
      ),
    );
  }
}
