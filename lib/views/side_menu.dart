import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/api/response_models/app_response.dart';
import 'package:client_common/api/response_models/environment_response.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BackofficeSideMenu extends StatelessWidget {
  const BackofficeSideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logger = Logger('BackofficeSideMenu');
    var theme = LenraTheme.of(context);
    return Container(
      width: 196,
      color: LenraColorThemeData.lenraBlack,
      child: LenraTheme(
        themeData: theme.copyWith(
          lenraTextThemeData: theme.lenraTextThemeData.copyWith(
            bodyText: theme.lenraTextThemeData.bodyText.copyWith(
              color: LenraColorThemeData.lenraWhite,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: theme.baseSize * 3,
                horizontal: theme.baseSize * 6,
              ),
              child: Image.asset('assets/images/logo-horizontal-white.png'),
            ),
            Expanded(
              child: SizedBox.expand(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: _ProjectMenu(),
                  ),
                ),
              ),
            ),
            Column(children: [
              BackofficeSideMenuItem(
                "Account",
                icon: Icons.account_circle_outlined,
                disabled: true,
              ),
              BackofficeSideMenuItem(
                "Documentation",
                icon: Icons.book_outlined,
                onPressed: () async {
                  const url = "https://doc.lenra.io";
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw "Could not launch $url";
                  }
                },
              ),
              BackofficeSideMenuItem(
                "Logout",
                icon: Icons.logout,
                onPressed: () {
                  context.read<AuthModel>().logout().then((value) {
                    Navigator.of(context)
                        .pushReplacementNamed(CommonNavigator.loginRoute);
                  }).catchError((error) {
                    logger.warning(error);
                  });
                },
              ),
              BackofficeSideMenuItem(
                "Contact us",
                icon: Icons.messenger_outline_rounded,
                onPressed: () async {
                  const url = "mailto:contact@lenra.io";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw "Could not launch $url";
                  }
                },
              ),
            ]),
            SizedBox(height: theme.baseSize * 2)
          ],
        ),
      ),
    );
  }
}

class _ProjectMenu extends StatefulWidget {
  const _ProjectMenu({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ProjectMenuState();
  }
}

class _ProjectMenuState extends State<_ProjectMenu> {
  AppResponse? selectedApp;
  EnvironmentResponse? mainEnv;
  bool isInitialized = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .read<UserApplicationModel>()
          .fetchUserApplications()
          .then((value) {
        selectedApp = context.read<UserApplicationModel>().selectedApp;
        context.read<UserApplicationModel>().getMainEnv(selectedApp!.id);
        isInitialized = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mainEnv = context
        .select<UserApplicationModel, EnvironmentResponse?>((m) => m.mainEnv);

    var theme = LenraTheme.of(context);
    if (selectedApp == null) return SizedBox.shrink();
    return Column(children: [
      Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: theme.baseSize * 3,
            horizontal: theme.baseSize * 2,
          ),
          child: isInitialized
              ? LenraFlex(
                  direction: Axis.vertical,
                  spacing: 0.5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedApp!.name,
                      style: theme.lenraTextThemeData.headline2,
                    ),
                    LenraFlex(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 1,
                      children: [
                        Icon(
                          Icons.circle,
                          color: mainEnv!.isPublic
                              ? LenraColorThemeData.lenraCustomGreen
                              : LenraColorThemeData.lenraCustomRed,
                          size: theme.baseSize,
                        ),
                        Text(
                          "${mainEnv!.isPublic ? 'Public' : 'Private'} access",
                        ),
                      ],
                    )
                  ],
                )
              : LenraFlex(
                  children: [CircularProgressIndicator()],
                  mainAxisAlignment: MainAxisAlignment.center)),
      BackofficeSideMenuRoute(
        "Overview",
        icon: Icons.bookmark_border_rounded,
        route: CommonNavigator.homeRoute,
      ),
      BackofficeSideMenuRoute(
        "Environments",
        icon: Icons.layers_outlined,
        disabled: true,
        route: "null",
      ),
      BackofficeSideMenuRoute(
        "Builds",
        icon: Icons.bolt,
        disabled: true,
        route: "null",
      ),
      BackofficeSideMenuRoute(
        "Settings",
        icon: Icons.settings_outlined,
        disabled: false,
        route: BackofficeNavigator.settings,
      ),
    ]);
  }
}

class BackofficeSideMenuItem extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool selected;
  final bool disabled;
  final GestureTapCallback? onPressed;

  const BackofficeSideMenuItem(
    this.text, {
    Key? key,
    this.icon,
    this.selected = false,
    this.disabled = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = LenraTheme.of(context);
    var color = disabled
        ? theme.lenraTextThemeData.disabledBodyText.color
        : theme.lenraTextThemeData.bodyText.color;
    var ret = Container(
      color: selected ? LenraColorThemeData.lenraBlue : Colors.transparent,
      padding: EdgeInsets.symmetric(
          horizontal: theme.baseSize * 2, vertical: theme.baseSize),
      width: double.infinity,
      child: Row(children: [
        Container(
          width: theme.baseSize * 3.5,
          child: icon != null
              ? Icon(
                  icon,
                  color: color,
                  size: theme.baseSize * 2,
                )
              : null,
        ),
        Text(
          text,
          style: TextStyle(color: color),
          textAlign: TextAlign.left,
        ),
      ]),
    );
    if (disabled || onPressed == null) return ret;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        hoverColor: LenraColorThemeData.lenraBlueHover,
        child: ret,
      ),
    );
  }
}

class BackofficeSideMenuRoute extends StatelessWidget {
  final String text;
  final String route;
  final IconData? icon;
  final bool disabled;

  const BackofficeSideMenuRoute(
    this.text, {
    Key? key,
    required this.route,
    this.icon,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isCurrent = CommonNavigator.currentRoute == route;
    return BackofficeSideMenuItem(
      text,
      icon: icon,
      disabled: disabled,
      selected: isCurrent,
      onPressed: (!disabled && !isCurrent)
          ? () => Navigator.of(context).pushNamed(route)
          : null,
    );
  }
}
