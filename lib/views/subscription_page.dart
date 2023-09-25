import 'package:client_backoffice/views/backoffice_page.dart';
import 'package:client_common/api/request_models/create_stripe_checkout_request.dart';
import 'package:client_common/api/request_models/create_stripe_customer_request.dart';
import 'package:client_common/api/response_models/get_stripe_subscriptions_response.dart';
import 'package:client_common/api/stripe_api.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatefulWidget {
  final int appId;

  SubscriptionPage({required this.appId});

  @override
  State<StatefulWidget> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
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

          String customer = snapshot.data?[0] as String? ?? '';
          String? currentPlan = (snapshot.data?[1] as GetStripeSubscriptionsResponse).subscription?["plan"];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              subcriptionBox(
                SubscriptionPlan.month,
                customer,
                currentPlan,
              ),
              SizedBox(
                width: 32,
              ),
              subcriptionBox(
                SubscriptionPlan.year,
                customer,
                currentPlan,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget subcriptionBox(SubscriptionPlan plan, String customer, String? currentPlan) {
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

    bool isCurrentPlan = (currentPlan != null && currentPlan == plan.name);
    bool isNotCurrentPlan = (currentPlan != null && currentPlan != plan.name);

    String buttonText = "Subscribe";
    if (isCurrentPlan) {
      buttonText = "Manage";
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
          Container(
            constraints: BoxConstraints(
              maxHeight: 100,
              minWidth: double.infinity,
            ),
            child: LenraButton(
              disabled: isNotCurrentPlan,
              onPressed: () async {
                String? redirectUrl;
                if (isCurrentPlan) {
                  redirectUrl = await StripeApi.getCustomerPortalUrl();
                } else {
                  redirectUrl = await StripeApi.createCheckout(
                    CreateStripeCheckoutRequest(
                      appId: widget.appId,
                      plan: plan.name,
                      customer: customer,
                      successUrl: 'http://localhost:10000/stripe',
                      cancelUrl: 'http://localhost:10000/stripe',
                    ),
                  );
                }

                launchUrl(Uri.parse(redirectUrl));
              },
              text: buttonText,
            ),
          ),
        ],
      ),
    );
  }
}

enum SubscriptionPlan { month, year }
