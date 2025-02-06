import 'package:flutter/foundation.dart';
import '../../../data/models/accessory.dart';
import '../../../data/models/station.dart';
import '../../../data/repositories/accessory_repository.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../core/services/storage_service.dart';

class RentalViewModel extends ChangeNotifier {
  final AccessoryRepository _accessoryRepository = AccessoryRepository();
  final StationRepository _stationRepository = StationRepository.instance;
  final StorageService _storageService = StorageService.instance;

  List<Accessory> _accessories = [];
  List<Station> _stations = [];
  String? _selectedCategory;
  Station? _selectedStation;
  Accessory? _selectedAccessory;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  List<Accessory> get accessories => _accessories;
  List<Station> get stations => _stations;
  Station? get selectedStation => _selectedStation;
  Accessory? get selectedAccessory => _selectedAccessory;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RentalViewModel() {
    _init();
  }

  Future<void> _init() async {
    await refresh();
    // 초기 카테고리를 첫 번째 카테고리로 설정
    selectCategory(AccessoryCategory.values.first.toString());
  }

  Future<void> selectStation(Station station) async {
    _selectedStation = station;
    await _storageService.setSelectedStation(station);
    notifyListeners();
  }

  Future<void> selectAccessory(Accessory accessory) async {
    _selectedAccessory = accessory;
    await _storageService.setSelectedAccessory(accessory);
    notifyListeners();
  }

  Future<void> clearSelections() async {
    _selectedStation = null;
    _selectedAccessory = null;
    await _storageService.clearSelections();
    notifyListeners();
  }

  Future<void> _loadAccessories() async {
    final accessories = await _accessoryRepository.getAll();
    _accessories = accessories;
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
        return accessory.name.toLowerCase().contains(query) ||
            accessory.description.toLowerCase().contains(query);
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
      await Future.wait([
        _loadAccessories(),
        _loadStations(),
      ]);

      // 저장된 스테이션과 액세서리 정보 불러오기
      _selectedStation = await _storageService.getSelectedStation();
      _selectedAccessory = await _storageService.getSelectedAccessory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
