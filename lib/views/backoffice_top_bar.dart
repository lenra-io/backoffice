import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';

class BackofficeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool mobileView;
  final Widget? actionWidget;

  const BackofficeTopBar({
    Key? key,
    required this.title,
    required this.mobileView,
    this.actionWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 6,
      title: Text(title),
      actions: [
        if (actionWidget != null) Padding(padding: EdgeInsets.all(10), child: actionWidget!),
      ],
      backgroundColor: LenraColorThemeData.lenraWhite,
      foregroundColor: LenraColorThemeData.lenraBlack,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
