import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_common/views/simple_page.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/component/lenra_button.dart';

class WelcomeDevPage extends StatelessWidget {
  static const title = 'Welcome to the technical platform!';
  static const welcomeText =
      'You are now one of our first users and we thank you for that. We are at the very beginning of the project and therefore many new features will be implemented as we go along. You may also encounter some bugs so do not hesitate to share them with some comments and ideas to improve our product!';
  static const buttonText = 'Continue and create my first project';

  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: title,
      message: welcomeText,
      child: LenraButton(
        text: buttonText,
        onPressed: () => Navigator.of(context).pushReplacementNamed(BackofficeNavigator.firstProject),
      ),
    );
  }
}
