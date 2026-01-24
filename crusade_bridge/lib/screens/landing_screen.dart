import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../services/storage_service.dart';
import '../widgets/army_avatar.dart';
import '../utils/drive_restore_helper.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> with WidgetsBindingObserver {
  List<Crusade> _savedCrusades = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCrusades();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh crusades when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadCrusades();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadCrusades() {
    setState(() {
      _savedCrusades = StorageService.loadAllCrusades();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(  // ← No Scaffold here - parent handles it
      children: [
        // Recent Crusades section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Crusades',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loadCrusades,
              ),
            ],
          ),
        ),
        Expanded(
          child: _savedCrusades.isEmpty
              ? const Center(
                  child: Text(
                    'No Crusades saved yet.\nCreate one to get started!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _savedCrusades.length,
                  itemBuilder: (context, index) {
                    final crusade = _savedCrusades[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: ArmyAvatar(
                          factionAsset: crusade.factionIconAsset,
                          customPath: crusade.armyIconPath,
                          radius: 24,
                        ),
                        title: Text(crusade.name),
                        subtitle: Text(
                          '${crusade.faction} - ${crusade.detachment}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        trailing: Text(
                          '${crusade.totalOobPoints}/${crusade.supplyLimit} pts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: crusade.remainingPoints < 0 ? Colors.red : null,
                          ),
                        ),
                        onTap: () {
                          ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
                          context.go('/dashboard');
                        },
                      ),
                    );
                  },
                ),
        ),
        // Main action buttons (bottom section)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  context.go('/new-crusade');
                },
                child: const Text('New Crusade'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
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
                              'Saved Crusades',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (savedCrusades.isEmpty)
                              const Text('No saved Crusades yet.'),
                            if (savedCrusades.isNotEmpty)
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: savedCrusades.length,
                                  itemBuilder: (context, index) {
                                    final crusade = savedCrusades[index];
                                    return ListTile(
                                      leading: ArmyAvatar(
                                        factionAsset: crusade.factionIconAsset,
                                        customPath: crusade.armyIconPath,
                                        radius: 24,
                                      ),
                                      title: Text(crusade.name),
                                      subtitle: Text(
                                        '${crusade.faction} - ${crusade.detachment}',
                                        style: Theme.of(context).textTheme.labelLarge,
                                      ),
                                      trailing: Text(
                                        '${crusade.totalOobPoints}/${crusade.supplyLimit} pts',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: crusade.remainingPoints < 0 ? Colors.red : null,
                                        ),
                                      ),
                                      onTap: () {
                                        ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
                                        Navigator.pop(context); // Close bottom sheet
                                        context.go('/dashboard');
                                      },
                                    );
                                  },
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
                },
                child: const Text('Load Crusade'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => DriveRestoreHelper.showRestoreDialog(
                  context: context,
                  ref: ref,
                  useBottomSheet: false,
                  onRestoreComplete: _loadCrusades,
                ),
                child: const Text('Restore from Drive'),
              ),
              const SizedBox(height: 8),
              // Add your other buttons here (Build/Modify OOB, etc.) with SizedBox(height: 8)
            ],
          ),
        ),
      ],
    );
  }

}