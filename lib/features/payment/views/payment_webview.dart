import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String accessToken;
  final String rentalItemToken;
  final String rentalTime;
  final String paymentType;

  const PaymentWebView({
    super.key,
    required this.accessToken,
    required this.rentalItemToken,
    required this.rentalTime,
    required this.paymentType,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            _controller.runJavaScript('''
              sessionStorage.setItem('accessToken', '${widget.accessToken}');
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('bannabe://')) {
              final uri = Uri.parse(request.url);
              if (uri.host == 'payment-success') {
                final rentalHistoryToken =
                    uri.queryParameters['rentalHistoryToken'];
                Navigator.of(context).pop(rentalHistoryToken);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('[ERROR] WebView 에러: ${error.description}');
          },
        ),
      );

    final paymentUrl = Uri(
      scheme: 'http',
      host: '10.0.2.2',
      port: 8080,
      path: '/v1/payments/checkout',
      queryParameters: {
        'rentalItemToken': widget.rentalItemToken,
        'rentalTime': widget.rentalTime,
        'paymentType': widget.paymentType,
      },
    ).toString();

    _controller.loadRequest(
      Uri.parse(paymentUrl),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
