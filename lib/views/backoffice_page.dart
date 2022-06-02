import 'package:client_backoffice/views/side_menu.dart';
import 'package:client_backoffice/views/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();
_BackofficeBurgerMenuManagerState _burgerMenuState = _BackofficeBurgerMenuManagerState();

class BackofficePage extends StatelessWidget {
  final Widget child;
  final Widget? title;
  final Widget? mainActionWidget;

  const BackofficePage({
    Key? key,
    this.title,
    this.mainActionWidget,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = LenraTheme.of(context);
    MediaQueryData media = MediaQuery.of(context);
    var mobileView = media.size.width < 1000;

    var menu = BackofficeSideMenu();

    var content = SizedBox.expand(
      child: Column(children: [
        if (title != null || mainActionWidget != null)
          BackofficeTopBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null) title!,
                if (mainActionWidget != null) mainActionWidget!,
              ],
            ),
            mobileView: mobileView,
          ),
        Expanded(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(theme.baseSize * 4),
            child: child,
          ),
        ),
      ]),
    );

    if (mobileView) {
      return Stack(children: [
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: LenraColorThemeData.lenraWhite,
          body: content,
          drawer: Drawer(
            child: menu,
          ),
          onDrawerChanged: (isOpened) => _burgerMenuState.refresh(),
        ),
        _BackofficeBurgerMenuManager(),
      ]);
    } else {
      return Scaffold(
        backgroundColor: LenraColorThemeData.lenraWhite,
        body: Row(
          children: [
            menu,
            Expanded(
              child: content,
            ),
          ],
        ),
      );
    }
  }
}

class _BackofficeBurgerMenuManager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _burgerMenuState = _BackofficeBurgerMenuManagerState();
    return _burgerMenuState;
  }
}

class _BackofficeBurgerMenuManagerState extends State<_BackofficeBurgerMenuManager> {
  @override
  Widget build(BuildContext context) {
    var theme = LenraTheme.of(context);
    var state = _scaffoldKey.currentState;
    var opened = state?.isDrawerOpen ?? false;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 2 * theme.baseSize,
        horizontal: 4 * theme.baseSize,
      ),
      width: double.infinity,
      child: AnimatedAlign(
        alignment: opened ? Alignment.topRight : Alignment.topLeft,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: LenraButton(
          leftIcon: Icon(
            opened ? Icons.close : Icons.menu,
          ),
          type: LenraComponentType.secondary,
          onPressed: () => _toggleMenu(context),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  void _toggleMenu(context) {
    var state = _scaffoldKey.currentState;
    var opened = state?.isDrawerOpen ?? false;
    if (opened) {
      Navigator.pop(context);
    } else {
      state?.openDrawer();
    }
  }
}
