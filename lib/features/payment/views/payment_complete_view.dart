import 'package:bannabee/core/services/api_service.dart';
import 'package:bannabee/core/services/token_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../app/routes.dart';
import '../../../data/models/rental_success_simple_response.dart';

class PaymentCompleteView extends StatefulWidget {
  final String rentalHistoryToken;

  const PaymentCompleteView({
    super.key,
    required this.rentalHistoryToken,
  });

  @override
  State<PaymentCompleteView> createState() => _PaymentCompleteViewState();
}

class _PaymentCompleteViewState extends State<PaymentCompleteView> {
  late Future<RentalSuccessSimpleResponse> _rentalData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _rentalData = _fetchRentalData();
  }

  Future<RentalSuccessSimpleResponse> _fetchRentalData() async {
    try {
      final accessToken = await TokenService.instance.getAccessToken();
      if (accessToken == null) {
        throw '로그인이 필요합니다.';
      }

      final response = await ApiService.instance.get(
        '/rentals/success/${widget.rentalHistoryToken}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return RentalSuccessSimpleResponse.fromJson(response.data['data']);
      } else {
        throw '대여 데이터를 불러오는데 실패했습니다';
      }
    } catch (e) {
      throw '대여 데이터를 불러오는 중 오류가 발생했습니다';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/bannabee.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 40),
              const Text(
                '결제가 완료되었습니다',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              FutureBuilder<RentalSuccessSimpleResponse>(
                future: _rentalData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '오류가 발생했습니다: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('데이터가 없습니다'));
                  }

                  final rental = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '결제 금액',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${rental.amount}원',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('대여 상품'),
                            Text(rental.itemName),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('대여 시간'),
                            Text('${rental.rentalTime}시간'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('대여 스테이션'),
                            Text(rental.stationName),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Spacer(),
              Text(
                '대여 현황에서 자세한 내용을 확인할 수 있습니다',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(Routes.home);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('홈으로'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(Routes.rentalStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '대여 현황 보기',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
