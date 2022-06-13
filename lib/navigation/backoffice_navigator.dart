import 'package:client_backoffice/navigation/guard.dart';
import 'package:client_backoffice/views/activation_code_page.dart';
import 'package:client_backoffice/views/create_first_project_page.dart';
import 'package:client_backoffice/views/overview_page.dart';
import 'package:client_backoffice/views/settings_page.dart';
import 'package:client_backoffice/views/welcome_dev_page.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:client_common/navigator/guard.dart';
import 'package:client_common/navigator/page_guard.dart';
import 'package:client_common/views/page_404.dart';
import 'package:flutter/widgets.dart';

class BackofficeNavigator extends CommonNavigator {
  static const String homeRoute = "/";
  static const String validationDevRoute = "/validation-dev";
  static const String welcome = "/welcome";
  static const String firstProject = "/first-project";
  static const String settings = "/settings";

  static String? currentRoute;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final Map<String, CustomPageBuilder> routes = {}
    ..addAll(CommonNavigator.authRoutes)
    ..addAll(backofficeRoutes);

  static final Map<String, CustomPageBuilder> backofficeRoutes = {
    validationDevRoute: (Map<String, String> params) => PageGuard(
          guards: [
            Guard.checkAuthenticated,
            Guard.checkCguAccepted,
            Guard.checkIsNotDev,
          ],
          child: ActivationCodePage(),
        ),
    welcome: (Map<String, String> params) => PageGuard(
          guards: [
            Guard.checkAuthenticated,
            Guard.checkCguAccepted,
            Guard.checkIsDev,
            Guard.checkNotHaveApp,
          ],
          child: WelcomeDevPage(),
        ),
    firstProject: (Map<String, String> params) => PageGuard(
          guards: [
            Guard.checkAuthenticated,
            Guard.checkCguAccepted,
            Guard.checkIsDev,
            Guard.checkNotHaveApp,
          ],
          child: CreateFirstProjectPage(),
        ),
    homeRoute: (Map<String, String> params) => PageGuard(
          guards: [
            Guard.checkAuthenticated,
            Guard.checkCguAccepted,
            Guard.checkIsDev,
            BackofficeGuard.checkHaveApp,
          ],
          child: OverviewPage(),
        ),
    settings: (Map<String, String> params) => PageGuard(
          guards: [
            Guard.checkAuthenticated,
            Guard.checkCguAccepted,
            Guard.checkIsDev,
            BackofficeGuard.checkHaveApp,
          ],
          child: SettingsPage(),
        ),
  };

  static Widget? _getPageForRoutes(
    List<String> currentRouteParts,
    String route,
    CustomPageBuilder routeBuilder,
  ) {
    Map<String, String> params = {};
    List<String> routeParts = route.split('/');
    if (routeParts.length != currentRouteParts.length) return null;
    for (int i = 0; i < routeParts.length; i++) {
      String routePart = routeParts[i];
      String currentRoutePart = currentRouteParts[i];

      if (routePart.startsWith(':')) {
        params[routePart.replaceFirst(':', '')] = currentRoutePart;
      } else if (routePart != currentRoutePart) {
        return null;
      }
    }

    return routeBuilder(params);
  }

  static Widget? _getFirstMatchingPage(String route) {
    List<String> currentRouteParts = route.split('/');
    for (MapEntry<String, CustomPageBuilder> entry in routes.entries) {
      Widget? page = _getPageForRoutes(currentRouteParts, entry.key, entry.value);
      if (page != null) {
        return page;
      }
    }
    return null;
  }

  static Route<dynamic> handleGenerateRoute(RouteSettings settings) {
    debugPrint("route: ${settings.name}");
    BackofficeNavigator.currentRoute = settings.name;
    if (settings.name == null) return Page404.pageRoutebuilder(settings);
    Widget? page = _getFirstMatchingPage(settings.name!);
    if (page == null) return Page404.pageRoutebuilder(settings);
    return PageRouteBuilder(
      pageBuilder: (BuildContext context, a, b) {
        return page;
      },
      settings: settings,
    );
  }
}
