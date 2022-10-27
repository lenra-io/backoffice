import 'dart:async';

import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/api/response_models/app_response.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:client_common/navigator/guard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackofficeGuard extends Guard {
  BackofficeGuard({required super.isValid, required super.onInvalid});

  static final BackofficeGuard checkHaveApp = BackofficeGuard(isValid: _haveApp(true), onInvalid: _toWelcome);
  static final BackofficeGuard checkHasSelectedApp =
      BackofficeGuard(isValid: _hasSelectedApp(), onInvalid: _toSelectApp);

  static Future<bool> Function(BuildContext) _haveApp(bool mustHaveApp) {
    return (BuildContext context) async {
      try {
        List<AppResponse> userApps = await context.read<UserApplicationModel>().fetchUserApplications();
        return userApps.isNotEmpty == mustHaveApp;
      } catch (e) {
        return false;
      }
    };
  }

  static Future<bool> Function(BuildContext) _hasSelectedApp() {
    return (BuildContext context) {
      return Future.delayed(
        const Duration(),
        () {
          return context.read<UserApplicationModel>().selectedApp == null ? false : true;
        },
      );
    };
  }

  static void _toSelectApp(context) {
    Navigator.of(context).pushNamed(BackofficeNavigator.selectProject);
  }

  static void _toWelcome(context) {
    Navigator.of(context).pushNamed(BackofficeNavigator.welcome);
  }
}
