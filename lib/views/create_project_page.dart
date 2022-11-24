import 'package:client_backoffice/views/create_project_form.dart';
import 'package:client_common/views/simple_page.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';

class CreateProjectPage extends StatelessWidget {
  static const String titleText = 'Create your project';
  static const String messageText =
      'Please give a name for your project and provide us the url of your git repository to be able to create your application.';
  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: titleText,
      message: messageText,
      child: LenraFlex(
        direction: Axis.vertical,
        children: [
          CreateProjectForm(),
        ],
      ),
    );
  }
}
