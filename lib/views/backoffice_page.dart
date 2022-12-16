import 'package:client_backoffice/views/backoffice_drawer.dart';
import 'package:client_backoffice/views/backoffice_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';

class BackofficePage extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? actionWidget;

  const BackofficePage({
    required this.child,
    required this.title,
    Key? key,
    this.actionWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    var mobileView = media.size.width < 1000;

    var drawer = BackofficeDrawer();

    var scaffold = Scaffold(
      appBar: BackofficeTopBar(
        mobileView: mobileView,
        actionWidget: actionWidget,
        title: title,
      ),
      backgroundColor: LenraColorThemeData.lenraWhite,
      body: wrapChild(context),
      drawer: mobileView ? drawer : null,
    );

    if (mobileView) {
      return SizedBox.expand(child: scaffold);
    }
    return Row(children: [drawer, Expanded(child: scaffold)]);
  }

  Widget wrapChild(BuildContext context) {
    var theme = LenraTheme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(theme.baseSize * 4),
      child: child,
    );
  }
}
