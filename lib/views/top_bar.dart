import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';

class BackofficeTopBar extends StatelessWidget {
  final Widget title;
  final bool mobileView;

  const BackofficeTopBar({
    Key? key,
    required this.title,
    required this.mobileView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = LenraTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 2 * theme.baseSize,
        bottom: 2 * theme.baseSize,
        left: ((mobileView ? 6 + 4 : 0) + 4) * theme.baseSize,
        right: 4 * theme.baseSize,
      ),
      decoration: BoxDecoration(
        color: LenraColorThemeData.lenraWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 1), // changes position of shadow
          ),
          BoxShadow(
            color: LenraColorThemeData.lenraDisabledGray.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 16,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: theme.lenraTextThemeData.bodyText.merge(theme.lenraTextThemeData.headline2),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: this.title,
      ),
    );
  }
}
