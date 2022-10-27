import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/api/response_models/app_response.dart';
import 'package:client_common/api/response_models/build_response.dart';
import 'package:client_common/api/response_models/get_main_env_response.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/component/lenra_status_sticker.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:provider/provider.dart';

class SelectProjectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SelectProjectPageState();
}

class _SelectProjectPageState extends State<SelectProjectPage> {
  @override
  Widget build(BuildContext context) {
    var theme = LenraTheme.of(context);
    return BackofficePage(
      title: Text("Project selection"),
      mainActionWidget: LenraButton(
        text: "Create a new project",
        onPressed: () => Navigator.of(context).pushNamed(BackofficeNavigator.createProject),
      ),
      child: LenraFlex(
        direction: Axis.vertical,
        spacing: 16,
        children: [
          Text(
            "My projects",
            style: theme.lenraTextThemeData.headline2,
          ),
          ...context.read<UserApplicationModel>().userApps.map((app) => buildRow(context, app))
        ],
      ),
    );
  }

  Color colorFromStatus(BuildStatus status) {
    switch (status) {
      case BuildStatus.success:
        return LenraColorThemeData.lenraFunGreenPulse;

      case BuildStatus.pending:
        return LenraColorThemeData.lenraFunYellowPulse;

      case BuildStatus.failure:
        return LenraColorThemeData.lenraFunRedPulse;

      default:
        return LenraColorThemeData.lenraFunRedPulse;
    }
  }

  Widget buildRow(BuildContext context, AppResponse app) {
    var theme = LenraTheme.of(context);

    return FutureBuilder(
      future: context.read<UserApplicationModel>().getMainEnv(app.id),
      builder: (BuildContext context, AsyncSnapshot<GetMainEnvResponse> snapshot) {
        if (snapshot.hasData) {
          return InkWell(
            onTap: () {
              context.read<UserApplicationModel>().selectedApp = app;
              Navigator.of(context).pushNamed(BackofficeNavigator.homeRoute);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: LenraColorThemeData.greyLight),
              ),
              child: LenraFlex(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 28),
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    app.name,
                    style: theme.lenraTextThemeData.headline3,
                  ),
                  LenraFlex(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LenraStatusSticker(
                          color: colorFromStatus(BuildStatus.success)), // TODO: Get real status from the app
                      Text(snapshot.data!.mainEnv.isPublic
                          ? "Public"
                          : "Private"), // TODO: Get real visibility from the app
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
