import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/rental_viewmodel.dart';
import '../../../data/models/accessory.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../../app/routes.dart';
import './rental_detail_view.dart';
import '../../../core/widgets/loading_animation.dart';
import '../../../core/constants/app_colors.dart';
import 'dart:math';

class RentalView extends StatelessWidget {
  const RentalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RentalViewModel(),
      child: const _RentalContent(),
    );
  }
}

class _RentalContent extends StatelessWidget {
  const _RentalContent();

  String _getCategoryName(AccessoryCategory category) {
    switch (category) {
      case AccessoryCategory.charger:
        return '충전기';
      case AccessoryCategory.powerBank:
        return '보조배터리';
      case AccessoryCategory.dock:
        return '독';
      case AccessoryCategory.cable:
        return '케이블';
      default:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('대여하기'),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.home);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: SafeArea(
              child: Consumer<RentalViewModel>(
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

                  return DefaultTextStyle.merge(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    child: RefreshIndicator(
                      onRefresh: viewModel.refresh,
                      child: CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 16),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '대여 가능한 물품',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFBE00)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: Theme.of(context).primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            onChanged:
                                                viewModel.searchAccessories,
                                            decoration: const InputDecoration(
                                              hintText: '악세사리 검색',
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 45,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFE0E0E0),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: AccessoryCategory.values
                                            .map(
                                              (category) => IntrinsicWidth(
                                                child: _buildCategoryTab(
                                                  context,
                                                  _getCategoryName(category),
                                                  category.toString(),
                                                  viewModel,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final accessory =
                                      viewModel.filteredAccessories[index];
                                  // 임시로 랜덤 수량 생성 (1~5)
                                  // 마지막 아이템은 재고 없음으로 설정
                                  final quantity = accessory.isAvailable
                                      ? Random().nextInt(5) + 1
                                      : 0;
                                  return InkWell(
                                    onTap: () {
                                      viewModel.selectAccessory(accessory);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RentalDetailView(
                                            accessory: accessory,
                                            station: viewModel.selectedStation,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Stack(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                ),
                                                child: Image.asset(
                                                  accessory.imageUrl.isNotEmpty
                                                      ? accessory.imageUrl
                                                      : 'assets/images/bannabe.png',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/bannabe.png',
                                                      fit: BoxFit.contain,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (quantity == 0)
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      '재고 없음',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                accessory.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                childCount:
                                    viewModel.filteredAccessories.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const AppBottomNavigationBar(currentIndex: 1),
      ],
    );
  }

  Widget _buildCategoryTab(
    BuildContext context,
    String label,
    String value,
    RentalViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedCategory == value;
    return InkWell(
      onTap: () => viewModel.selectCategory(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFFFBE00) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
