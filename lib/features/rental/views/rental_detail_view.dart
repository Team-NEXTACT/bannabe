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
    // 임시 데이터: 0~5개 랜덤 생성
    _quantity = Random().nextInt(6);

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
          final station = await stationRepository.getStation(savedStationId);
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
                          Text(
                            widget.accessory.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.accessory.pricePerHour}원/시간',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedStation == null
                                      ? Colors.grey[200]
                                      : _quantity > 0
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _selectedStation == null
                                      ? '스테이션 선택 후 수량 확인'
                                      : '남은 수량: $_quantity개',
                                  style: TextStyle(
                                    color: _selectedStation == null
                                        ? Colors.grey[600]
                                        : _quantity > 0
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '대여 시간',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '선택된 시간',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      '$_selectedHours시간',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: _selectedHours > 1
                                          ? () {
                                              setState(() {
                                                _selectedHours--;
                                              });
                                              // 시간 변경 시 쿠키 업데이트
                                              _storageService.setInt(
                                                'selected_rental_duration',
                                                _selectedHours,
                                              );
                                              _storageService.setInt(
                                                'selected_price',
                                                widget.accessory.pricePerHour *
                                                    _selectedHours,
                                              );
                                            }
                                          : null,
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _selectedHours.toDouble(),
                                        min: 1,
                                        max: 24,
                                        divisions: 23,
                                        label: '$_selectedHours시간',
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedHours = value.toInt();
                                          });
                                          // 시간 변경 시 쿠키 업데이트
                                          _storageService.setInt(
                                            'selected_rental_duration',
                                            _selectedHours,
                                          );
                                          _storageService.setInt(
                                            'selected_price',
                                            widget.accessory.pricePerHour *
                                                _selectedHours,
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _selectedHours < 24
                                          ? () {
                                              setState(() {
                                                _selectedHours++;
                                              });
                                              // 시간 변경 시 쿠키 업데이트
                                              _storageService.setInt(
                                                'selected_rental_duration',
                                                _selectedHours,
                                              );
                                              _storageService.setInt(
                                                'selected_price',
                                                widget.accessory.pricePerHour *
                                                    _selectedHours,
                                              );
                                            }
                                          : null,
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '시간당 가격',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${widget.accessory.pricePerHour}원',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '총 대여 시간',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '$_selectedHours시간',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
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
                                      '총 결제 금액',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${widget.accessory.pricePerHour * _selectedHours}원',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '스테이션 정보',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_selectedStation != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedStation!.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _selectedStation!.address,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _selectStation,
                                    child: const Text('변경'),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: TextButton(
                                onPressed: _selectStation,
                                child: const Text('스테이션 선택'),
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
                  Text(
                    '총 결제 금액: ${widget.accessory.pricePerHour * _selectedHours}원',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: (_selectedStation == null || _quantity == 0)
                        ? null
                        : () async {
                            // 쿠키에 정보 저장
                            await _storageService.setString(
                              'selected_accessory_id',
                              widget.accessory.id,
                            );
                            await _storageService.setString(
                              'selected_station_id',
                              _selectedStation?.id ?? '',
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
                    child: Text(
                      _selectedStation == null
                          ? '스테이션을 선택해주세요'
                          : _quantity == 0
                              ? '현재 대여 불가능'
                              : 'QR 스캔하기',
                    ),
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
