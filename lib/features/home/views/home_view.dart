import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../../core/widgets/loading_animation.dart';
import '../../../app/routes.dart';
import '../../../core/widgets/map_view.dart';
import 'dart:async';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_pageController.hasClients) return;

      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Bannabee'),
                centerTitle: true,
                automaticallyImplyLeading: false,
              ),
              body: SafeArea(
                child: Consumer<HomeViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(
                        child: HoneyLoadingAnimation(
                          isStationSelected: false,
                        ),
                      );
                    }

                    if (viewModel.error != null) {
                      return Center(child: Text(viewModel.error!));
                    }

                    if (!viewModel.hasLocationPermission &&
                        !viewModel.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '위치 권한이 필요합니다',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '주변 스테이션을 찾기 위해\n위치 권한이 필요합니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              child: const Text('위치 권한 허용'),
                              onPressed: () async {
                                final hasPermission =
                                    await viewModel.requestLocationPermission();
                                if (!hasPermission && context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('위치 권한 필요'),
                                      content: const Text(
                                        '주변 스테이션을 찾기 위해 위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('취소'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // TODO: 시스템 설정으로 이동
                                          },
                                          child: const Text('설정으로 이동'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: viewModel.refresh,
                      child: CustomScrollView(
                        slivers: [
                          const SliverPadding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DefaultTextStyle.merge(
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                                child: Column(
                                  children: [
                                    _buildEventBannerSection(context),
                                    const SizedBox(height: 24),
                                    _buildNoticeSection(context, viewModel),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '스테이션 찾기',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AspectRatio(
                                    aspectRatio: 2,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          Routes.map,
                                          arguments: {
                                            'onStationSelected': true,
                                            'stations':
                                                viewModel.nearbyStations,
                                          },
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: MapView(
                                          isPreview: true,
                                          initialPosition:
                                              viewModel.currentLocation,
                                          stations: viewModel.nearbyStations,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const AppBottomNavigationBar(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildEventBannerSection(BuildContext context) {
    final List<Map<String, String>> events = [
      {
        'title': '신규 가입 이벤트',
        'description': '첫 대여 시 1시간 무료!',
        'image': 'assets/images/smartphone_qr_code_man.png',
        'backgroundColor': '#FFBE00',
      },
      {
        'title': '멤버십 할인 이벤트',
        'description': '월 99,900원으로 무제한 대여',
        'image': 'assets/images/pc_smartphone_battery_juuden.png',
        'backgroundColor': '#FF6B6B',
      },
      {
        'title': '친구 초대 이벤트',
        'description': '친구 초대하고 포인트 받기',
        'image': 'assets/images/smartphone_couple.png',
        'backgroundColor': '#4ECDC4',
      },
    ];

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: events.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Color(int.parse(
                          event['backgroundColor']!.substring(1, 7),
                          radix: 16) +
                      0xFF000000),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    if (event['image'] != null)
                      Positioned(
                        right: -25,
                        top: 0,
                        bottom: 0,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Image.asset(
                          event['image']!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            );
                          },
                        ),
                      ),
                    Positioned(
                      left: 24,
                      top: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'EVENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event['description']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 24,
            child: Row(
              children: List.generate(events.length, (index) {
                return Container(
                  width: 24,
                  height: 4,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeSection(BuildContext context, HomeViewModel viewModel) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.noticeList);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text(
              '공지사항 | ',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.latestNotice?.title ?? '새로운 공지사항이 없습니다.',
                style: const TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
/*
  Future<void> _saveRentalInfo(Rental rental) async {
    final storageService = StorageService.instance;
    await storageService.setString('selected_accessory_id', rental.accessoryId);
    await storageService.setString('selected_station_id', rental.stationId);

    // 대여 시간 계산 (최소 1시간)
    final rentalHours = rental.updatedAt.difference(rental.createdAt).inHours;
    final hours = rentalHours > 0 ? rentalHours : 1;
    await storageService.setInt('selected_rental_duration', hours.clamp(1, 24));
  }

  Future<Map<String, dynamic>> _getAccessoryFromRental(Rental rental) async {
    // 대여 시간 계산 (최소 1시간)
    final rentalHours = rental.updatedAt.difference(rental.createdAt).inHours;
    final hours = rentalHours > 0 ? rentalHours : 1;

    return {
      'id': rental.accessoryId,
      'name': rental.accessoryName,
      'pricePerHour': rental.totalPrice ~/ hours,
      'imageUrl': 'assets/images/accessories/${rental.accessoryId}.png',
      'isAvailable': true,
    };
  }
*/
}
