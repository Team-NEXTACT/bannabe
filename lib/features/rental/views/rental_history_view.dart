import 'package:flutter/material.dart';
import '../../../data/models/rental.dart';
import '../../../data/repositories/rental_repository.dart';
import '../../../core/constants/app_theme.dart';

class RentalHistoryView extends StatefulWidget {
  const RentalHistoryView({super.key});

  @override
  State<RentalHistoryView> createState() => _RentalHistoryViewState();
}

class _RentalHistoryViewState extends State<RentalHistoryView> {
  final _rentalRepository = RentalRepository.instance;
  List<Rental> _rentals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rentals = await _rentalRepository.getRecentRentals();

      setState(() {
        _rentals = rentals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('대여 내역을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대여 내역'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRentals,
              child: _rentals.isEmpty
                  ? const Center(
                      child: Text('지난 대여 내역이 없습니다'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _rentals.length,
                      itemBuilder: (context, index) {
                        return _buildRentalCard(_rentals[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildRentalCard(Rental rental) {
    String statusText;
    Color statusColor;
    switch (rental.status) {
      case RentalStatus.active:
        statusText = '대여 중';
        statusColor = Colors.blue;
        break;
      case RentalStatus.completed:
        statusText = '반납 완료';
        statusColor = Colors.grey;
        break;
      case RentalStatus.overdue:
        statusText = '연체';
        statusColor = Colors.red;
        break;
      case RentalStatus.overdueCompleted:
        statusText = '반납 완료';
        statusColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rental.accessoryName,
                    style: AppTheme.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('대여 스테이션: ${rental.stationName}'),
            const SizedBox(height: 4),
            Text('반납 스테이션: ${rental.returnStationName ?? rental.stationName}'),
            const SizedBox(height: 4),
            Text(
              '대여일시: ${rental.createdAt.toString().substring(0, 16)}',
            ),
            const SizedBox(height: 4),
            Text(
              '반납일시: ${rental.updatedAt.toString().substring(0, 16)}',
            ),
            const SizedBox(height: 4),
            Text('결제 금액: ${rental.totalPrice}원'),
            if (rental.isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '연체 정보',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '연체 시간: ${rental.overdueDuration.inHours}시간',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '연체료: ${rental.overdueFee}원',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: 연장 기능 구현
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('준비 중인 기능입니다.'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              foregroundColor: Colors.blue,
                              elevation: 0,
                            ),
                            child: const Text('연장하기'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: 연체료 결제 기능 구현
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('준비 중인 기능입니다.'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('연체료 결제'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
