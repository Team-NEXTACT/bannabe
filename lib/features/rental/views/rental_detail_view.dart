import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import './qr_scan_view.dart';
import '../../../data/models/accessory.dart';
import '../../../data/models/station.dart';
import '../../../app/routes.dart';
import '../../../data/repositories/station_repository.dart';
import 'dart:math'; // 임시 데이터 생성용

class RentalDetailView extends StatefulWidget {
  final Accessory accessory;
  final Station? station;

  const RentalDetailView({
    Key? key,
    required this.accessory,
    this.station,
  }) : super(key: key);

  @override
  State<RentalDetailView> createState() => _RentalDetailViewState();
}

class _RentalDetailViewState extends State<RentalDetailView> {
  final _storageService = StorageService.instance;
  Station? _selectedStation;
  int _selectedHours = 1;
  late final int _quantity; // 악세사리 수량

  @override
  void initState() {
    super.initState();
    _selectedStation = widget.station;
    // 임시 데이터: 1~5개 랜덤 생성
    _quantity = Random().nextInt(5) + 1;

    // 초기 대여 시간 쿠키 생성
    _storageService.setInt('selected_rental_duration', _selectedHours);
    _storageService.setInt(
      'selected_price',
      widget.accessory.pricePerHour * _selectedHours,
    );

    _loadSavedInfo();
  }

  Future<void> _loadSavedInfo() async {
    try {
      // 저장된 스테이션 정보 불러오기
      final savedStationId =
          await _storageService.getString('selected_station_id');
      final savedAccessoryId =
          await _storageService.getString('selected_accessory_id');

      if (savedAccessoryId == widget.accessory.id && mounted) {
        // 스테이션 정보 불러오기
        if (savedStationId != null) {
          final stationRepository = StationRepository.instance;
          final station =
              await stationRepository.getStation(int.parse(savedStationId));

          if (station != null) {
            setState(() {
              _selectedStation = station;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading saved info: $e');
    }
  }

  Future<void> _selectStation() async {
    final station = await Navigator.of(context).pushNamed(
      Routes.map,
      arguments: {
        'onStationSelected': true,
      },
    );

    if (station != null && context.mounted) {
      setState(() {
        _selectedStation = station as Station;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상세 정보'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        color: Colors.grey[200],
                        child: Image.asset(
                          widget.accessory.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            widget.accessory.category.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.accessory.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.accessory.pricePerHour}원/시간',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.accessory.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          if (_selectedStation != null && _quantity > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '남은 수량: $_quantity개',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedStation == null)
                    ElevatedButton(
                      onPressed: _selectStation,
                      child: const Text('스테이션 선택 후 수량 확인하기'),
                    )
                  else if (_quantity == 0)
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('현재 대여 불가능'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        // 쿠키에 정보 저장
                        await _storageService.setString(
                          'selected_accessory_id',
                          widget.accessory.id,
                        );
                        await _storageService.setString(
                          'selected_station_id',
                          _selectedStation?.id.toString() ?? '',
                        );
                        await _storageService.setString(
                          'selected_accessory_name',
                          widget.accessory.name,
                        );
                        await _storageService.setString(
                          'selected_station_name',
                          _selectedStation?.name ?? '',
                        );
                        await _storageService.setInt(
                          'selected_rental_duration',
                          _selectedHours,
                        );
                        await _storageService.setInt(
                          'selected_price',
                          widget.accessory.pricePerHour * _selectedHours,
                        );

                        final scanned = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QRScanView(
                              rentalDuration: _selectedHours,
                              isReturn: false,
                            ),
                          ),
                        );

                        if (scanned == true && context.mounted) {
                          Navigator.of(context).pushNamed(Routes.payment);
                        }
                      },
                      child: const Text('QR 스캔하기'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
