import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/bookmark_response.dart';
import '../../../core/services/user_service.dart';

class BookmarkedStationsView extends StatefulWidget {
  const BookmarkedStationsView({super.key});

  @override
  State<BookmarkedStationsView> createState() => _BookmarkedStationsViewState();
}

class _BookmarkedStationsViewState extends State<BookmarkedStationsView> {
  bool _isLoading = false;
  String? _error;
  List<BookmarkStation> _bookmarkedStations = [];

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
      final bookmarks = await UserService.instance.getBookmarkedStations();
      setState(() {
        _bookmarkedStations = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _removeBookmark(int bookmarkId) async {
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
      await UserService.instance.removeBookmark(bookmarkId);
      setState(() {
        _bookmarkedStations
            .removeWhere((station) => station.bookmarkId == bookmarkId);
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
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 2),
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
                              station.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark),
                              color: AppColors.primary,
                              onPressed: () =>
                                  _removeBookmark(station.bookmarkId),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
