import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/payment.dart';
import '../../core/services/token_service.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio) {
    _dio.options.baseUrl = "http://10.0.2.2:8080";
  }

  Future<PaymentCheckoutUrlResponse> getCheckoutUrl() async {
    try {
      final accessToken = await TokenService.instance.getAccessToken();
      if (accessToken == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _dio.get(
        '/v1/payments/checkout-url',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      // localhost를 10.0.2.2로 변경
      final data = response.data;
      if (data['data'] != null && data['data']['checkoutUrl'] != null) {
        data['data']['checkoutUrl'] = data['data']['checkoutUrl']
            .toString()
            .replaceAll('localhost', '10.0.2.2');
      }

      return PaymentCheckoutUrlResponse.fromJson(data);
    } catch (e) {
      throw Exception('결제 URL을 가져오는데 실패했습니다: $e');
    }
  }

  Future<PaymentCheckoutUrlResponse> createCheckout({
    required String rentalItemToken,
    required int rentalTime,
    required int amount,
    required PaymentType paymentType,
    required String orderName,
  }) async {
    try {
      final accessToken = await TokenService.instance.getAccessToken();
      if (accessToken == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final orderId = const Uuid().v4();
      final customerKey = const Uuid().v4();

      print('[DEBUG] 결제창 호출 요청 파라미터:');
      print('  - orderId: $orderId');
      print('  - rentalItemToken: $rentalItemToken');
      print('  - rentalTime: $rentalTime');
      print('  - amount: $amount');
      print(
          '  - paymentType: ${paymentType.toString().split('.').last.toUpperCase()}');
      print('  - orderName: $orderName');
      print('  - customerKey: $customerKey');

      final response = await _dio.get(
        '/v1/payments/checkout',
        queryParameters: {
          'orderId': orderId,
          'rentalItemToken': rentalItemToken,
          'rentalTime': rentalTime,
          'amount': amount,
          'paymentType': paymentType.toString().split('.').last.toUpperCase(),
          'orderName': orderName,
          'customerKey': customerKey,
          'currency': 'KRW',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          responseType: ResponseType.plain,
        ),
      );

      print('[DEBUG] 결제창 호출 응답:');
      print('  - 상태 코드: ${response.statusCode}');
      print('  - 응답 데이터: ${response.data}');
      print('  - 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.statusCode != 200) {
        throw Exception('결제창 호출에 실패했습니다.');
      }

      final htmlContent = response.data as String;
      print('[DEBUG] HTML 컨텐츠 길이: ${htmlContent.length}');
      print('[DEBUG] HTML 컨텐츠 전체:');
      print(htmlContent);

      return PaymentCheckoutUrlResponse(
        success: true,
        message: '성공',
        htmlContent: htmlContent,
      );
    } catch (e) {
      print('[ERROR] 결제창 호출 중 오류가 발생했습니다: $e');
      if (e is DioException) {
        print('[ERROR] 에러 응답: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? '결제창 호출 중 오류가 발생했습니다.');
      }
      throw Exception('결제창 호출 중 오류가 발생했습니다: $e');
    }
  }
}
