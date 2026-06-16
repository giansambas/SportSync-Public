import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportsync/features/about/screens/about_screen.dart';
import 'package:sportsync/features/booking/screens/booking_screen.dart';
import 'package:sportsync/features/bookings/screens/my_bookings_screen.dart';
import 'package:sportsync/features/courts/screens/court_detail_screen.dart';
import 'package:sportsync/features/home/data/sample_courts.dart';
import 'package:sportsync/features/home/screens/home_screen.dart';
import 'package:sportsync/features/profile/screens/edit_profile_screen.dart';
import 'package:sportsync/features/profile/screens/profile_screen.dart';
import 'package:sportsync/features/shell/main_scaffold.dart';

/// Single [GoRouter] for the app.
/// Bottom tabs use [StatefulShellRoute] (Home / Bookings / Profile).
/// Court detail + booking flow are pushed inside the Home branch so they
/// inherit the back-stack of the tab the user came from.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/home'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          // Home tab (with nested court detail + booking flow).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'courts/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final court = sampleCourts.firstWhere((c) => c.id == id,
                          orElse: () => sampleCourts.first);
                      return CourtDetailScreen(court: court);
                    },
                    routes: [
                      GoRoute(
                        path: 'book',
                        builder: (context, state) => const BookingScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Bookings tab.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MyBookingsScreen(),
                ),
              ),
            ],
          ),
          // Profile tab (with nested Edit + About).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
