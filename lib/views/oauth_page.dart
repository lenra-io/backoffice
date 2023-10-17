import 'package:client_common/api/lenra_http_client.dart';
import 'package:client_common/api/response_models/api_error.dart';
import 'package:client_common/api/response_models/user_response.dart';
import 'package:client_common/api/user_api.dart';
import 'package:client_common/config/config.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/oauth/oauth_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuthPage extends StatefulWidget {
  const OAuthPage({Key? key}) : super(key: key);

  @override
  OAuthPageState createState() => OAuthPageState();
}

class OAuthPageState extends State<OAuthPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(
        [
          isAuthenticated(context),
          rootBundle.loadString('assets/texts/oauth-page-code.js'),
        ],
      ),
      builder: ((context, snapshot) {
        if (snapshot.hasData && !(snapshot.data![0] as bool)) {
          var theme = LenraTheme.of(context);
          bool isMobileDevice = MediaQuery.of(context).size.width <= 875;

          return Scaffold(
            body: Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 40, top: 40),
                          child: Image.asset(
                            'assets/images/logo-vertical.png',
                            height: theme.baseSize * 8,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(100),
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: theme.lenraTextThemeData.headline1,
                                text: "Welcome to the ",
                                children: [
                                  TextSpan(
                                      text: "technical platform",
                                      style: TextStyle(color: LenraColorThemeData.lenraBlue)),
                                  TextSpan(text: " !"),
                                ],
                              ),
                            ),
                            SizedBox(height: 32),
                            LenraButton(
                              onPressed: () async {
                                bool authenticated = await authenticate(context);
                                if (authenticated) {
                                  context.go(context.read<OAuthModel>().beforeRedirectPath);
                                }
                              },
                              text: 'Sign in to Lenra',
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("You're not a dev?"),
                                  SizedBox(height: 14),
                                  RichText(
                                    text: TextSpan(
                                        text: "Go to the app platform",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: LenraColorThemeData.lenraBlue,
                                        ),
                                        children: [
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: Icon(Icons.arrow_forward, color: LenraColorThemeData.lenraBlue),
                                            ),
                                          )
                                        ],
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            String url = Config.instance.appBaseUrl;
                                            if (await canLaunchUrl(Uri.parse(url))) {
                                              await launchUrl(Uri.parse(url));
                                            } else {
                                              throw "Could not launch $url";
                                            }
                                          }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                rightSide(isMobileDevice, snapshot.data![1] as String)
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  static Future<bool> isAuthenticated(BuildContext context) async {
    OAuthModel oauthModel = context.read<OAuthModel>();

    AccessTokenResponse? token = await oauthModel.helper.getTokenFromStorage();
    if (token?.accessToken != null) {
      return await authenticate(context);
    }

    return false;
  }

  static Future<bool> authenticate(BuildContext context) async {
    AccessTokenResponse? response = await context.read<OAuthModel>().authenticate();
    if (response != null) {
      context.read<AuthModel>().accessToken = response;

      // Set the token for the global API instance
      LenraApi.instance.token = response.accessToken;

      if (context.read<AuthModel>().user == null) {
        try {
          UserResponse resp = await UserApi.me();
          context.read<AuthModel>().user = resp.user;
        } on ApiError catch (e) {
          if (e.reason == 'invalid_token') {
            // Delete access token from storage
            await context.read<OAuthModel>().helper.removeAllTokens();
            // Delete access token from AuthModel
            context.read<AuthModel>().accessToken = null;
            return false;
          }
        }
      }

      return true;
    }

    return false;
  }

  Widget rightSide(bool isMobileDevice, String code) {
    return isMobileDevice
        ? SizedBox()
        : Flexible(
            child: Container(
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(color: Color(0xFF1E232C)),
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: List.generate(
                        37,
                        (index) => Text(
                          (index + 1).toString(),
                          style: TextStyle(color: Color(0xFF475367), fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      children: [
                        Text(
                          code,
                          style: TextStyle(color: Color(0xFF70CBF2), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
