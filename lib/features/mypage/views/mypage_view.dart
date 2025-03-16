import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../../app/routes.dart';
import '../../../features/rental/views/active_rentals_view.dart';
import '../../../features/rental/views/rental_history_view.dart';
import 'package:provider/provider.dart';

class MyPageView extends StatefulWidget {
  const MyPageView({super.key});

  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  @override
  void initState() {
    super.initState();
    // 페이지가 로드될 때 사용자 프로필 정보를 가져옵니다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.instance.fetchUserProfile();
    });
  }

  // URL 실행 함수
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthService를 리스닝하여 사용자 정보 변경 시 UI 업데이트
    return ChangeNotifierProvider.value(
      value: AuthService.instance,
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          final user = authService.currentUser;

          return Scaffold(
            appBar: AppBar(
              title: const Text('마이페이지'),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. 회원 정보 필드
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(
                                image: user?.profileImageUrl != null &&
                                        user!.profileImageUrl!.isNotEmpty
                                    ? (user.profileImageUrl!.startsWith('http')
                                        ? NetworkImage(user.profileImageUrl!)
                                            as ImageProvider
                                        : AssetImage(user.profileImageUrl!))
                                    : const AssetImage(
                                        'assets/images/profile.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.nickname != null &&
                                          user!.nickname!.isNotEmpty
                                      ? '${user.nickname}님'
                                      : '사용자님',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(Routes.editProfile);
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. 대여 관련 메뉴
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '대여 관리',
                            style: AppTheme.titleMedium.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMenuButton(
                                  context,
                                  icon: Icons.access_time_filled,
                                  label: '대여 현황',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ActiveRentalsView(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMenuButton(
                                  context,
                                  icon: Icons.receipt_long,
                                  label: '대여 내역',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RentalHistoryView(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. 고객지원 필드
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '고객지원',
                            style: AppTheme.titleMedium.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            children: [
                              _buildSupportButton(
                                '이용 약관',
                                Icons.description_outlined,
                                onPressed: () {
                                  // TODO: 이용 약관 페이지로 이동
                                },
                              ),
                              _buildSupportButton(
                                '개인정보\n처리방침',
                                Icons.security_outlined,
                                onPressed: () {
                                  // TODO: 개인정보 처리방침 페이지로 이동
                                },
                              ),
                              _buildSupportButton(
                                '공지사항',
                                Icons.notifications_outlined,
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(Routes.noticeList);
                                },
                              ),
                              _buildSupportButton(
                                '자주 묻는 질문',
                                Icons.help_outline,
                                onPressed: () {
                                  // TODO: FAQ 페이지로 이동
                                },
                              ),
                              _buildSupportButton(
                                '전화문의',
                                Icons.phone_outlined,
                                onPressed: () {
                                  // TODO: 전화문의 기능 구현
                                },
                              ),
                              _buildSupportButton(
                                '1:1 채팅상담',
                                Icons.chat_outlined,
                                onPressed: () {
                                  _launchURL('http://pf.kakao.com/_uRFKn');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. 로그아웃 버튼
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await AuthService.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.login,
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('로그아웃 실패: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.grey),
                      label: const Text('로그아웃'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportButton(
    String label,
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.grey[700],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
