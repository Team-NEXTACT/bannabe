import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/station_selection_viewmodel.dart';
import '../../../core/widgets/loading_animation.dart';
import '../../../data/models/station.dart';

class StationSelectionView extends StatelessWidget {
  final Station? currentStation;

  const StationSelectionView({
    super.key,
    this.currentStation,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          StationSelectionViewModel(currentStation: currentStation),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('스테이션 선택'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Consumer<StationSelectionViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(
                  child: HoneyLoadingAnimation(
                    isStationSelected: false,
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: viewModel.searchStations,
                      decoration: InputDecoration(
                        hintText: '스테이션 검색',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = viewModel.filteredStations[index];
                        final isSelected =
                            viewModel.currentStation?.stationId == station.stationId;

                        return InkWell(
                          onTap: () {
                            viewModel.selectStation(station);
                            Navigator.of(context).pop(station);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1)
                                  : null,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 0.5,
                                ),
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
                                        station.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        station.address,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
