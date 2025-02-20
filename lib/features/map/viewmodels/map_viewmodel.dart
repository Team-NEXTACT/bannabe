import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../../data/models/station.dart';
import '../../../data/models/accessory.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';

class MapViewModel with ChangeNotifier {
  final StationRepository _stationRepository;
  final LocationService _locationService;
  final StorageService _storageService;

  List<NMarker> _markers = [];
  Position? _currentPosition;
  Station? _selectedStation;
  bool _isLoading = false;
  String? _error;
  NaverMapController? _mapController;
  NLocationOverlay? _locationOverlay;
  final List<Station> _stations = [];
  List<Station> _filteredStations = [];
  List<Station> _favoriteStations = [];
  List<Station> _recentStations = [];
  String _searchQuery = '';

  MapViewModel({
    StationRepository? stationRepository,
    LocationService? locationService,
    StorageService? storageService,
  })  : _stationRepository = stationRepository ?? StationRepository.instance,
        _locationService = locationService ?? LocationService.instance,
        _storageService = storageService ?? StorageService.instance;

  List<NMarker> get naverMarkers => _markers;
  Position? get currentLocation => _currentPosition;
  Station? get selectedStation => _selectedStation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Station> get favoriteStations => _favoriteStations;
  List<Station> get recentStations => _recentStations;

  Future<void> onMapCreated(NaverMapController controller) async {
    _mapController = controller;
    _locationOverlay = await controller.getLocationOverlay();

    // 현재 위치로 이동
    if (_currentPosition != null) {
      await _mapController?.updateCamera(
        NCameraUpdate.withParams(
          target:
              NLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 15,
        ),
      );
    }

    // 현재 위치 오버레이 활성화
    if (_locationOverlay != null) {
      _locationOverlay!.setIsVisible(true);
      if (_currentPosition != null) {
        _locationOverlay!.setPosition(
          NLatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
        );
      }
    }

    // 마커 추가
    await Future.delayed(const Duration(milliseconds: 500));
    await addMarkers();
  }

  Future<void> addMarkers() async {
    if (_mapController == null) return;

    final markerIcon = await NOverlayImage.fromAssetImage(
      'assets/images/honey.png',
    );

    _markers.clear();
    final stations = _searchQuery.isEmpty ? _stations : _filteredStations;

    for (final station in stations) {
      final marker = NMarker(
        id: station.id.toString(),
        position: NLatLng(
          station.latitude,
          station.longitude,
        ),
        icon: markerIcon,
        size: const Size(48, 48),
        anchor: const NPoint(0.5, 0.5),
      );

      marker.setOnTapListener((marker) {
        selectStation(
          stations.firstWhere((s) => s.id == marker.info.id),
        );
      });

      _markers.add(marker);
    }

    await _mapController?.clearOverlays();
    await _mapController?.addOverlayAll(_markers.toSet());
  }

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 현재 위치를 먼저 가져옴
      await _getCurrentLocation();

      // 모든 스테이션 로드
      await _loadStations();

      // 저장된 스테이션 정보 불러오기
      _selectedStation = await _storageService.getSelectedStation();

      // 즐겨찾기 및 최근 이용 스테이션 불러오기
      await _loadFavoriteStations();
      await _loadRecentStations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _currentPosition = position;
      if (_locationOverlay != null) {
        _locationOverlay!.setPosition(
          NLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );
        _locationOverlay!.setIsVisible(true);

        if (_mapController != null) {
          await _mapController!.updateCamera(
            NCameraUpdate.withParams(
              target: NLatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15,
            ),
          );
        }
      }
      notifyListeners();
    }
  }

  Future<void> _loadStations() async {
    try {
      final stations = await _stationRepository.getNearbyStations();
      _stations.clear();
      _stations.addAll(stations);
      _filteredStations = _stations;
      await addMarkers();
    } catch (e) {
      print('Failed to load stations: $e');
    }
  }

  Future<void> selectStation(Station station) async {
    _selectedStation = station;
    // 선택한 스테이션 정보 저장
    await _storageService.setSelectedStation(station);
    // 최근 이용 스테이션에 추가
    await _addToRecentStations(station);
    if (_mapController != null) {
      await _mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(station.latitude, station.longitude),
          zoom: 15,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> moveToCurrentLocation() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    } else if (_mapController != null) {
      await _mapController!.updateCamera(
        NCameraUpdate.withParams(
          target:
              NLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 15,
        ),
      );
    }
  }

  Future<Accessory?> getSelectedAccessory() async {
    return await _storageService.getSelectedAccessory();
  }

  void clearSelectedStation() {
    _selectedStation = null;
    _storageService.clearSelections();
    notifyListeners();
  }

  // 검색 기능
  void searchStations(String query) {
    _searchQuery = query.toLowerCase();
    _filteredStations = _stations.where((station) {
      return station.name.toLowerCase().contains(_searchQuery) ||
          station.address.toLowerCase().contains(_searchQuery);
    }).toList();

    // 검색 결과가 있으면 첫 번째 결과로 지도 중심 이동
    if (_filteredStations.isNotEmpty && _mapController != null) {
      final firstStation = _filteredStations.first;
      _mapController!.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(firstStation.latitude, firstStation.longitude),
          zoom: 15,
        ),
      );
    }

    addMarkers();
    notifyListeners();
  }

  // 즐겨찾기 기능
  Future<void> _loadFavoriteStations() async {
    try {
      final favoriteIds =
          await _storageService.getStringList('favorite_stations') ?? [];
      _favoriteStations = _stations
          .where((station) => favoriteIds.contains(station.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Failed to load favorite stations: $e');
    }
  }

  bool isStationFavorite(Station station) {
    return _favoriteStations.any((s) => s.id == station.id);
  }

  Future<void> toggleFavorite(Station station) async {
    try {
      if (isStationFavorite(station)) {
        _favoriteStations.removeWhere((s) => s.id == station.id);
      } else {
        _favoriteStations.add(station);
      }

      await _storageService.setStringList(
        'favorite_stations',
        _favoriteStations.map((s) => s.id.toString()).toList(),
      );
      notifyListeners();
    } catch (e) {
      print('Failed to toggle favorite: $e');
    }
  }

  // 최근 이용 스테이션 기능
  Future<void> _loadRecentStations() async {
    try {
      final recentIds =
          await _storageService.getStringList('recent_stations') ?? [];
      _recentStations =
          _stations.where((station) => recentIds.contains(station.id)).toList();
      notifyListeners();
    } catch (e) {
      print('Failed to load recent stations: $e');
    }
  }

  Future<void> _addToRecentStations(Station station) async {
    try {
      _recentStations.removeWhere((s) => s.id == station.id);
      _recentStations.insert(0, station);
      if (_recentStations.length > 5) {
        _recentStations = _recentStations.sublist(0, 5);
      }

      await _storageService.setStringList(
        'recent_stations',
        _recentStations.map((s) => s.id.toString()).toList(),
      );
      notifyListeners();
    } catch (e) {
      print('Failed to add to recent stations: $e');
    }
  }
}
