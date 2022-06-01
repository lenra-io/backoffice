import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/api/response_models/api_errors.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/views/error_list.dart';
import 'package:client_common/views/simple_page.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivationCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ActivationCodePageState();
  }
}

class _ActivationCodePageState extends State<ActivationCodePage> {
  final logger = Logger('ActivationCodePage');

  String code = "";

  @override
  Widget build(BuildContext context) {
    ApiErrors? validateDevErrors = context
        .select<AuthModel, ApiErrors?>((m) => m.validateDevStatus.errors);
    bool hasError =
        context.select<AuthModel, bool>((m) => m.validateDevStatus.hasError());
    bool isLoading = context
        .select<AuthModel, bool>((m) => m.validateDevStatus.isFetching());

    return SimplePage(
      title: "Thank you for your registration",
      message:
          "Great things are about to happen! We will send you soon a token to access our developer platform.",
      child: LenraFlex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 4,
        children: [
          LenraFlex(
            direction: Axis.vertical,
            spacing: 2,
            children: [
              LenraFlex(
                spacing: 2,
                fillParent: true,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: LenraTextField(
                      size: LenraComponentSize.large,
                      hintText: "Token",
                      onChanged: (String value) {
                        code = value;
                      },
                      onSubmitted: (_) {
                        submit();
                      },
                    ),
                  ),
                  LenraButton(
                    text: "Confirm the token",
                    disabled: isLoading,
                    onPressed: () {
                      submit();
                    },
                  ),
                ],
              ),
              if (hasError) ErrorList(validateDevErrors),
            ],
          ),
          LenraButton(
            text: "I don't have a token yet, take me to the home page.",
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
        ],
      ),
    );
  }

  void submit() {
    context.read<AuthModel>().validateDev(code).then((_) {
      Navigator.of(context).pushReplacementNamed(BackofficeNavigator.welcome);
    }).catchError((error) {
      logger.warning(error);
    });
  }
}
