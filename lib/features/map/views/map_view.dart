import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../../core/widgets/loading_animation.dart';
import '../viewmodels/map_viewmodel.dart';
import '../../../app/routes.dart';
import '../../../features/rental/views/rental_detail_view.dart';
import '../../../core/services/storage_service.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel()..init(),
      child: _MapContent(),
    );
  }
}

class _MapContent extends StatelessWidget {
  _MapContent();

  final _storageService = StorageService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 스테이션'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showRecentStations(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              _showFavoriteStations(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<MapViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(
                child: HoneyLoadingAnimation(
                  isStationSelected: false,
                ),
              );
            }

            if (viewModel.error != null) {
              return Center(
                child: Text(
                  viewModel.error!,
                  style: AppTheme.bodyMedium,
                ),
              );
            }

            return Stack(
              children: [
                NaverMap(
                  onMapReady: viewModel.onMapCreated,
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: viewModel.currentLocation != null
                          ? NLatLng(
                              viewModel.currentLocation!.latitude,
                              viewModel.currentLocation!.longitude,
                            )
                          : const NLatLng(37.5665, 126.9780),
                      zoom: 15,
                    ),
                    contentPadding: const EdgeInsets.all(0),
                  ),
                  onMapTapped: (point, latLng) {
                    viewModel.clearSelectedStation();
                  },
                ),
                // 검색 바
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: viewModel.searchStations,
                      decoration: InputDecoration(
                        hintText: '스테이션 검색',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 현재 위치 버튼
                Positioned(
                  right: 16,
                  bottom: viewModel.selectedStation != null ? 200 : 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.black,
                    ),
                    onPressed: viewModel.moveToCurrentLocation,
                  ),
                ),
                // 선택된 스테이션 정보
                if (viewModel.selectedStation != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      viewModel.selectedStation!.name,
                                      style: AppTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      viewModel.selectedStation!.address,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppColors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin:
                                              const EdgeInsets.only(right: 4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: viewModel
                                                .selectedStation!.statusColor,
                                          ),
                                        ),
                                        Text(
                                          '${viewModel.selectedStation!.stations_status} · ${viewModel.selectedStation!.business_time}',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      viewModel.isStationFavorite(
                                              viewModel.selectedStation!)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () => viewModel.toggleFavorite(
                                        viewModel.selectedStation!),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.grey,
                                    ),
                                    onPressed: viewModel.clearSelectedStation,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.black,
                              ),
                              child: const Text('대여 가능 물품 조회'),
                              onPressed: () async {
                                // 선택된 스테이션 정보 저장
                                await _storageService.setString(
                                  'selected_station_id',
                                  viewModel.selectedStation!.id.toString(),
                                );
                                await _storageService.setString(
                                  'selected_station_name',
                                  viewModel.selectedStation!.name,
                                );

                                final savedAccessory =
                                    await viewModel.getSelectedAccessory();
                                if (savedAccessory != null) {
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RentalDetailView(
                                          accessory: savedAccessory,
                                          station: viewModel.selectedStation,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  Navigator.of(context).pushNamed(
                                    Routes.rental,
                                    arguments: viewModel.selectedStation,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }

  void _showRecentStations(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Consumer<MapViewModel>(
            builder: (context, viewModel, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('최근 이용 스테이션', style: AppTheme.titleMedium),
                    const SizedBox(height: 16),
                    if (viewModel.recentStations.isEmpty)
                      const Center(
                        child: Text('최근 이용한 스테이션이 없습니다'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: viewModel.recentStations.length,
                        itemBuilder: (context, index) {
                          final station = viewModel.recentStations[index];
                          return ListTile(
                            title: Text(station.name),
                            subtitle: Text(station.address),
                            onTap: () {
                              viewModel.selectStation(station);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFavoriteStations(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Consumer<MapViewModel>(
            builder: (context, viewModel, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('즐겨찾기', style: AppTheme.titleMedium),
                    const SizedBox(height: 16),
                    if (viewModel.favoriteStations.isEmpty)
                      const Center(
                        child: Text('즐겨찾기한 스테이션이 없습니다'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: viewModel.favoriteStations.length,
                        itemBuilder: (context, index) {
                          final station = viewModel.favoriteStations[index];
                          return ListTile(
                            title: Text(station.name),
                            subtitle: Text(station.address),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite),
                              color: AppColors.primary,
                              onPressed: () =>
                                  viewModel.toggleFavorite(station),
                            ),
                            onTap: () {
                              viewModel.selectStation(station);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
