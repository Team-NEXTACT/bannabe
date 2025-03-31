import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/rental.dart';
import '../../../data/models/payment.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../app/routes.dart';
import '../viewmodels/qr_scan_viewmodel.dart';

class RentalDurationView extends StatefulWidget {
  final Rental rental;
  final RentalItemResponse? rentalItemResponse;

  const RentalDurationView({
    Key? key,
    required this.rental,
    this.rentalItemResponse,
  }) : super(key: key);

  @override
  State<RentalDurationView> createState() => _RentalDurationViewState();
}

class _RentalDurationViewState extends State<RentalDurationView> {
  int _selectedHours = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 선택 시간을 rental의 시간으로 설정
    _selectedHours = widget.rental.rentalTimeHour;
  }

  Future<void> _handlePaymentButtonTap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = PaymentCalculateRequest(
        rentalItemToken: widget.rental.token,
        rentalTime: _selectedHours,
      );

      final response =
          await PaymentRepository.instance.calculatePayment(request);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          Routes.payment,
          arguments: {
            'rental': widget.rental,
            'paymentCalculation': response,
            'rentalItemResponse': widget.rentalItemResponse,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대여 시간 선택'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '대여 정보',
                            style: AppTheme.titleMedium.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '대여 스테이션: ${widget.rentalItemResponse?.currentStationName ?? "알 수 없음"}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.rental.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '대여 시간 선택',
                      style: AppTheme.titleMedium.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_selectedHours > 1) {
                                setState(() {
                                  _selectedHours--;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: _selectedHours > 1
                                  ? AppColors.primary
                                  : Colors.grey,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '$_selectedHours시간',
                            style: AppTheme.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            onPressed: () {
                              if (_selectedHours < 24) {
                                setState(() {
                                  _selectedHours++;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: _selectedHours < 24
                                  ? AppColors.primary
                                  : Colors.grey,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightGrey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '결제 금액',
                            style: AppTheme.titleMedium.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '시간당',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '${widget.rentalItemResponse?.price ?? 1000}원',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '총 금액',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(widget.rentalItemResponse?.price ?? 1000) * _selectedHours}원',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePaymentButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          '결제하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
