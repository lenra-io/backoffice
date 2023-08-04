import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:client_common/views/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class CreateProjectForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateProjectFormState();
  }
}

class _CreateProjectFormState extends State<CreateProjectForm> {
  final logger = Logger("CreateProjectForm");

  final _formKey = GlobalKey<FormState>();

  String projectName = "";
  String gitRepository = "";
  String? appNameTextfieldError = "";

  @override
  Widget build(BuildContext context) {
    bool isLoading = context.select<UserApplicationModel, bool>((m) => m.createApplicationStatus.isFetching());

    return Form(
      key: _formKey,
      child: LenraFlex(
        direction: Axis.vertical,
        spacing: 32,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          fields(context),
          LenraFlex(
            spacing: 16,
            children: [
              cancelButton(context),
              LoadingButton(
                text: "Create my project",
                loading: isLoading,
                onPressed: () {
                  submit();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget fields(BuildContext context) {
    return LenraFlex(
      direction: Axis.vertical,
      spacing: 16,
      children: [
        LenraTextFormField(
          validator: validator([
            checkLength(min: 2, max: 64),
          ]),
          description: '64 characters maximum',
          label: 'Name of your project',
          onChanged: (newValue) {
            setState(() {
              projectName = newValue;
              appNameTextfieldError = "";
            });
          },
          onSubmitted: (_) {
            submit();
          },
          errorMessage: appNameTextfieldError,
        ),
        LenraTextFormField(
          validator: validator([
            checkGitRepoFormat(),
          ]),
          description:
              'For now, the repository must be public. The default repository branch will be used to deploy your app.',
          label: 'URL of your Git repository',
          hintText: 'https://mygit.io/my_profile/my_project.git',
          onChanged: (newValue) {
            setState(() {
              gitRepository = newValue;
            });
          },
          onSubmitted: (_) {
            submit();
          },
        ),
      ],
    );
  }

  LenraButton cancelButton(BuildContext context) {
    bool hasApp = context.read<UserApplicationModel>().userApps.isNotEmpty;

    if (hasApp) {
      return LenraButton(
        text: "Cancel",
        onPressed: () {
          CommonNavigator.go(context, BackofficeNavigator.selectProject);
        },
        type: LenraComponentType.secondary,
      );
    } else {
      return LenraButton(
        text: "Logout",
        onPressed: () {
          context.read<AuthModel>().logout().then((value) {
            // TODO: fix this
            // CommonNavigator.go(context, CommonNavigator.sign, extra: {"register": false});
          }).catchError((error) {
            logger.warning(error);
          });
        },
        type: LenraComponentType.secondary,
      );
    }
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      context.read<UserApplicationModel>().createApp(projectName, gitRepository).then((app) {
        CommonNavigator.go(context, BackofficeNavigator.overview, params: {"appId": app.id.toString()});
      }).catchError((error) {
        if (error.reason == "invalid_name") {
          setState(() {
            appNameTextfieldError = "This app name is already taken.";
          });
        }
        logger.warning(error);
      });
    }
  }
}
