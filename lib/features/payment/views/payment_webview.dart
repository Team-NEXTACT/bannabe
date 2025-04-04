import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/services/payment_service.dart';

class PaymentWebView extends StatefulWidget {
  final String checkoutUrl; // HTML 컨텐츠
  final String accessToken;
  final PaymentService paymentService;
  final String orderId;
  final String orderName;
  final int amount;
  final String customerKey;

  const PaymentWebView({
    super.key,
    required this.checkoutUrl,
    required this.accessToken,
    required this.paymentService,
    required this.orderId,
    required this.orderName,
    required this.amount,
    required this.customerKey,
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
            print('[DEBUG] WebView 페이지 로드 시작: $url');
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('[DEBUG] WebView 페이지 로드 완료: $url');
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('[DEBUG] WebView 네비게이션 요청: ${request.url}');
            if (request.url.contains('test-success')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('[ERROR] WebView 에러: ${error.description}');
            print('[ERROR] WebView 에러 코드: ${error.errorCode}');
            print('[ERROR] WebView 에러 타입: ${error.errorType}');
          },
        ),
      );

    // HTML 컨텐츠 수정
    String modifiedHtml = widget.checkoutUrl;
    print('[DEBUG] 원본 HTML 길이: ${modifiedHtml.length}');

    // localhost를 10.0.2.2로 변경
    modifiedHtml = modifiedHtml.replaceAll('localhost', '10.0.2.2');
    print('[DEBUG] localhost 변경 후 HTML 길이: ${modifiedHtml.length}');

    // 토스 페이먼츠 결제창 설정 수정
    modifiedHtml = modifiedHtml.replaceAll('async function requestPayment() {',
        '''async function requestPayment() {
        const successUrl = "https://docs.tosspayments.com/guides/payment/test-success";
        const failUrl = "https://docs.tosspayments.com/guides/payment/test-fail";

        // View Model 데이터 선언
        const clientKey = "test_ck_PBal2vxj81yE5wYp9vqk85RQgOAN";
        const customerKey = "${widget.customerKey}";
        const orderId = "${widget.orderId}";
        const orderName = "${widget.orderName}";

        try {
          const tossPayments = TossPayments(clientKey);
          const paymentWidget = tossPayments.payment({
            customerKey: customerKey
          });

          await paymentWidget.requestPayment({
            method: "CARD",
            amount,
            orderId: orderId,
            orderName: orderName,
            successUrl: successUrl,
            failUrl: failUrl
          });
        } catch (error) {
          console.error('결제 요청 실패:', error);
        }''');
    print('[DEBUG] 결제창 설정 변경 후 HTML 길이: ${modifiedHtml.length}');

    // HTML이 완전한지 확인
    if (!modifiedHtml.contains('</html>')) {
      print('[ERROR] HTML이 완전하지 않습니다!');
    }

    print('[DEBUG] 최종 HTML:');
    print(modifiedHtml);

    _controller.loadHtmlString(modifiedHtml);
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
