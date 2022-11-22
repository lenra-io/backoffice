import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/api/response_models/app_response.dart';
import 'package:client_common/api/response_models/build_response.dart';
import 'package:client_common/api/response_models/get_main_env_response.dart';
import 'package:client_common/models/build_model.dart';
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
          ...context.read<UserApplicationModel>().userApps.map((app) => _ProjectRow(app: app))
        ],
      ),
    );
  }
}

class _ProjectRow extends StatefulWidget {
  final AppResponse app;

  _ProjectRow({required this.app});

  @override
  State<StatefulWidget> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
  bool isInitialized = false;
  GetMainEnvResponse? mainEnv;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      mainEnv = await context.read<UserApplicationModel>().getMainEnv(widget.app.id);
      await context.read<BuildModel>().fetchBuilds(widget.app.id);
      setState(() {
        isInitialized = true;
      });
    });
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    var theme = LenraTheme.of(context);

    if (isInitialized) {
      BuildResponse? latestBuild = context.read<BuildModel>().latestBuildForApp(widget.app.id);
      return InkWell(
        onTap: () {
          context.read<UserApplicationModel>().selectedApp = widget.app;
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
            fillParent: true,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: LenraFlex(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.app.name,
                      style: theme.lenraTextThemeData.headline3,
                    ),
                    LenraFlex(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LenraStatusSticker(
                          color: colorFromStatus(latestBuild?.status ?? BuildStatus.pending),
                        ),
                        Text(mainEnv!.mainEnv.isPublic ? "Public" : "Private"),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: LenraFlex(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Last update: ${latestBuild?.insertedAt ?? "Never"}",
                      style: theme.lenraTextThemeData.subtext,
                    ),
                    LenraButton(
                      type: LenraComponentType.tertiary,
                      leftIcon: Icon(Icons.more_horiz),
                      onPressed: () {
                        context.read<UserApplicationModel>().selectedApp = widget.app;
                        Navigator.of(context).pushNamed(BackofficeNavigator.settings);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
