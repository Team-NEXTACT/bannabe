import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'change_nickname_view.dart';
import 'change_password_view.dart';
import 'bookmarked_stations_view.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _error;
  String? _success;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // 권한 요청 함수
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    final result = await permission.request();
    return result.isGranted;
  }

  // 카메라로 이미지 선택
  Future<void> _getImageFromCamera() async {
    final hasCameraPermission = await _requestPermission(Permission.camera);

    if (!hasCameraPermission) {
      setState(() {
        _error = '카메라 접근 권한이 필요합니다.';
        _success = null;
      });
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      setState(() {
        _error = '카메라 접근 중 오류가 발생했습니다: ${e.toString()}';
        _success = null;
      });
    }
  }

  // 갤러리에서 이미지 선택
  Future<void> _getImageFromGallery() async {
    final hasGalleryPermission = await _requestPermission(Permission.photos);

    if (!hasGalleryPermission) {
      setState(() {
        _error = '갤러리 접근 권한이 필요합니다.';
        _success = null;
      });
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      setState(() {
        _error = '갤러리 접근 중 오류가 발생했습니다: ${e.toString()}';
        _success = null;
      });
    }
  }

  // 이미지 업로드 처리
  Future<void> _uploadImage(File imageFile) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _success = null;
      });

      // PreSigned URL 조회
      final preSignedUrl =
          await AuthService.instance.getProfileImagePreSignedUrl();

      // 이미지 파일을 PreSigned URL로 업로드
      final dio = Dio();
      await dio.put(
        preSignedUrl,
        data: await imageFile.readAsBytes(),
        options: Options(
          headers: {
            'Content-Type': 'image/jpeg',
          },
        ),
      );

      // 이미지 URL 추출 (PreSigned URL에서 파일 경로 추출)
      final imageUrl = preSignedUrl.split('?')[0];

      // 프로필 이미지 업데이트
      await AuthService.instance.updateProfileImage(imageUrl);

      setState(() {
        _success = '프로필 이미지가 성공적으로 업데이트되었습니다.';
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = '이미지 업로드 실패: ${e.toString()}';
        _success = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 이미지 삭제
  Future<void> _deleteImage() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _success = null;
      });

      // 프로필 이미지를 기본 이미지로 변경
      await AuthService.instance.resetProfileImage();

      setState(() {
        _success = '프로필 이미지가 삭제되었습니다.';
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = '이미지 삭제 실패: ${e.toString()}';
        _success = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 이미지 변경 옵션 보여주기
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영하기'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택하기'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('이미지 삭제하기', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteImage();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _navigateToNicknameChange() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChangeNicknameView(),
      ),
    );
  }

  void _navigateToPasswordChange() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChangePasswordView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 관리'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 상단 프로필 정보 영역
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 프로필 이미지
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: user?.profileImageUrl != null &&
                                      user!.profileImageUrl!.isNotEmpty
                                  ? Image(
                                      image: user.profileImageUrl!
                                              .startsWith('http')
                                          ? NetworkImage(user.profileImageUrl!)
                                          : AssetImage(user.profileImageUrl!)
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/profile.jpg',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/profile.jpg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 사용자 정보 (이름, 이메일)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.nickname ?? '사용자',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 2. 프로필 이미지 변경 및 닉네임 변경 버튼
                  Row(
                    children: [
                      // 프로필 이미지 변경 버튼
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showImageOptions,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('이미지 변경'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 닉네임 변경 버튼
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _navigateToNicknameChange,
                          icon: const Icon(Icons.edit),
                          label: const Text('닉네임 변경'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 3. 비밀번호 변경 페이지로 이동하는 필드
                  InkWell(
                    onTap: _navigateToPasswordChange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '비밀번호 변경',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. 북마크한 스테이션 관리 페이지로 이동하는 필드
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BookmarkedStationsView(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '북마크한 스테이션 관리',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 오류 및 성공 메시지 표시
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  if (_success != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _success!,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColors.success,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
