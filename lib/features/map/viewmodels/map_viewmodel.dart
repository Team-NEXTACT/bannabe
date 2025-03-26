import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../../data/models/station.dart';
import '../../../data/models/accessory.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/user_service.dart';

class MapViewModel with ChangeNotifier {
  final StationRepository _stationRepository;
  final LocationService _locationService;
  final StorageService _storageService;
  final ApiService _apiService = ApiService.instance;
  final UserService _userService = UserService.instance;

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
          NLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );
      }
    }

    // 마커 추가
    await Future.delayed(const Duration(milliseconds: 500));
    await addMarkers();
  }

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _getCurrentLocation();
      await _loadStations();
      await _loadFavoriteStations();
      _selectedStation = await _storageService.getSelectedStation();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectStation(Station station) async {
    _selectedStation = station;
    await _storageService.setSelectedStation(station);
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

  Future<void> toggleFavorite(Station station) async {
    try {
      print('[DEBUG] 북마크 토글 - 스테이션 ID: ${station.stationId}');

      final response = await _apiService.post(
        '/stations/${station.stationId}/bookmark',
        data: {},
      );

      print('[DEBUG] 북마크 토글 응답:');
      print('  - 상태 코드: ${response.statusCode}');
      print('  - 응답 데이터: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          // 북마크 상태 토글
          final isCurrentlyFavorite = isStationFavorite(station);
          if (isCurrentlyFavorite) {
            _favoriteStations
                .removeWhere((s) => s.stationId == station.stationId);
          } else {
            _favoriteStations.add(station);
          }
          notifyListeners();

          // 북마크 목록 갱신
          await _loadFavoriteStations();
        } else {
          throw response.data['message'] ?? '북마크 처리에 실패했습니다.';
        }
      }
    } catch (e) {
      print('[DEBUG] 북마크 토글 에러: $e');
      throw '북마크 처리에 실패했습니다: ${e.toString()}';
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

  Future<void> addMarkers() async {
    if (_mapController == null) return;

    final markerIcon = await NOverlayImage.fromAssetImage(
      'assets/images/honey.png',
    );

    await _mapController!.clearOverlays();

    final stations = _searchQuery.isEmpty ? _stations : _filteredStations;

    for (final station in stations) {
      final marker = NMarker(
        id: 'station_${station.stationId}',
        position: NLatLng(
          station.latitude,
          station.longitude,
        ),
        icon: markerIcon,
        size: const Size(48, 48),
        anchor: const NPoint(0.5, 0.5),
      );

      await _mapController!.addOverlay(marker);

      marker.setOnTapListener((overlay) {
        try {
          final stationId = int.parse(overlay.info.id.split('_')[1]);
          final selectedStation = _stations.firstWhere(
            (s) => s.stationId == stationId,
            orElse: () => throw Exception('Station not found'),
          );
          selectStation(selectedStation);
        } catch (e) {
          print('Error selecting station: $e');
        }
      });
    }
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
      print('[DEBUG] 북마크 스테이션 목록 조회');
      final bookmarks = await _userService.getBookmarkedStations();

      print('[DEBUG] 북마크 스테이션 목록:');
      print('  - 개수: ${bookmarks.length}');
      print('  - 북마크 ID 목록: ${bookmarks.map((b) => b.stationId).toList()}');
      print('  - 전체 스테이션 개수: ${_stations.length}');
      print('  - 전체 스테이션 ID 목록: ${_stations.map((s) => s.stationId).toList()}');

      _favoriteStations = _stations
          .where((station) => bookmarks
              .any((bookmark) => bookmark.stationId == station.stationId))
          .toList();

      print('  - 매핑된 스테이션: ${_favoriteStations.length}개');
      print(
          '  - 매핑된 스테이션 ID 목록: ${_favoriteStations.map((s) => s.stationId).toList()}');
      notifyListeners();
    } catch (e) {
      print('[DEBUG] 북마크 목록 조회 실패: $e');
      print('  - 에러 상세: $e');
      _favoriteStations = [];
      notifyListeners();
    }
  }

  bool isStationFavorite(Station station) {
    return _favoriteStations.any((s) => s.stationId == station.stationId);
  }
}
