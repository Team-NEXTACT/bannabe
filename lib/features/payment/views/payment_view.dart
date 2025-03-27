import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/rental.dart';
import '../../../app/routes.dart';

class PaymentView extends StatefulWidget {
  final Rental rental;

  const PaymentView({
    super.key,
    required this.rental,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String? accessoryName;
  String? stationName;
  int? hours;
  int? totalPrice;
  bool agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _loadSavedInfo();
  }

  Future<void> _loadSavedInfo() async {
    final storage = StorageService.instance;
    final savedAccessoryName =
        await storage.getString('selected_accessory_name');
    final savedStationName = await storage.getString('selected_station_name');
    final savedHours = await storage.getInt('selected_rental_duration');
    final savedPrice = await storage.getInt('selected_price');

    if (mounted) {
      setState(() {
        accessoryName = savedAccessoryName;
        stationName = savedStationName;
        hours = savedHours;
        totalPrice = savedPrice;
      });
    }
  }

  Future<void> _launchKakaoPayLink() async {
    final url = Uri.parse('https://link.kakaopay.com/_/9DvW7m_');

    try {
      if (await canLaunchUrl(url)) {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('결제 링크를 열 수 없습니다.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        // 결제 완료 여부를 확인하기 위해 결제 상태를 주기적으로 체크
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/bannabee.png',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '결제 진행 중',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${1000 * widget.rental.rentalTimeHour}원',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.rental.name} (${widget.rental.rentalTimeHour}시간)',
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '카카오페이 결제를 완료해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '결제가 완료되면 아래 버튼을 눌러주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed(
                                Routes.paymentComplete,
                                arguments: widget.rental,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '결제 완료',
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('결제 링크를 열 수 없습니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 링크를 여는 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentButtonTap() {
    if (!agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('결제 약관에 동의해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _launchKakaoPayLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('대여 정보', style: AppTheme.titleMedium),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('상품'),
                                  Text(widget.rental.name),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('대여 시작'),
                                  Text(widget.rental.startTime
                                      .toString()
                                      .substring(0, 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('반납 예정'),
                                  Text(widget.rental.expectedReturnTime
                                      .toString()
                                      .substring(0, 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('대여 시간'),
                                  Text('${widget.rental.rentalTimeHour}시간'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('시간당 금액'),
                                  Text('1000원'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '총 금액',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${1000 * widget.rental.rentalTimeHour}원',
                                    style: AppTheme.titleMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('결제 동의', style: AppTheme.titleMedium),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('결제 진행 및 대여 약관에 동의합니다'),
                                value: agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    agreedToTerms = value ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 결제 금액 및 결제 수단 선택
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '총 결제 금액',
                                  style: AppTheme.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${1000 * widget.rental.rentalTimeHour}원',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // 카드 결제 버튼
                            Opacity(
                              opacity: agreedToTerms ? 1.0 : 0.5,
                              child: ElevatedButton(
                                onPressed: agreedToTerms
                                    ? () {
                                        // TODO: 카드 결제 구현
                                        print('카드 결제 버튼 클릭');
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(
                                        color: AppColors.lightGrey),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.credit_card),
                                    SizedBox(width: 8),
                                    Text(
                                      '신용/체크카드 결제',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 디버깅용 카카오페이 결제 버튼
                      if (true) // TODO: 배포 전 삭제
                        Column(
                          children: [
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: agreedToTerms
                                  ? _handlePaymentButtonTap
                                  : null,
                              child: Opacity(
                                opacity: agreedToTerms ? 1.0 : 0.5,
                                child: Image.asset(
                                  'assets/images/btn_send_regular.png',
                                  width: double.infinity,
                                  height: 44,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
