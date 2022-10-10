import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_backoffice/views/settings/git_integration_menu.dart';
import 'package:client_backoffice/views/settings/manage_access_menu.dart';
import 'package:client_common/api/response_models/build_response.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/component/lenra_text.dart';
import 'package:lenra_components/layout/lenra_container.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String currentContent = "Git integration";
  final logger = Logger("ChangeLostPasswordForm");

  @override
  Widget build(BuildContext context) {
    List<BuildResponse>? builds;

    return BackofficePage(
      title: Text("Settings"),
      /* TODO: change onPressed function */
      mainActionWidget: LenraButton(
        text: "Publish my application",
        disabled: builds?.any((build) => build.status == BuildStatus.pending) ?? true,
        onPressed: () {},
      ),
      child: LenraFlex(
        spacing: 16,
        children: [
          LenraContainer(
            constraints: BoxConstraints(maxWidth: 200),
            child: LenraFlex(
              spacing: 16,
              direction: Axis.vertical,
              children: [
                createSubMenuItem("Git integration", callback: () {
                  setState(() {
                    currentContent = "Git integration";
                  });
                }),
                createSubMenuItem("Manage access", callback: () {
                  setState(() {
                    currentContent = "Manage access";
                  });
                }),
              ],
            ),
          ),
          VerticalDivider(),
          LenraContainer(
            constraints: BoxConstraints(maxWidth: 480),
            child: showContent(currentContent),
          ),
        ],
      ),
    );
  }

  Widget createSubMenuItem(String text, {Function()? callback}) {
    return LenraContainer(
      decoration: BoxDecoration(color: currentContent == text ? LenraColorThemeData.lenraBlue : Colors.transparent),
      child: InkWell(
        onTap: callback,
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
                color: currentContent == text ? Colors.white : Colors.black,
              ),
            ),
            Icon(Icons.navigate_next, color: currentContent == text ? Colors.white : Colors.black),
          ],
        ),
      ),
    );
  }

  Widget showContent(String name) {
    switch (name) {
      case "Manage access":
        return ManageAccessMenu();
      case "Git integration":
        return GitIntegrationMenu();
      default:
        return Container();
    }
  }
}
