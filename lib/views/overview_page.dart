import 'dart:async';

import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/api/response_models/build_response.dart';
import 'package:client_common/config/config.dart';
import 'package:client_common/models/build_model.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var selectedApp = context.read<UserApplicationModel>().selectedApp;
    var buildModel = context.read<BuildModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserApplicationModel>().fetchUserApplications().then(
        (value) {
          if (selectedApp != null) {
            buildModel.fetchBuilds(selectedApp.id);
          }
        },
      );
    });

    var theme = LenraTheme.of(context);
    // A bit dirty
    if (selectedApp == null) return Center(child: CircularProgressIndicator());
    List<BuildResponse> builds =
        context.select<BuildModel, List<BuildResponse>>((buildModel) => buildModel.buildsForApp(selectedApp.id));

    var hasPendingBuild = false;
    var hasPublishedBuild = false;

    if (builds.isNotEmpty) {
      builds.sort((a, b) => a.buildNumber.compareTo(b.buildNumber));

      // Check if there is a createBuildStatus that is currently fetching.
      var createBuildStatusFetching = buildModel.createBuildStatus[selectedApp.id]?.isFetching() ?? false;

      hasPendingBuild = builds.any((build) => build.status == BuildStatus.pending) || createBuildStatusFetching;

      if (hasPendingBuild) {
        timer = Timer(Duration(seconds: 5), () {
          setState(() {});
        });
      }

      hasPublishedBuild = builds.any((build) => build.status == BuildStatus.success);
    }

    return BackofficePage(
      title: Text("Overview"),
      mainActionWidget: LenraButton(
        text: "Publish my application",
        disabled: hasPendingBuild,
        onPressed: () => buildModel.createBuild(selectedApp.id),
      ),
      child: LenraFlex(
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
                  final url = "${Config.instance.appBaseUrl}${selectedApp.serviceName}";
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
              if (builds.isNotEmpty) buildRow(context, builds.last),
              if (builds.length >= 2 && builds.last.status == BuildStatus.pending)
                buildRow(context, builds.reversed.elementAt(1)),
            ],
          ),
          if (builds.isEmpty)
            Text(
              "Your application has not been built yet.\nClick “Publish my application” to create your first build.",
              style: theme.lenraTextThemeData.disabledBodyText,
              textAlign: TextAlign.center,
            ),
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

  String textFromStatus(BuildStatus status) {
    switch (status) {
      case BuildStatus.success:
        return "Published";

      case BuildStatus.pending:
        return "Building...";

      case BuildStatus.failure:
        return "Failure";

      default:
        return "Failure";
    }
  }

  TableRow buildRow(BuildContext context, BuildResponse buildResponse) {
    var theme = LenraTheme.of(context);
    return TableRow(children: [
      LenraTableCell(
        child: Text("#${buildResponse.buildNumber}"),
      ),
      LenraTableCell(
        child: Text(DateFormat.yMMMMd().add_jm().format(buildResponse.insertedAt)),
      ),
      LenraTableCell(
        child: LenraFlex(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(
              Icons.circle,
              color: colorFromStatus(buildResponse.status),
              size: theme.baseSize,
            ),
            Text(textFromStatus(buildResponse.status)),
          ],
        ),
      ),
    ]);
  }
}
