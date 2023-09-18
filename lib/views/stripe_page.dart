import 'dart:convert';

import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lenra_components/component/lenra_button.dart';
import 'package:url_launcher/url_launcher.dart';

class StripePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StripePageState();
}

class _StripePageState extends State<StripePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficePage(
      title: 'Subscribe to Lenra',
      child: FutureBuilder(
        future: createCustomer(),
        builder: (context, snapshot) {
          return Column(
            children: [
              LenraButton(
                onPressed: () {
                  createCheckoutSession(
                    snapshot.data ?? '',
                    SubscriptionOptions(
                      plan: SubscriptionPlan.month,
                      recurring: true,
                    ),
                  );
                },
                text: 'Pay monthly',
              ),
              LenraButton(
                onPressed: () {
                  createCheckoutSession(
                    snapshot.data ?? '',
                    SubscriptionOptions(
                      plan: SubscriptionPlan.year,
                      recurring: true,
                    ),
                  );
                },
                text: 'Pay yearly',
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> createCheckoutSession(String customerId, SubscriptionOptions options) async {
    final url = Uri.parse('http://localhost:4242/stripe/checkout');
    final session = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'customer': customerId,
        'mode': options.recurring ? 'subscription' : 'payment',
        'plan': options.plan.name,
        'success_url':
            'http://localhost:10000/stripe/success?session_id={CHECKOUT_SESSION_ID}' // TODO: Find a way to get the real host
      }),
    );

    launchUrl(Uri.parse(jsonDecode(session.body)['url']));
  }

  Future<String> createCustomer() async {
    final url = Uri.parse('http://localhost:4242/stripe/customers');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': 'jonas@lenra.io',
      }),
    );
    return json.decode(response.body)['id'];
  }
}

enum SubscriptionPlan { month, year }

class SubscriptionOptions {
  SubscriptionPlan plan;
  bool recurring;

  SubscriptionOptions({required this.plan, required this.recurring});
}
