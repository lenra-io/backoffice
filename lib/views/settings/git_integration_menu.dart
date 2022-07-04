import 'package:client_common/api/request_models/update_app_request.dart';
import 'package:client_common/lenra_application/api_error_snack_bar.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/component/lenra_text.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class GitIntegrationMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GitIntegrationMenuState();
  }
}

class _GitIntegrationMenuState extends State<GitIntegrationMenu> {
  final logger = Logger("GitIntegrationMenu");
  final _formKey = GlobalKey<FormState>();
  String newRepositoryUrl = "";
  String newRepositoryBranch = "";
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    _controller.text = context.read<UserApplicationModel>().selectedApp?.repository ?? "";
    newRepositoryUrl = _controller.text;
    _branchController.text = context.read<UserApplicationModel>().selectedApp?.repositoryBranch ?? "";
    newRepositoryBranch = _branchController.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;
    bool urlChanged = newRepositoryUrl != context.read<UserApplicationModel>().selectedApp?.repository;
    bool branchChanged =
        newRepositoryBranch != (context.read<UserApplicationModel>().selectedApp?.repositoryBranch ?? "");

    return Form(
      key: _formKey,
      child: LenraFlex(
        direction: Axis.vertical,
        spacing: 1,
        children: [
          LenraText(
            text: "Git integration",
            style: lenraTextThemeData.headline3,
          ),
          LenraText(
            text:
                "You can import your project from many platforms such as GitLab or GitHub. To do this, indicate the URL of the repository which contains your project.",
            style: lenraTextThemeData.bodyText,
          ),
          LenraFlex(
            direction: Axis.vertical,
            children: [
              LenraText(
                text: "URL of the repository",
                style: lenraTextThemeData.bodyText,
              ),
              LenraFlex(
                spacing: 1,
                children: [
                  Expanded(
                    child: LenraTextFormField(
                      validator: urlChanged
                          ? validator([
                              checkNotEmpty(error: "You must enter a repository URL"),
                              checkGitRepoFormat(error: "The repository URL is not valid"),
                            ])
                          : null,
                      size: LenraComponentSize.large,
                      hintText: "https://repo-URL.git",
                      controller: _controller,
                      onSubmitted: (value) {
                        submitForm();
                      },
                      onChanged: (value) {
                        setState(() {
                          newRepositoryUrl = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          LenraFlex(
            direction: Axis.vertical,
            children: [
              LenraText(
                text: "Branch of the repository",
                style: lenraTextThemeData.bodyText,
              ),
              LenraFlex(
                spacing: 1,
                children: [
                  Expanded(
                    child: LenraTextFormField(
                      size: LenraComponentSize.large,
                      controller: _branchController,
                      onSubmitted: (value) {
                        submitForm();
                      },
                      onChanged: (value) {
                        setState(() {
                          newRepositoryBranch = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: LenraButton(
              text: "Save",
              onPressed: () {
                submitForm();
              },
              disabled: isLoading || (!urlChanged && !branchChanged),
            ),
          ),
        ],
      ),
    );
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      bool urlChanged = newRepositoryUrl != context.read<UserApplicationModel>().selectedApp?.repository;
      bool branchChanged =
          newRepositoryBranch != (context.read<UserApplicationModel>().selectedApp?.repositoryBranch ?? "");

      if (urlChanged || branchChanged) {
        setState(() {
          isLoading = true;
        });
        int selectedAppId = context.read<UserApplicationModel>().selectedApp!.id;
        context
            .read<UserApplicationModel>()
            .updateApp(
              UpdateAppRequest(
                id: selectedAppId,
                repository: urlChanged ? newRepositoryUrl : null,
                repositoryBranch: branchChanged ? newRepositoryBranch : null,
              ),
            )
            .then((value) {
          context.read<UserApplicationModel>().fetchUserApplications().then((value) {
            setState(() {
              isLoading = false;
            });
          });
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(ApiErrorSnackBar(
            error: error,
            actionLabel: 'Close',
            onPressAction: () {},
          ));
          logger.warning(error);
        });
      }
    }
  }
}
