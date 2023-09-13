import 'dart:convert';

import 'package:client_backoffice/views/stripe/loading_button.dart';
import 'package:client_backoffice/views/stripe/payment_element.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StripePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StripePageState();
}

class _StripePageState extends State<StripePage> {
  String? clientSecret;

  @override
  void initState() {
    getClientSecret();
    super.initState();
  }

  Future<void> getClientSecret() async {
    try {
      final client = await createPaymentIntent();
      print("GET CLIENT SECRET");
      print(client);
      setState(() {
        clientSecret = client;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(clientSecret);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter App'),
      ),
      body: Column(
        children: [
          Container(
              child: clientSecret != null
                  ? LenraPaymentElement(clientSecret)
                  : Center(child: CircularProgressIndicator())),
          LoadingButton(onPressed: pay, text: 'Pay'),
        ],
      ),
    );
  }

  Future<String> createPaymentIntent() async {
    final url = Uri.parse('http://localhost:4242/create-payment-intent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'currency': 'eur',
        'amount': 800,
        'payment_method_types': ['card'],
        'request_three_d_secure': 'any',
      }),
    );
    print(json.decode(response.body));
    return json.decode(response.body)['client_secret'];
  }
}
