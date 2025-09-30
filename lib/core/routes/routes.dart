import 'package:go_router/go_router.dart';
import 'package:minilauncher/features/presentation/screen/dashbord_screen.dart';
import 'package:minilauncher/features/presentation/screen/lanch_screen.dart';
import 'package:minilauncher/features/presentation/screen/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash_screen',
    routes: [
      GoRoute(
        path: '/splash_screen',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/lanch_screen',  
        name: 'lanch',         
        builder: (context, state) => const LauncherHome(),
      ),
      GoRoute(
        path: '/dashbord_screen',
        name: 'dashbord',
        builder: (context, state) => const DashbordScreen(),
      )
    ],
  );
}
