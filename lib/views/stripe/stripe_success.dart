import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:flutter/material.dart';

class StripeSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackofficePage(
      child: Text("Success"),
      title: "Successfully subscribed to Lenra",
    );
  }
}
