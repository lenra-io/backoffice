import 'dart:async';

import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/api/response_models/app_response.dart';
import 'package:client_common/api/response_models/build_response.dart';
import 'package:client_common/api/response_models/deployment_response.dart';
import 'package:client_common/config/config.dart';
import 'package:client_common/models/build_model.dart';
import 'package:client_common/models/deployment_model.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewPage extends StatefulWidget {
  final int appId;
  OverviewPage({Key? key, required this.appId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  Timer? timer;
  AppResponse? app;

  @override
  void initState() {
    var buildModel = context.read<BuildModel>();
    var deploymentModel = context.read<DeploymentModel>();

    UserApplicationModel userApplicationModel = context.read<UserApplicationModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userApplicationModel.fetchUserApplications().then(
        (_) async {
          AppResponse? app = userApplicationModel.getApp(widget.appId);

          if (app == null) {
            CommonNavigator.go(context, BackofficeNavigator.selectProject);
          } else {
            await Future.wait([
              buildModel.fetchBuilds(widget.appId),
              deploymentModel.fetchDeployments(widget.appId),
            ]);

            setState(() {
              this.app = app;
            });
          }
        },
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var buildModel = context.read<BuildModel>();
    var deploymentModel = context.read<DeploymentModel>();

    // A bit dirty
    if (app == null) return Center(child: CircularProgressIndicator());

    List<BuildResponse> builds = context.read<BuildModel>().buildsForApp(widget.appId);
    List<DeploymentResponse> deployments = context.read<DeploymentModel>().deploymentsForApp(widget.appId);

    var hasPendingDeployment = false;
    var hasPublishedDeployment = false;
    var hasPendingBuild = false;

    if (builds.isNotEmpty) {
      builds.sort((a, b) => a.buildNumber.compareTo(b.buildNumber));

      // Check if there is a createBuildStatus that is currently fetching.
      var createBuildStatusFetching = buildModel.createBuildStatus[widget.appId]?.isFetching() ?? false;

      hasPendingDeployment = deployments.any((deployment) =>
              deployment.status == DeploymentStatus.waitingForBuild ||
              deployment.status == DeploymentStatus.waitingForAppReady ||
              deployment.status == DeploymentStatus.created) ||
          createBuildStatusFetching;

      hasPendingBuild = builds.any((build) => build.status == BuildStatus.pending);

      if (!hasPendingDeployment && !hasPendingBuild && (timer?.isActive ?? false)) {
        timer?.cancel();
      }

      if ((hasPendingDeployment || hasPendingBuild) && !(timer?.isActive ?? false)) {
        deploymentModel.fetchDeployments(widget.appId).then((_) {
          buildModel.fetchBuilds(widget.appId).then((_) {
            setState(() {});
          });
        });

        timer = Timer.periodic(Duration(seconds: 5), (timer) {
          deploymentModel.fetchDeployments(widget.appId).then((_) {
            buildModel.fetchBuilds(widget.appId).then((_) {
              setState(() {});
            });
          });
        });
      }

      hasPublishedDeployment = deployments.any((deployment) => deployment.status == DeploymentStatus.success);
    }

    return BackofficePage(
      key: ValueKey("overview"),
      title: "Overview",
      actionWidget: LenraButton(
        text: "Publish my application",
        disabled: hasPendingDeployment || hasPendingBuild,
        onPressed: () => buildModel.createBuild(widget.appId).then((_) {
          setState(() {});
        }),
      ),
      child: buildPage(context, hasPublishedDeployment, deployments, builds),
    );
  }

  Widget buildPage(
      BuildContext context, bool hasPublishedBuild, List<DeploymentResponse> deployments, List<BuildResponse> builds) {
    var theme = LenraTheme.of(context);

    return LenraFlex(
      direction: Axis.vertical,
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LenraButton(
              disabled: !hasPublishedBuild,
              text: "See my application",
              type: LenraComponentType.secondary,
              onPressed: () async {
                final url = "${Config.instance.appBaseUrl}${app!.serviceName}";
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw "Could not launch $url";
                }
              },
            ),
          ],
        ),
        Table(
          children: [
            TableRow(children: [
              LenraTableCell(
                child: Text("Build number"),
              ),
              LenraTableCell(
                child: Text("Date"),
              ),
              LenraTableCell(
                child: Text("Build status"),
              ),
            ]),
            if (deployments.isNotEmpty)
              buildRow(
                  context, deployments.last, builds.firstWhere((element) => element.id == deployments.last.buildId)),
            if (deployments.length >= 2 &&
                deployments.last.status == DeploymentStatus.waitingForBuild &&
                deployments.last.status == DeploymentStatus.waitingForAppReady)
              buildRow(context, deployments.reversed.elementAt(1), builds.reversed.elementAt(1)),
          ],
        ),
        if (deployments.isEmpty)
          Text(
            "Your application has not been built yet.\nClick “Publish my application” to create your first build.",
            style: theme.lenraTextThemeData.disabledBodyText,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Color colorFromStatus(DeploymentStatus status) {
    switch (status) {
      case DeploymentStatus.success:
        return LenraColorThemeData.lenraFunGreenPulse;

      case DeploymentStatus.waitingForBuild:
        return LenraColorThemeData.lenraFunYellowPulse;

      case DeploymentStatus.waitingForAppReady:
        return LenraColorThemeData.lenraFunYellowPulse;

      case DeploymentStatus.created:
        return LenraColorThemeData.lenraGreyText;

      case DeploymentStatus.failure:
        return LenraColorThemeData.lenraFunRedPulse;

      default:
        return LenraColorThemeData.lenraFunRedPulse;
    }
  }

  String textFromStatus(DeploymentStatus status) {
    switch (status) {
      case DeploymentStatus.success:
        return "Published";

      case DeploymentStatus.waitingForBuild:
        return "Waiting for build...";

      case DeploymentStatus.waitingForAppReady:
        return "Waiting for the app to be ready...";

      case DeploymentStatus.created:
        return "Created";

      case DeploymentStatus.failure:
        return "Failure";

      default:
        return "Failure";
    }
  }

  TableRow buildRow(BuildContext context, DeploymentResponse deploymentResponse, BuildResponse buildResponse) {
    var theme = LenraTheme.of(context);
    return TableRow(children: [
      LenraTableCell(
        child: Text("#${buildResponse.buildNumber}"),
      ),
      LenraTableCell(
        child: Text(DateFormat.yMMMMd().add_jm().format(deploymentResponse.insertedAt)),
      ),
      LenraTableCell(
        child: LenraFlex(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(
              Icons.circle,
              color: colorFromStatus(deploymentResponse.status),
              size: theme.baseSize,
            ),
            Text(textFromStatus(deploymentResponse.status)),
          ],
        ),
      ),
    ]);
  }
}
