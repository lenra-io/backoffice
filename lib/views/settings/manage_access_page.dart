import 'package:client_common/api/request_models/create_environment_user_access_request.dart';
import 'package:client_common/api/request_models/update_environment_request.dart';
import 'package:client_common/api/response_models/api_error.dart';
import 'package:client_common/lenra_application/api_error_snack_bar.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/component/lenra_button.dart';
import 'package:lenra_components/component/lenra_text.dart';
import 'package:lenra_components/component/lenra_text_form_field.dart';
import 'package:lenra_components/component/lenra_toggle.dart';
import 'package:lenra_components/layout/lenra_flex.dart';
import 'package:lenra_components/theme/lenra_theme.dart';
import 'package:lenra_components/utils/form_validators.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class ManageAccessPage extends StatefulWidget {
  final int appId;
  ManageAccessPage({required this.appId});
  @override
  State<StatefulWidget> createState() => _ManageAccessPageState();
}

class _ManageAccessPageState extends State<ManageAccessPage> {
  final logger = Logger("ManageAccessMenu");
  final _formKey = GlobalKey<FormState>();
  bool isPublic = false;
  bool isInitialized = false;
  String textfieldUserEmail = "";
  List<String> invitedUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var mainEnvRequest = context.read<UserApplicationModel>().getMainEnv(widget.appId);
      mainEnvRequest.then(
        (mainEnv) {
          isPublic = mainEnv.mainEnv.isPublic;
          isInitialized = true;
          context.read<UserApplicationModel>().getInvitedUsers(widget.appId, mainEnv.mainEnv.id).then((accesses) {
            setState(() {
              invitedUsers = accesses.accesses.map((access) => access.email!).toList();
            });
          });
        },
      ).catchError((error) {
        logger.warning(error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lenraTextThemeData = LenraTheme.of(context).lenraTextThemeData;

    return isInitialized
        ? LenraFlex(
            spacing: 8,
            direction: Axis.vertical,
            children: [
              Text("Manage access", style: lenraTextThemeData.headline3),
              Text(
                  "Set up the access to your application : Public to let any Lenra user use it, or Private and invite other users with their e-mail adresses."),
              LenraFlex(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LenraText(
                    text: "Private",
                    style: !isPublic ? lenraTextThemeData.headlineBody : lenraTextThemeData.bodyText,
                  ),
                  LenraToggle(
                    value: isPublic,
                    onPressed: (value) {
                      var mainEnvRequest = context.read<UserApplicationModel>().getMainEnv(widget.appId);
                      mainEnvRequest.then(
                        (mainEnv) {
                          context
                              .read<UserApplicationModel>()
                              .updateEnvironment(
                                  widget.appId, mainEnv.mainEnv.id, UpdateEnvironmentRequest(isPublic: value))
                              .then((envResponse) {
                            setState(() {
                              isPublic = envResponse.environmentResponse.isPublic;
                            });
                          });
                        },
                      ).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(ApiErrorSnackBar(
                          error: error,
                          actionLabel: 'Close',
                          onPressAction: () {},
                        ));
                        logger.warning(error);
                      });
                    },
                  ),
                  LenraText(
                    text: "Public",
                    style: isPublic ? lenraTextThemeData.headlineBody : lenraTextThemeData.bodyText,
                  ),
                ],
              ),
              LenraText(
                text: "Invite users",
                style: lenraTextThemeData.headline3,
              ),
              ...invitedUsers.map((user) {
                return LenraFlex(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.circle, size: 6),
                    LenraText(
                      text: user,
                      style: lenraTextThemeData.headlineBody,
                    )
                  ],
                );
              }),
              Form(
                key: _formKey,
                child: LenraTextFormField(
                  validator: validator([
                    checkNotEmpty(error: "Please enter an email"),
                    checkEmailFormat(error: "Invalid email format"),
                  ]),
                  label: "Invite a new user",
                  hintText: "test@lenra.io",
                  onChanged: (value) {
                    textfieldUserEmail = value;
                  },
                  onSubmitted: (_) {
                    submit();
                  },
                ),
              ),
              LenraButton(
                text: "Invite user",
                onPressed: () {
                  submit();
                },
              ),
            ],
          )
        : Align(alignment: Alignment.topCenter, child: CircularProgressIndicator());
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      var mainEnvRequest = context.read<UserApplicationModel>().getMainEnv(widget.appId);
      mainEnvRequest.then(
        (mainEnv) {
          context
              .read<UserApplicationModel>()
              .inviteUser(
                  widget.appId, mainEnv.mainEnv.id, CreateEnvironmentUserAccessRequest(email: textfieldUserEmail))
              .then((envResponse) {
            setState(() {
              invitedUsers.add(textfieldUserEmail);
            });
          }).catchError((error) {
            logError(error);
          });
        },
      ).catchError((error) {
        logError(error);
      });
    }
  }

  void logError(ApiError error) {
    ScaffoldMessenger.of(context).showSnackBar(ApiErrorSnackBar(
      error: error,
      actionLabel: 'Close',
      onPressAction: () {},
    ));
    logger.warning(error);
  }
}
