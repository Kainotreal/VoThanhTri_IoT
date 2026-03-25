import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/get_started_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/password_recovery/screens/forgot_password_screen.dart';
import '../../features/password_recovery/screens/otp_screen.dart';
import '../../features/password_recovery/screens/secure_account_screen.dart';
import '../../features/password_recovery/screens/success_screen.dart';
import '../../features/account_setup/screens/country_origin_screen.dart';
import '../../features/account_setup/screens/home_name_screen.dart';
import '../../features/account_setup/screens/add_rooms_screen.dart';
import '../../features/account_setup/screens/set_location_screen.dart';
import '../../features/account_setup/screens/well_done_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/add_device_screen.dart';
import '../../features/home/screens/scan_device_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const getStarted = '/get-started';
  static const signUp = '/sign-up';
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot-password';
  static const enterOtp = '/enter-otp';
  static const secureAccount = '/secure-account';
  static const countryOrigin = '/country-origin';
  static const homeName = '/home-name';
  static const addRooms = '/add-rooms';
  static const setLocation = '/set-location';
  static const wellDone = '/well-done';
  static const home = '/home';
  static const addDevice = '/add-device';
  static const scanDevice = '/scan-device';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: getStarted,
        builder: (context, state) => const GetStartedScreen(),
      ),
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: enterOtp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: secureAccount,
        builder: (context, state) => const SecureAccountScreen(),
      ),
      GoRoute(
        path: '/password-success',
        builder: (context, state) => const PasswordSuccessScreen(),
      ),
      GoRoute(
        path: countryOrigin,
        builder: (context, state) => const CountryOriginScreen(),
      ),
      GoRoute(
        path: homeName,
        builder: (context, state) => const HomeNameScreen(),
      ),
      GoRoute(
        path: addRooms,
        builder: (context, state) => const AddRoomsScreen(),
      ),
      GoRoute(
        path: setLocation,
        builder: (context, state) => const SetLocationScreen(),
      ),
      GoRoute(
        path: wellDone,
        builder: (context, state) => const WellDoneScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: addDevice,
        builder: (context, state) {
          final initialDevice = state.extra as DeviceItem?;
          return AddDeviceScreen(initialDevice: initialDevice);
        },
      ),
      GoRoute(
        path: scanDevice,
        builder: (context, state) => const ScanDeviceScreen(),
      ),
    ],
  );
}
