import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'firebase_options.dart';
import 'app/routes.dart';
import 'core/constants/app_colors.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'data/models/rental.dart';
import 'data/models/accessory.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/signup_complete_view.dart';
import 'features/auth/views/signup_view.dart';
import 'features/auth/views/terms_view.dart';
import 'features/auth/views/forgot_password_view.dart';
import 'features/auth/views/reset_password_view.dart';
import 'features/home/views/home_view.dart';
import 'features/map/views/map_view.dart';
import 'features/mypage/views/edit_profile_view.dart';
import 'features/mypage/views/mypage_view.dart';
import 'features/notice/views/notice_list_view.dart';
import 'features/payment/views/payment_complete_view.dart';
import 'features/payment/views/payment_view.dart';
import 'features/rental/views/rental_view.dart';
import 'features/rental/views/rental_detail_view.dart';
import 'features/rental/views/rental_history_view.dart';
import 'features/rental/views/active_rentals_view.dart';
import 'data/models/station.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NaverMapSdk.instance.initialize(
    clientId: 'gaumfmevf3',
    onAuthFailed: (error) {
      print('네이버 지도 인증 실패: $error');
    },
  );
  await AuthService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bannabee',
      debugShowCheckedModeBanner: false,
      navigatorKey: ApiService.navigatorKey,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => const HomeView(),
        Routes.map: (context) => const MapView(),
        Routes.rental: (context) {
          final station =
              ModalRoute.of(context)!.settings.arguments as Station?;
          return RentalView(station: station);
        },
        Routes.rentalDetail: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return RentalDetailView(
            itemTypeId: args['itemTypeId'] as int,
            itemName: args['name'] as String,
            station: args['station'] as Station?,
          );
        },
        Routes.rentalStatus: (context) => const ActiveRentalsView(),
        Routes.rentalHistory: (context) => const RentalHistoryView(),
        Routes.payment: (context) => PaymentView(
              arguments: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        Routes.paymentComplete: (context) => PaymentCompleteView(
              rental: ModalRoute.of(context)!.settings.arguments as Rental,
            ),
        Routes.mypage: (context) => const MyPageView(),
        Routes.editProfile: (context) => const EditProfileView(),
        Routes.login: (context) => const LoginView(),
        Routes.terms: (context) => const TermsView(),
        Routes.signup: (context) => const SignupView(),
        Routes.signupComplete: (context) => const SignupCompleteView(),
        Routes.noticeList: (context) => const NoticeListView(),
        Routes.forgotPassword: (context) => const ForgotPasswordView(),
        Routes.resetPassword: (context) => const ResetPasswordView(),
      },
    );
  }
}
