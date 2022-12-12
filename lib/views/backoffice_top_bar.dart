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

    // var theme = LenraTheme.of(context);
    //
    // return Container(
    //   width: double.infinity,
    //   padding: EdgeInsets.only(
    //     top: 2 * theme.baseSize,
    //     bottom: 2 * theme.baseSize,
    //     left: 2 * theme.baseSize,
    //     right: 4 * theme.baseSize,
    //   ),
    //   decoration: BoxDecoration(
    //     color: LenraColorThemeData.lenraWhite,
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.15),
    //         spreadRadius: 0,
    //         blurRadius: 8,
    //         offset: Offset(0, 1), // changes position of shadow
    //       ),
    //       BoxShadow(
    //         color: LenraColorThemeData.lenraDisabledGray.withOpacity(0.25),
    //         spreadRadius: 0,
    //         blurRadius: 16,
    //         offset: Offset(0, 4), // changes position of shadow
    //       ),
    //     ],
    //   ),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       Row(
    //         children: [
    //           if (mobileView)
    //             IconButton(
    //               padding: EdgeInsets.all(4),
    //               icon: const Icon(Icons.menu),
    //               onPressed: () {
    //                 Scaffold.of(context).openDrawer();
    //               },
    //               tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    //             ),
    //           Padding(
    //             padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
    //             child: DefaultTextStyle(
    //               style: theme.lenraTextThemeData.bodyText.merge(theme.lenraTextThemeData.headline2),
    //               softWrap: false,
    //               overflow: TextOverflow.ellipsis,
    //               child: Text(title),
    //             ),
    //           ),
    //         ],
    //       ),
    //       if (actionWidget != null) actionWidget!
    //     ],
    //   ),
    // );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
