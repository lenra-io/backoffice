import 'package:client_backoffice/navigation/guard.dart';
import 'package:client_backoffice/views/create_project_page.dart';
import 'package:client_backoffice/views/dev_validation_page.dart';
import 'package:client_backoffice/views/overview_page.dart';
import 'package:client_backoffice/views/select_project_page.dart';
import 'package:client_backoffice/views/settings/git_integration_page.dart';
import 'package:client_backoffice/views/settings/manage_access_page.dart';
import 'package:client_backoffice/views/settings_page.dart';
import 'package:client_backoffice/views/welcome_dev_page.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:client_common/navigator/guard.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class BackofficeNavigator extends CommonNavigator {
  static GoRoute validationDev = GoRoute(
    name: "validation-dev",
    path: "validation-dev",
    redirect: (context, state) => Guard.guards(context, [
      Guard.checkAuthenticated,
      Guard.checkCguAccepted,
      Guard.checkIsNotDev,
    ]),
    pageBuilder: (context, state) => NoTransitionPage(
      child: DevValidationPage(),
    ),
  );

  static GoRoute welcome = GoRoute(
    name: "welcome",
    path: "welcome",
    redirect: (context, state) => Guard.guards(context, [
      Guard.checkAuthenticated,
      Guard.checkCguAccepted,
      Guard.checkIsUser,
      Guard.checkIsDev,
      Guard.checkNotHaveApp,
    ]),
    pageBuilder: (context, state) => NoTransitionPage(
      child: WelcomeDevPage(),
    ),
  );

  static GoRoute createProject = GoRoute(
    name: "create-project",
    path: "create-project",
    redirect: (context, state) => Guard.guards(context, [
      Guard.checkAuthenticated,
      Guard.checkCguAccepted,
      Guard.checkIsUser,
      Guard.checkIsDev,
    ]),
    pageBuilder: (context, state) => NoTransitionPage(
      child: CreateProjectPage(),
    ),
  );

  static GoRoute gitSettings = GoRoute(
    name: "git-settings",
    path: "settings/git",
    pageBuilder: (context, state) {
      return NoTransitionPage(
        key: state.pageKey,
        child: GitIntegrationPage(
          appId: int.tryParse(state.params["appId"]!)!,
        ),
      );
    },
  );

  static GoRoute accessSettings = GoRoute(
    name: "access-settings",
    path: "settings/access",
    pageBuilder: (context, state) {
      return NoTransitionPage(
        key: state.pageKey,
        child: ManageAccessPage(
          appId: int.tryParse(state.params["appId"]!)!,
        ),
      );
    },
  );

  static ShellRoute settings = ShellRoute(
    pageBuilder: (context, state, child) {
      return NoTransitionPage(
        key: state.pageKey,
        child: SettingsPage(
          appId: int.tryParse(state.params["appId"]!)!,
          child: child,
        ),
      );
    },
    routes: [
      gitSettings,
      accessSettings,
    ],
  );

  static GoRoute overview = GoRoute(
    name: "overview",
    path: "app/:appId",
    redirect: (context, state) => Guard.guards(
      context,
      [
        Guard.checkAuthenticated,
        Guard.checkCguAccepted,
        Guard.checkIsUser,
        Guard.checkIsDev,
        BackofficeGuard.checkHaveApp,
      ],
    ),
    pageBuilder: (context, state) {
      print("PAGE BUILDER OVERVIEW");
      return NoTransitionPage(
        key: state.pageKey,
        child: OverviewPage(
          appId: int.tryParse(state.params["appId"]!)!,
        ),
      );
    },
    routes: [settings],
  );

  static GoRoute root = GoRoute(
    name: "root",
    path: "/",
    redirect: (context, state) {
      print("REDIRECTING FROM ROOT");
      print(state.pageKey);
      print(state.path);
      return "/select-project";
    },
    pageBuilder: (context, state) {
      print("PAGE BUILDER ROOT");
      return NoTransitionPage(
        key: state.pageKey,
        child: Container(),
      );
    },
    routes: [
      CommonNavigator.authRoutes,
      // Onboarding & other pages
      validationDev,
      welcome,
      createProject,
      overview,
      selectProject,
    ],
  );

  static GoRoute selectProject = GoRoute(
    name: "select-project",
    path: "select-project",
    redirect: (context, state) {
      print("RUNNING GUARDS");
      return Guard.guards(
        context,
        [
          Guard.checkAuthenticated,
          Guard.checkCguAccepted,
          Guard.checkIsUser,
          Guard.checkIsDev,
          BackofficeGuard.checkHaveApp,
        ],
      );
    },
    pageBuilder: (context, state) {
      print("PAGE BUILDER SELECTPROJECT");
      return NoTransitionPage(
        key: state.pageKey,
        child: SelectProjectPage(),
      );
    },
  );

  static final GoRouter router = GoRouter(routes: [root]);
}

class FadeInTransitionPage extends CustomTransitionPage {
  FadeInTransitionPage({required Widget child, LocalKey? key})
      : super(
          child: child,
          key: key,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Change the opacity of the screen using a Curve based on the the animation's
            // value
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
}

class NoTransitionPage extends CustomTransitionPage {
  NoTransitionPage({required Widget child, LocalKey? key})
      : super(
          child: child,
          key: key,
          transitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}
