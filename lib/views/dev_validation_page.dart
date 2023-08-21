import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/api/response_models/api_error.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:client_common/views/error.dart';
import 'package:client_common/views/simple_page.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DevValidationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DevValidationPageState();
  }
}

class _DevValidationPageState extends State<DevValidationPage> {
  final logger = Logger('DevValidationPage');

  String code = "";

  @override
  Widget build(BuildContext context) {
    ApiError? validateDevError = context.select<AuthModel, ApiError?>((m) => m.validateDevStatus.error);
    bool hasError = context.select<AuthModel, bool>((m) => m.validateDevStatus.hasError());
    bool isLoading = context.select<AuthModel, bool>((m) => m.validateDevStatus.isFetching());

    return SimplePage(
      title: "Thank you for your registration",
      message: "Great things are about to happen! Do you confirm that you want to access our developer platform ?",
      child: LenraFlex(
        direction: Axis.vertical,
        fillParent: true,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 32,
        children: [
          LenraFlex(
            spacing: 16,
            fillParent: true,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: LenraButton(
                  text: "Become a developer",
                  disabled: isLoading,
                  onPressed: () {
                    validateDev();
                  },
                ),
              ),
              Flexible(
                child: LenraButton(
                  text: "Take me to the home page",
                  type: LenraComponentType.tertiary,
                  onPressed: () async {
                    const url = "https://www.lenra.io";
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      throw "Could not launch $url";
                    }
                  },
                ),
              ),
            ],
          ),
          if (hasError) Error(validateDevError!),
        ],
      ),
    );
  }

  void validateDev() {
    context.read<AuthModel>().validateDev().then((_) {
      CommonNavigator.go(context, BackofficeNavigator.welcome);
    });
  }
}
