import 'package:flutter/material.dart';
import '../../../data/models/rental.dart';
import '../../../data/repositories/rental_repository.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';

class ActiveRentalsView extends StatefulWidget {
  final Rental? newRental;

  const ActiveRentalsView({
    super.key,
    this.newRental,
  });

  @override
  State<ActiveRentalsView> createState() => _ActiveRentalsViewState();
}

class _ActiveRentalsViewState extends State<ActiveRentalsView> {
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
      final rentals = await _rentalRepository.getActiveRentals();

      setState(() {
        // 새로운 결제 기록이 있다면 리스트 최상단에 추가
        if (widget.newRental != null) {
          _rentals = [widget.newRental!, ...rentals];
        } else {
          _rentals = rentals;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('대여 현황을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('현재 대여 중'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRentals,
              child: _rentals.isEmpty
                  ? const Center(
                      child: Text('현재 대여 중인 물품이 없습니다'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _rentals.length,
                      itemBuilder: (context, index) {
                        return _buildRentalCard(_rentals[index]);
                      },
                    ),
            ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildRentalCard(Rental rental) {
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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '대여 중',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('대여 스테이션: ${rental.stationName}'),
            const SizedBox(height: 4),
            Text(
              '대여일시: ${rental.createdAt.toString().substring(0, 16)}',
            ),
            const SizedBox(height: 4),
            Text('대여 시간: ${rental.formattedRentalTime}'),
            const SizedBox(height: 4),
            Text('결제 금액: ${rental.totalPrice}원'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 연장 기능 구현
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('준비 중인 기능입니다.')),
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
          ],
        ),
      ),
    );
  }
}
