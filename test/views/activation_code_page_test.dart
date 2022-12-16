import 'package:client_backoffice/views/dev_validation_page.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/test/lenra_page_test_help.dart';
import 'package:client_common/views/simple_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ActivationCodePage check SimplePage', (WidgetTester tester) async {
    await tester.pumpWidget(createAppTestWidgets(ChangeNotifierProvider<AuthModel>(
      create: (_) => AuthModel(),
      child: DevValidationPage(),
    )));

    final widgetFinder = find.byType(SimplePage);

    expect(widgetFinder, findsOneWidget);
  });

  testWidgets('ActivationCodePage check texts', (WidgetTester tester) async {
    await tester.pumpWidget(createAppTestWidgets(ChangeNotifierProvider<AuthModel>(
      create: (_) => AuthModel(),
      child: DevValidationPage(),
    )));

    final textFinder = find.byType(Text);

    expect(textFinder, findsNWidgets(5));
  });
}
