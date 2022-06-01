import 'package:client_backoffice/views/activation_code_page.dart';
import 'package:client_backoffice/views/create_first_project_page.dart';
import 'package:client_backoffice/views/overview_page.dart';
import 'package:client_backoffice/views/settings_page.dart';
import 'package:client_backoffice/views/welcome_dev_page.dart';
import 'package:flutter/widgets.dart';

typedef CustomPageBuilder = Widget Function(Map<String, String>);

class BackofficeNavigator {
  static const String homeRoute = "/";
  static const String validationDevRoute = "/validation-dev";
  static const String welcome = "/welcome";
  static const String firstProject = "/first-project";
  static const String settings = "/settings";

  static String? currentRoute;

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
            Guard.checkHaveApp,
          ],
          child: OverviewPage(),
        ),
    settings: (Map<String, String> params) => PageGuard(
          guards: [
            Guard.checkAuthenticated,
            Guard.checkCguAccepted,
            Guard.checkIsDev,
            Guard.checkHaveApp,
          ],
          child: SettingsPage(),
        ),
  };
}
