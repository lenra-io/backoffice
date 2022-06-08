import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/models/build_model.dart';
import 'package:client_common/models/cgu_model.dart';
import 'package:client_common/models/store_model.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(Backoffice());
}

class Backoffice extends StatelessWidget {
  Backoffice({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var themeData = LenraThemeData();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthModel>(create: (context) => AuthModel()),
        ChangeNotifierProvider<BuildModel>(create: (context) => BuildModel()),
        ChangeNotifierProvider<UserApplicationModel>(create: (context) => UserApplicationModel()),
        ChangeNotifierProvider<StoreModel>(create: (context) => StoreModel()),
        ChangeNotifierProvider<CguModel>(create: (context) => CguModel()),
      ],
      builder: (BuildContext context, _) => LenraTheme(
        themeData: themeData,
        child: MaterialApp(
          title: 'Lenra',
          navigatorKey: BackofficeNavigator.navigatorKey,
          onGenerateInitialRoutes: (initialRoute) =>
              [BackofficeNavigator.handleGenerateRoute(RouteSettings(name: initialRoute))],
          onGenerateRoute: BackofficeNavigator.handleGenerateRoute,
          theme: ThemeData(
            textTheme: TextTheme(bodyText2: themeData.lenraTextThemeData.bodyText),
          ),
        ),
      ),
    );
  }
}
