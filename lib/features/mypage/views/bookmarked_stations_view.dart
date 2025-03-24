import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';

class BookmarkedStationsView extends StatefulWidget {
  const BookmarkedStationsView({super.key});

  @override
  State<BookmarkedStationsView> createState() => _BookmarkedStationsViewState();
}

class _BookmarkedStationsViewState extends State<BookmarkedStationsView> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _bookmarkedStations = []; // 임시 데이터 구조

  @override
  void initState() {
    super.initState();
    _loadBookmarkedStations();
  }

  Future<void> _loadBookmarkedStations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: API 호출하여 북마크한 스테이션 목록 가져오기
      // 임시 데이터
      await Future.delayed(const Duration(seconds: 1));
      _bookmarkedStations = [
        {
          'id': '1',
          'name': '강남역 1번 출구',
          'address': '서울특별시 강남구 강남대로 396',
        },
        {
          'id': '2',
          'name': '신논현역 4번 출구',
          'address': '서울특별시 강남구 봉은사로 102',
        },
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '북마크한 스테이션을 불러오는데 실패했습니다.';
      });
    }
  }

  Future<void> _removeBookmark(String stationId) async {
    // 삭제 확인 다이얼로그 표시
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('북마크 삭제'),
        content: const Text('이 스테이션을 북마크에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    // 사용자가 취소를 선택하거나 다이얼로그를 닫은 경우
    if (shouldDelete != true) {
      return;
    }

    try {
      // TODO: API 호출하여 북마크 삭제
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _bookmarkedStations
            .removeWhere((station) => station['id'] == stationId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('북마크가 삭제되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('북마크 삭제에 실패했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크한 스테이션'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBookmarkedStations,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _bookmarkedStations.isEmpty
                  ? const Center(
                      child: Text(
                        '북마크한 스테이션이 없습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookmarkedStations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final station = _bookmarkedStations[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            title: Text(
                              station['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              station['address'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark),
                              color: AppColors.primary,
                              onPressed: () => _removeBookmark(station['id']),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
