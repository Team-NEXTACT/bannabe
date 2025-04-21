import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
              try {
                sessionStorage.setItem('accessToken', '${widget.accessToken}');
              } catch (e) {
                console.error('sessionStorage 접근 오류:', e);
              }
            ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains('/v1/payments/success')) {
              final uri = Uri.parse(request.url);
              final paymentKey = uri.queryParameters['paymentKey'];
              final amount = uri.queryParameters['amount'];
              final orderId = uri.queryParameters['orderId'];

              if (paymentKey != null && amount != null && orderId != null) {
                // ✅ Flutter에서 HTTP 요청 보내기
                try {
                  final response = await http.post(
                    Uri.parse('http://10.0.2.2:8080/v1/payments/confirm'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer ${widget.accessToken}',
                    },
                    body: jsonEncode({
                      'paymentKey': paymentKey,
                      'amount': int.parse(amount),
                      'orderId': orderId,
                    }),
                  );

                  final result = jsonDecode(response.body);
                  if (result['success'] == true) {
                    final rentalHistoryToken =
                        result['data']['rentalHistoryToken'];
                    Navigator.of(context).pop(rentalHistoryToken);
                  } else {
                    Navigator.of(context).pop('failure:${result['message']}');
                  }
                } catch (e) {
                  Navigator.of(context).pop('failure:결제 처리 중 오류가 발생했습니다.');
                }

                return NavigationDecision.prevent;
              }
            } else if (request.url.contains('/v1/payments/failure')) {
              final uri = Uri.parse(request.url);
              final message = uri.queryParameters['message'] ?? '결제가 실패했습니다.';
              Navigator.of(context).pop('failure:$message');
              return NavigationDecision.prevent;
            } else if (request.url.contains('/v1/payments/success')) {
              final uri = Uri.parse(request.url);
              final rentalHistoryToken =
                  uri.queryParameters['rentalHistoryToken'];
              if (rentalHistoryToken != null) {
                Navigator.of(context).pop(rentalHistoryToken);
                return NavigationDecision.prevent;
              }
            } else if (request.url.startsWith('intent://')) {
              final uri = Uri.parse(request.url);
              if (uri.host == 'pay') {
                final payToken = uri.queryParameters['payToken'];
                if (payToken != null) {
                  final tossUrl = Uri(
                    scheme: 'supertoss',
                    host: 'pay',
                    queryParameters: {
                      'payToken': payToken,
                      'deviceType': 'mobile',
                      'isTossApp': 'false',
                      'appPayVersion': '2.0',
                    },
                  );
                  try {
                    final result = await launchUrl(
                      tossUrl,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!result) {
                      // 토스 앱이 설치되어 있지 않은 경우
                      final marketUrl =
                          Uri.parse('market://details?id=viva.republica.toss');
                      await launchUrl(
                        marketUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } catch (e) {
                    print('토스 앱 실행 오류: $e');
                    // Play Store로 이동
                    final playStoreUrl = Uri.parse(
                        'https://play.google.com/store/apps/details?id=viva.republica.toss');
                    await launchUrl(
                      playStoreUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                  return NavigationDecision.prevent;
                }
              } else if (uri.host == 'payment-success') {
                final rentalHistoryToken =
                    uri.queryParameters['rentalHistoryToken'];
                if (rentalHistoryToken != null) {
                  Navigator.of(context).pop(rentalHistoryToken);
                }
              } else if (uri.host == 'payment-failure') {
                final message = uri.queryParameters['message'];
                Navigator.of(context).pop('failure:$message');
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
