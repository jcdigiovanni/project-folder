import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';
import 'screens/landing_screen.dart';
import 'screens/new_crusade_screen.dart';
import 'screens/crusade_dashboard_screen.dart';
import 'screens/oob_modify_screen.dart';
import 'screens/requisition_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/roster_list_screen.dart';
import 'screens/roster_view_screen.dart';
import 'screens/roster_build_screen.dart';
import 'screens/play_screen.dart';
import 'screens/campaign_list_screen.dart';
import 'screens/campaign_view_screen.dart';
import 'services/storage_service.dart';
import 'services/google_drive_service.dart';
import 'services/reference_data_service.dart';
import 'providers/crusade_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await GoogleDriveService.init();
  await ReferenceDataService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize current Crusade after ProviderScope is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final all = StorageService.loadAllCrusades();
      if (all.isNotEmpty) {
        ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(all.first);
      }
    });
  }

  static final GoRouter _router = GoRouter(
    initialLocation: '/landing',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/landing',
            builder: (context, state) => const LandingScreen(),
          ),
          GoRoute(
            path: '/new-crusade',
            builder: (context, state) => const NewCrusadeScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const CrusadeDashboardScreen(),
          ),
          GoRoute(
            path: '/oob',
            builder: (context, state) => const OOBModifyScreen(),
          ),
          GoRoute(
            path: '/requisition',
            builder: (context, state) => const RequisitionScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/rosters',
            builder: (context, state) => const RosterListScreen(),
          ),
          GoRoute(
            path: '/roster/:rosterId',
            builder: (context, state) => RosterViewScreen(
              rosterId: state.pathParameters['rosterId']!,
            ),
          ),
          GoRoute(
            path: '/roster/:rosterId/edit',
            builder: (context, state) => RosterBuildScreen(
              rosterId: state.pathParameters['rosterId']!,
            ),
          ),
          GoRoute(
            path: '/play',
            builder: (context, state) => const PlayScreen(),
          ),
          GoRoute(
            path: '/campaigns',
            builder: (context, state) => const CampaignListScreen(),
          ),
          GoRoute(
            path: '/campaign/:campaignId',
            builder: (context, state) => CampaignViewScreen(
              campaignId: state.pathParameters['campaignId']!,
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '40K Crusade Bridge',
      theme: darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// New widget for bottom nav + back button support
class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);
    return Scaffold(
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // Dark red ribbon background
          canvasColor: const Color(0xFF8B0000), // Dark red base
          // Selected item background/underline
          splashColor: Colors.black.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.2),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Keeps all items visible
          backgroundColor: const Color(0xFF8B0000), // Explicit dark red
          selectedItemColor: Colors.white, // White for selected
          unselectedItemColor: Colors.white70, // Slightly dim for unselected
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          items: currentCrusade != null
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.play_arrow),
                    label: 'Play',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.exit_to_app),
                    label: 'Exit',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.folder_open),
                    label: 'Load',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.exit_to_app),
                    label: 'Exit',
                  ),
                ],
          currentIndex: _calculateSelectedIndex(context, currentCrusade != null),
          onTap: (index) => _onItemTapped(context, index, currentCrusade),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context, bool hasCrusade) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/landing')) return 0;
    if (location.startsWith('/dashboard')) return 1;
    if (location.startsWith('/oob')) return 1;
    if (location.startsWith('/play')) return hasCrusade ? 2 : 0;
    // Settings is index 3 with crusade, index 2 without
    if (location.startsWith('/settings')) return hasCrusade ? 3 : 2;
    return 0; // Default to home
  }

  void _onItemTapped(BuildContext context, int index, dynamic currentCrusade) {
    final hasCrusade = currentCrusade != null;

    // With crusade: Home(0), Dashboard(1), Play(2), Settings(3), Exit(4)
    // Without crusade: Home(0), Load(1), Settings(2), Exit(3)

    if (index == 0) {
      context.go('/landing');
      return;
    }

    if (index == 1) {
      if (hasCrusade) {
        context.go('/dashboard');
      } else {
        // Show load dialog
        _showLoadCrusadeDialog(context);
      }
      return;
    }

    if (hasCrusade) {
      // With crusade loaded
      switch (index) {
        case 2:
          context.go('/play');
          break;
        case 3:
          context.go('/settings');
          break;
        case 4:
          _showExitConfirmation(context);
          break;
      }
    } else {
      // Without crusade loaded
      switch (index) {
        case 2:
          context.go('/settings');
          break;
        case 3:
          _showExitConfirmation(context);
          break;
      }
    }
  }

  void _showLoadCrusadeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final savedCrusades = StorageService.loadAllCrusades();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Load Crusade',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (savedCrusades.isEmpty)
                const Text('No saved Crusades yet.'),
              if (savedCrusades.isNotEmpty)
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) => ListView.builder(
                      shrinkWrap: true,
                      itemCount: savedCrusades.length,
                      itemBuilder: (context, idx) {
                        final crusade = savedCrusades[idx];
                        return ListTile(
                          title: Text(crusade.name),
                          subtitle: Text('${crusade.faction} - ${crusade.detachment}'),
                          onTap: () {
                            ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
                            Navigator.pop(context);
                            context.go('/dashboard');
                          },
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit Crusade Bridge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}