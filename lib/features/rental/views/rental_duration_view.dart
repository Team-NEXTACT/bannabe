import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/rental.dart';
import '../../../app/routes.dart';

class RentalDurationView extends StatefulWidget {
  final Rental rental;

  const RentalDurationView({
    Key? key,
    required this.rental,
  }) : super(key: key);

  @override
  State<RentalDurationView> createState() => _RentalDurationViewState();
}

class _RentalDurationViewState extends State<RentalDurationView> {
  int _selectedHours = 1;

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
                            Text('스테이션: ${widget.rental.stationName}'),
                            const SizedBox(height: 8),
                            Text('상품: ${widget.rental.accessoryName}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '대여 시간 선택',
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_selectedHours > 1) {
                                setState(() {
                                  _selectedHours--;
                                });
                              }
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Expanded(
                            child: Text(
                              '$_selectedHours시간',
                              textAlign: TextAlign.center,
                              style: AppTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_selectedHours < 24) {
                                setState(() {
                                  _selectedHours++;
                                });
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('결제 금액', style: AppTheme.titleMedium),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('시간당'),
                                Text(
                                    '${widget.rental.totalPrice ~/ widget.rental.totalRentalTime.inHours}원'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('총 금액'),
                                Text(
                                  '${(widget.rental.totalPrice ~/ widget.rental.totalRentalTime.inHours) * _selectedHours}원',
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  final updatedRental = Rental(
                    id: widget.rental.id,
                    userId: widget.rental.userId,
                    accessoryId: widget.rental.accessoryId,
                    stationId: widget.rental.stationId,
                    accessoryName: widget.rental.accessoryName,
                    stationName: widget.rental.stationName,
                    totalPrice: (widget.rental.totalPrice ~/
                            widget.rental.totalRentalTime.inHours) *
                        _selectedHours,
                    status: widget.rental.status,
                    createdAt: widget.rental.createdAt,
                    updatedAt: widget.rental.updatedAt,
                  );

                  Navigator.of(context).pushReplacementNamed(
                    Routes.payment,
                    arguments: updatedRental,
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('결제하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
