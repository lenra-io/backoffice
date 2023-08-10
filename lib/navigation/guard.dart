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

  static Future<bool> Function(BuildContext, Map<String, dynamic>?) _haveApp(bool mustHaveApp) {
    return (BuildContext context, Map<String, dynamic>? metadata) async {
      try {
        List<AppResponse> userApps = await context.read<UserApplicationModel>().fetchUserApplications();
        return userApps.isNotEmpty == mustHaveApp;
      } catch (e) {
        return false;
      }
    };
  }

  static String _toWelcome(context) {
    return BackofficeNavigator.welcome.path;
  }
}
