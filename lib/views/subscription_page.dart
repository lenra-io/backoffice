import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/api/request_models/create_stripe_checkout_request.dart';
import 'package:client_common/api/request_models/create_stripe_customer_request.dart';
import 'package:client_common/api/response_models/user_response.dart';
import 'package:client_common/api/stripe_api.dart';
import 'package:client_common/api/user_api.dart';
import 'package:flutter/material.dart';
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
        future: StripeApi.createCustomer(
          CreateStripeCustomerRequest(email: "jonas@lenra.io"),
        ).then((customer) async {
          return [customer, await StripeApi.getSubscriptions(widget.appId)];
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          if ((snapshot.data?[1] as List<Map<String, dynamic>>).isEmpty) {
            String customer = snapshot.data?[0] as String? ?? '';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                subcriptionBox(SubscriptionPlan.month, customer),
                SizedBox(
                  width: 32,
                ),
                subcriptionBox(SubscriptionPlan.year, customer),
              ],
            );
          } else {
            return alreadySubscribedWidget((snapshot.data![1] as List<Map<String, dynamic>>)[0]);
          }
        },
      ),
    );
  }

  Widget subcriptionBox(SubscriptionPlan plan, String customer) {
    var theme = LenraTheme.of(context);
    String title;
    String price;
    String realPrice;
    String per;

    if (plan == SubscriptionPlan.month) {
      title = "Monthly";
      price = "4 €";
      realPrice = "8 €";
      per = "month";
    } else {
      title = "Yearly";
      price = "40 €";
      realPrice = "80 €";
      per = "year";
    }

    return Container(
      width: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Color(0x22000000)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LenraFlex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Text(
            title,
            style: theme.lenraTextThemeData.headline2,
          ),
          SizedBox(),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: theme.lenraTextThemeData.headline1,
                  ),
                  Text(
                    " / $per",
                    style: theme.lenraTextThemeData.bodyText,
                  ),
                ],
              ),
              Text(realPrice,
                  style: theme.lenraTextThemeData.disabledBodyText.copyWith(decoration: TextDecoration.lineThrough)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LenraCheckbox(
                  value: plan == SubscriptionPlan.month ? monthlyRecurring : yearlyRecurring,
                  onPressed: (value) {
                    setState(() {
                      if (plan == SubscriptionPlan.month) {
                        monthlyRecurring = value!;
                      } else {
                        yearlyRecurring = value!;
                      }
                    });
                  }),
              Text("Recurring"),
            ],
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: 100,
              minWidth: double.infinity,
            ),
            child: LenraButton(
              onPressed: () async {
                SubscriptionOptions options = SubscriptionOptions(
                  plan: SubscriptionPlan.month,
                  recurring: yearlyRecurring,
                );

                String redirectUrl = await StripeApi.createCheckout(
                  CreateStripeCheckoutRequest(
                    appId: widget.appId,
                    plan: options.plan.name,
                    mode: options.recurring ? 'subscription' : 'payment',
                    customer: customer,
                    successUrl: 'http://localhost:10000/stripe',
                    cancelUrl: '',
                  ),
                );

                launchUrl(Uri.parse(redirectUrl));
              },
              text: "Subscribe",
            ),
          ),
        ],
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
}

enum SubscriptionPlan { month, year }

class SubscriptionOptions {
  SubscriptionPlan plan;
  bool recurring;

  SubscriptionOptions({required this.plan, required this.recurring});
}
