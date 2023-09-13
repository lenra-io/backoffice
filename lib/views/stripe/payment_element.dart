import 'package:client_backoffice/views/stripe/stripe_checkout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';

Future<void> pay() async {
  await WebStripe.instance.confirmPaymentElement(
    ConfirmPaymentElementOptions(
      confirmParams: ConfirmPaymentParams(return_url: getReturnUrl()),
    ),
  );
}

class LenraPaymentElement extends StatelessWidget {
  const LenraPaymentElement(this.clientSecret);

  final String? clientSecret;

  @override
  Widget build(BuildContext context) {
    return PaymentElement(
      autofocus: true,
      enablePostalCode: true,
      onCardChanged: (_) {},
      clientSecret: clientSecret ?? '',
    );
  }
}
