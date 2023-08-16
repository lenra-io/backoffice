import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/api/response_models/app_response.dart';
import 'package:client_common/api/response_models/environment_response.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:client_common/navigator/common_navigator.dart';
import 'package:client_common/oauth/oauth_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BackofficeDrawer extends StatelessWidget {
  const BackofficeDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logger = Logger('BackofficeSideMenu');
    var theme = LenraTheme.of(context);
    return Drawer(
      width: 196,
      child: Container(
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
                  child: SingleChildScrollView(
                    child: _ProjectMenu(),
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
                    const url = "https://docs.lenra.io";
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
                  onPressed: () async {
                    await context.read<OAuthModel>().helper.disconnect();
                    context.go("/");
                  },
                ),
                BackofficeSideMenuItem(
                  "Contact us",
                  icon: Icons.messenger_outline_rounded,
                  onPressed: () async {
                    const url = "mailto:contact@lenra.io";
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
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
      ),
    );
  }
}

class _ProjectMenu extends StatefulWidget {
  const _ProjectMenu({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ProjectMenuState();
  }
}

class _ProjectMenuState extends State<_ProjectMenu> {
  @override
  Widget build(BuildContext context) {
    var routeParams = GoRouterState.of(context).params;
    int appId = routeParams.containsKey("appId") ? int.tryParse(routeParams["appId"]!)! : -1;

    AppResponse? selectedApp = context.read<UserApplicationModel>().getApp(appId);

    if (selectedApp == null) return SizedBox.shrink();

    EnvironmentResponse? mainEnv = context.select<UserApplicationModel, EnvironmentResponse?>((m) => m.mainEnv);

    if (mainEnv == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserApplicationModel>().getMainEnv(selectedApp.id!);
      });
      return SizedBox.shrink();
    }
    return readyWidget(context, selectedApp, mainEnv);
  }

  void Function() navigateTo(BuildContext context, GoRoute? route,
      {Map<String, String> params = const <String, String>{}}) {
    return () {
      if (route != null) CommonNavigator.go(context, route, params: params);
    };
  }

  Widget readyWidget(BuildContext context, AppResponse selectedApp, EnvironmentResponse mainEnv) {
    var theme = LenraTheme.of(context);
    return Column(children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: theme.baseSize * 3,
          horizontal: theme.baseSize * 2,
        ),
        child: LenraFlex(
          direction: Axis.vertical,
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: LenraFlex(
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    color: LenraColorThemeData.lenraBlue,
                  ),
                  Text(
                    "Projects",
                    style: theme.lenraTextThemeData.blueBodyText,
                  ),
                ],
              ),
              onTap: navigateTo(context, BackofficeNavigator.selectProject),
            ),
            Text(
              selectedApp.name,
              style: theme.lenraTextThemeData.headline2,
            ),
            LenraFlex(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(
                  Icons.circle,
                  color: mainEnv.isPublic ? LenraColorThemeData.lenraCustomGreen : LenraColorThemeData.lenraCustomRed,
                  size: theme.baseSize,
                ),
                Text(
                  "${mainEnv.isPublic ? 'Public' : 'Private'} access",
                ),
              ],
            )
          ],
        ),
      ),
      BackofficeSideMenuRoute(
        "Overview",
        icon: Icons.bookmark_border_rounded,
        selected: CommonNavigator.isCurrent(context, BackofficeNavigator.overview),
        onPressed: navigateTo(context, BackofficeNavigator.overview, params: {"appId": selectedApp.id.toString()}),
      ),
      BackofficeSideMenuRoute(
        "Environments",
        icon: Icons.layers_outlined,
        disabled: true,
        selected: false,
        onPressed: navigateTo(context, null),
      ),
      BackofficeSideMenuRoute(
        "Builds",
        icon: Icons.bolt,
        disabled: true,
        selected: false,
        onPressed: navigateTo(context, null),
      ),
      BackofficeSideMenuRoute(
        "Settings",
        icon: Icons.settings_outlined,
        selected: CommonNavigator.isCurrent(context, BackofficeNavigator.settings),
        onPressed: navigateTo(context, BackofficeNavigator.gitSettings, params: {"appId": selectedApp.id.toString()}),
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
    var color = disabled ? theme.lenraTextThemeData.disabledBodyText.color : theme.lenraTextThemeData.bodyText.color;
    var ret = Container(
      color: selected ? LenraColorThemeData.lenraBlue : Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: theme.baseSize * 2, vertical: theme.baseSize),
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
  final IconData? icon;
  final bool disabled;
  final void Function()? onPressed;
  final bool selected;

  const BackofficeSideMenuRoute(
    this.text, {
    Key? key,
    this.icon,
    this.disabled = false,
    required this.selected,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackofficeSideMenuItem(
      text,
      icon: icon,
      disabled: disabled,
      selected: selected,
      onPressed: (!disabled && !selected) ? onPressed : null,
    );
  }
}
