import 'package:flutter/foundation.dart';
import '../../../data/models/accessory.dart';
import '../../../data/models/station.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/station_service.dart';
import '../../../data/models/rental_item_detail_response.dart';

class RentalViewModel extends ChangeNotifier {
  final StationRepository _stationRepository = StationRepository.instance;
  final StorageService _storageService = StorageService.instance;
  final StationService _stationService = StationService.instance;

  List<Accessory> _accessories = [];
  List<Station> _stations = [];
  String? _selectedCategory;
  Station? _selectedStation;
  Accessory? _selectedAccessory;
  RentalItemDetail? _selectedItemDetail;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  List<Accessory> get accessories => _accessories;
  List<Station> get stations => _stations;
  Station? get selectedStation => _selectedStation;
  Accessory? get selectedAccessory => _selectedAccessory;
  RentalItemDetail? get selectedItemDetail => _selectedItemDetail;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RentalViewModel() {
    _init();
  }

  Future<void> init(Station? station) async {
    _selectedStation = station;
    await refresh();
    // 초기 카테고리를 첫 번째 카테고리로 설정
    selectCategory(AccessoryCategory.values.first.toString());
  }

  Future<void> _init() async {
    await refresh();
    // 초기 카테고리를 첫 번째 카테고리로 설정
    selectCategory(AccessoryCategory.values.first.toString());
  }

  Future<void> selectStation(Station station) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedStation = station;
      await _storageService.setSelectedStation(station);

      // 선택된 스테이션의 대여 가능 물품 목록 로드
      final response =
          await _stationService.getStationRentalItems(station.stationId);

      _accessories = response.data.rentalItems.map((item) {
        final imageUrl = item.image;

        return Accessory(
          itemTypeId: item.itemTypeId.toString(),
          name: item.name,
          description: '', // API에서 제공되지 않음
          imageUrl: imageUrl,
          category: _getCategoryFromString(item.category),
          price: 0, // API에서 제공되지 않음, 상세 정보에서 제공
          stock: item.stock,
        );
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AccessoryCategory _getCategoryFromString(String category) {
    switch (category.toUpperCase()) {
      case 'CHARGER':
        return AccessoryCategory.charger;
      case 'POWER_BANK':
        return AccessoryCategory.powerBank;
      case 'HUB':
        return AccessoryCategory.dock;
      case 'CABLE':
        return AccessoryCategory.cable;
      default:
        return AccessoryCategory.etc;
    }
  }

  Future<void> selectAccessory(Accessory accessory) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedAccessory = accessory;
      await _storageService.setSelectedAccessory(accessory);

      // 선택된 물품의 상세 정보 로드
      if (_selectedStation != null) {
        final detail = await _stationService.getRentalItemDetail(
          _selectedStation!.stationId,
          int.parse(accessory.itemTypeId),
        );
        _selectedItemDetail = detail.data;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearSelections() async {
    _selectedStation = null;
    _selectedAccessory = null;
    _selectedItemDetail = null;
    await _storageService.clearSelections();
    notifyListeners();
  }

  Future<void> _loadStations() async {
    final stations = await _stationRepository.getNearbyStations();
    _stations = stations;
  }

  List<Accessory> get filteredAccessories {
    return _accessories.where((accessory) {
      // 카테고리 필터링
      if (_selectedCategory != null &&
          accessory.category.toString() != _selectedCategory) {
        return false;
      }

      // 검색어 필터링
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return accessory.name.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void searchAccessories(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadStations();

      // 저장된 스테이션과 액세서리 정보 불러오기
      _selectedStation = await _storageService.getSelectedStation();
      if (_selectedStation != null) {
        await selectStation(_selectedStation!);
      }

      _selectedAccessory = await _storageService.getSelectedAccessory();
      if (_selectedAccessory != null) {
        await selectAccessory(_selectedAccessory!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
