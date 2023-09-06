import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lenra_components/component/lenra_text.dart';
import 'package:lenra_components/layout/lenra_container.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';

class SettingsPage extends StatelessWidget {
  final Widget child;
  final int appId;
  final logger = Logger("ChangeLostPasswordForm");

  SettingsPage({Key? key, required this.appId, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackofficePage(
      key: ValueKey("settings"),
      title: "Settings",
      child: buildPage(context),
    );
  }

  Widget buildPage(BuildContext context) {
    return LenraFlex(
      spacing: 16,
      children: [
        LenraContainer(
          constraints: BoxConstraints(maxWidth: 200),
          child: LenraFlex(
            spacing: 16,
            direction: Axis.vertical,
            children: [
              createSubMenuItem(
                context,
                "Git integration",
                BackofficeNavigator.gitSettings,
              ),
              createSubMenuItem(
                context,
                "Manage access",
                BackofficeNavigator.accessSettings,
              ),
              createSubMenuItem(
                context,
                "External clients",
                BackofficeNavigator.oauthSettings,
              )
            ],
          ),
        ),
        VerticalDivider(),
        LenraContainer(
          constraints: BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ],
    );
  }

  Widget createSubMenuItem(BuildContext context, String text, GoRoute route) {
    var isCurrentRoute = CommonNavigator.isCurrent(context, route);
    print("IS CURRENT: ${isCurrentRoute}");
    return LenraContainer(
      decoration: BoxDecoration(color: isCurrentRoute ? LenraColorThemeData.lenraBlue : Colors.transparent),
      child: InkWell(
        onTap: () {
          CommonNavigator.go(context, route, params: {"appId": appId.toString()});
        },
        hoverColor: LenraColorThemeData.lenraBlue,
        child: LenraFlex(
          fillParent: true,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          padding: EdgeInsets.symmetric(horizontal: 2),
          children: [
            LenraText(
              text: text,
              style: TextStyle(
                color: isCurrentRoute ? Colors.white : Colors.black,
              ),
            ),
            Icon(Icons.navigate_next, color: isCurrentRoute ? Colors.white : Colors.black),
          ],
        ),
      ),
    );
  }
}
