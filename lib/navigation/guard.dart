import 'dart:async';

import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_backoffice/views/oauth_page.dart';
import 'package:client_common/navigator/guard.dart';
import 'package:flutter/material.dart';

typedef IsValid = Future<bool> Function(BuildContext, Map<String, dynamic>?);

class BackofficeGuard extends Guard {
  BackofficeGuard({required super.isValid, required super.onInvalid});

  static final BackofficeGuard checkHaveApp = BackofficeGuard(isValid: Guard.haveApp(true), onInvalid: _toWelcome);

  static final Guard checkIsAuthenticated = Guard(isValid: isAuthenticated, onInvalid: toOauth);

  static Future<bool> isAuthenticated(BuildContext context) async {
    return OAuthPageState.isAuthenticated(context);
  }

  static String _toWelcome(context) {
    return BackofficeNavigator.welcome.path;
  }

  static String toOauth(context) {
    return BackofficeNavigator.oauth.path;
  }
}
