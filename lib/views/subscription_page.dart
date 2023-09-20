import 'dart:convert';

import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/api/response_models/user_response.dart';
import 'package:client_common/api/user_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatefulWidget {
  final String appId;

  SubscriptionPage({required this.appId});

  @override
  State<StatefulWidget> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool monthlyRecurring = false;
  bool yearlyRecurring = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficePage(
      title: 'Subscription',
      child: FutureBuilder(
        future: createOrGetCustomer().then((customer) async {
          return [customer, await getCustomerSubscription(customer)];
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          if ((snapshot.data?[1] as List<Map<String, dynamic>>).isEmpty) {
            var theme = LenraTheme.of(context);
            return Row(
              children: [
                Container(
                  width: 250,
                  height: 250,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Color(0x22000000)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Lenra Monthly",
                        style: theme.lenraTextThemeData.headline1,
                      ),
                      Row(
                        children: [
                          Text(
                            "€8",
                            style: theme.lenraTextThemeData.headline2,
                          ),
                          Text(
                            " per month",
                            style: theme.lenraTextThemeData.subtext,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          LenraCheckbox(
                              value: monthlyRecurring,
                              onPressed: (value) {
                                setState(() {
                                  monthlyRecurring = value!;
                                });
                              }),
                          Text("Recurring"),
                        ],
                      ),
                      LenraButton(
                        onPressed: () {
                          createCheckoutSession(
                            snapshot.data?[0] as String? ?? '',
                            SubscriptionOptions(
                              plan: SubscriptionPlan.month,
                              recurring: monthlyRecurring,
                            ),
                          );
                        },
                        text: "Subscribe",
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 32,
                ),
                Container(
                  width: 250,
                  height: 250,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Color(0x22000000)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Lenra Yearly",
                        style: theme.lenraTextThemeData.headline1,
                      ),
                      Row(
                        children: [
                          Text(
                            "€80",
                            style: theme.lenraTextThemeData.headline2,
                          ),
                          Text(
                            " per year",
                            style: theme.lenraTextThemeData.subtext,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          LenraCheckbox(
                              value: yearlyRecurring,
                              onPressed: (value) {
                                setState(() {
                                  yearlyRecurring = value!;
                                });
                              }),
                          Text("Recurring"),
                        ],
                      ),
                      LenraButton(
                        onPressed: () {
                          createCheckoutSession(
                            snapshot.data?[0] as String? ?? '',
                            SubscriptionOptions(
                              plan: SubscriptionPlan.month,
                              recurring: yearlyRecurring,
                            ),
                          );
                        },
                        text: "Subscribe",
                      )
                    ],
                  ),
                ),
              ],
            );
          } else {
            return alreadySubscribedWidget((snapshot.data![1] as List<Map<String, dynamic>>)[0]);
            return Text("Already subscribed to Lenra");
          }
        },
      ),
    );
  }

  Widget alreadySubscribedWidget(Map<String, dynamic> subscription) {
    var theme = LenraTheme.of(context);
    DateTime subscriptionEnd = DateTime.fromMillisecondsSinceEpoch(subscription['current_period_end']);
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Color(0x33000000)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text("Your subscription", style: theme.lenraTextThemeData.headline1),
              // TODO: Plan actuel
              Text("Ends : ${dateFormat.format(subscriptionEnd)}"),
              LenraButton(
                onPressed: () async {
                  UserResponse response = await UserApi.me();
                  String email = response.user.email;
                  Uri managementUri =
                      Uri.parse("https://billing.stripe.com/p/login/3cs4h61Sz45e06c000?prefilled_email=$email");

                  launchUrl(managementUri);
                },
                text: "Manage",
              ),
            ],
          ),
        ),
      ],
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
        'success_url': 'http://localhost:10000/stripe', // TODO: Find a way to get the real host
        'metadata': {
          'appId': widget.appId,
        }
      }),
    );

    launchUrl(Uri.parse(jsonDecode(session.body)['url']));
  }

  Future<List<Map<String, dynamic>>> getCustomerSubscription(String customerId) async {
    // final url = Uri.parse('http://localhost:4242/stripe/subscriptions?customer=$customerId');
    // final response = await http.get(url);
    // print(response);
    // return json.decode(response.body);
    return [
      {
        "id": "sub_1NsPkpDcEBIbl7Vf1SWCeaRI",
        "object": "subscription",
        "application": null,
        "application_fee_percent": null,
        "automatic_tax": {"enabled": true},
        "billing_cycle_anchor": 1695213823,
        "billing_thresholds": null,
        "cancel_at": null,
        "cancel_at_period_end": false,
        "canceled_at": null,
        "cancellation_details": {"comment": null, "feedback": null, "reason": null},
        "collection_method": "charge_automatically",
        "created": 1695213823,
        "currency": "eur",
        "current_period_end": 1726836223,
        "current_period_start": 1695213823,
        "customer": "cus_OfVSp7N7Ik84Zc",
        "days_until_due": null,
        "default_payment_method": "pm_1NsPHcDcEBIbl7Vfo9q7f4kf",
        "default_source": null,
        "default_tax_rates": [],
        "description": null,
        "discount": null,
        "ended_at": null,
        "items": {
          "object": "list",
          "data": [
            {
              "id": "si_OflHeanj6u9pDf",
              "object": "subscription_item",
              "billing_thresholds": null,
              "created": 1695213823,
              "metadata": {},
              "price": {
                "id": "price_1NriwlDcEBIbl7Vfmw8FX7oj",
                "object": "price",
                "active": true,
                "billing_scheme": "per_unit",
                "created": 1695049271,
                "currency": "eur",
                "custom_unit_amount": null,
                "livemode": false,
                "lookup_key": null,
                "metadata": {},
                "nickname": null,
                "product": "prod_Oezn3vBAmHUnrf",
                "recurring": {
                  "aggregate_usage": null,
                  "interval": "year",
                  "interval_count": 1,
                  "usage_type": "licensed"
                },
                "tax_behavior": "inclusive",
                "tiers_mode": null,
                "transform_quantity": null,
                "type": "recurring",
                "unit_amount": 8000,
                "unit_amount_decimal": "8000"
              },
              "quantity": 1,
              "subscription": "sub_1NsPkpDcEBIbl7Vf1SWCeaRI",
              "tax_rates": []
            }
          ],
          "has_more": false,
          "url": "/v1/subscription_items?subscription=sub_1NsPkpDcEBIbl7Vf1SWCeaRI"
        },
        "latest_invoice": "in_1NsPkpDcEBIbl7VfzMfwzIKE",
        "livemode": false,
        "metadata": {"app_id": "azeaopejaozpjraozefp"},
        "next_pending_invoice_item_invoice": null,
        "on_behalf_of": null,
        "pause_collection": null,
        "payment_settings": {
          "payment_method_options": null,
          "payment_method_types": null,
          "save_default_payment_method": "off"
        },
        "pending_invoice_item_interval": null,
        "pending_setup_intent": null,
        "pending_update": null,
        "schedule": null,
        "start_date": 1695213823,
        "status": "active",
        "test_clock": null,
        "transfer_data": null,
        "trial_end": null,
        "trial_settings": {
          "end_behavior": {"missing_payment_method": "create_invoice"}
        },
        "trial_start": null
      }
    ];
  }

  Future<String> createOrGetCustomer() async {
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
