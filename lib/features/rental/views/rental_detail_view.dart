import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import './qr_scan_view.dart';
import '../../../data/models/station.dart';
import '../../../app/routes.dart';
import '../../../core/services/station_service.dart';
import '../../../data/models/rental_item_detail_response.dart';

class RentalDetailView extends StatefulWidget {
  final int itemTypeId;
  final String itemName;
  final Station? station;

  const RentalDetailView({
    Key? key,
    required this.itemTypeId,
    required this.itemName,
    this.station,
  }) : super(key: key);

  @override
  State<RentalDetailView> createState() => _RentalDetailViewState();
}

class _RentalDetailViewState extends State<RentalDetailView> {
  final _storageService = StorageService.instance;
  final _stationService = StationService.instance;
  Station? _selectedStation;
  int _selectedHours = 1;
  bool _isLoading = true;
  String? _error;
  RentalItemDetail? _itemDetail;

  @override
  void initState() {
    super.initState();
    _selectedStation = widget.station;

    // 초기 대여 시간 쿠키 생성
    _storageService.setInt('selected_rental_duration', _selectedHours);

    _loadSavedInfo();
    _loadItemDetail();
  }

  Future<void> _loadItemDetail() async {
    if (_selectedStation == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _stationService.getRentalItemDetail(
        _selectedStation!.stationId,
        widget.itemTypeId,
      );

      if (mounted) {
        setState(() {
          _itemDetail = response.data;
          _storageService.setInt(
            'selected_price',
            response.data.price * _selectedHours,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSavedInfo() async {
    try {
      if (_selectedStation == null) {
        // 저장된 스테이션 정보 불러오기
        _selectedStation = await _storageService.getSelectedStation();

        if (_selectedStation != null && mounted) {
          _loadItemDetail(); // 스테이션 정보가 로드되면 상세 정보도 다시 로드
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

    if (station != null && mounted) {
      setState(() {
        _selectedStation = station as Station;
      });
      await _storageService.setSelectedStation(_selectedStation!);
      _loadItemDetail(); // 스테이션이 선택되면 상세 정보 로드
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadItemDetail,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_itemDetail != null) ...[
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    color: Colors.grey[200],
                                    child: Image.network(
                                      _itemDetail!.image,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.image_not_supported,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '이미지를 불러올 수 없습니다',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        _itemDetail!.category,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _itemDetail!.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_itemDetail!.price}원/시간',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _itemDetail!.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 24),
                                      if (_selectedStation != null &&
                                          _itemDetail!.stock > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '남은 수량: ${_itemDetail!.stock}개',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
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
                            else if (_itemDetail != null &&
                                _itemDetail!.stock <= 0)
                              ElevatedButton(
                                onPressed: null,
                                child: const Text('현재 대여 불가능'),
                              )
                            else if (_itemDetail != null)
                              ElevatedButton(
                                onPressed: () async {
                                  // 쿠키에 정보 저장
                                  await _storageService.setInt(
                                    'selected_rental_duration',
                                    _selectedHours,
                                  );
                                  await _storageService.setInt(
                                    'selected_price',
                                    _itemDetail!.price * _selectedHours,
                                  );

                                  final scanned =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => QRScanView(
                                        rentalDuration: _selectedHours,
                                        isReturn: false,
                                      ),
                                    ),
                                  );

                                  if (scanned == true && context.mounted) {
                                    Navigator.of(context)
                                        .pushNamed(Routes.payment);
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
