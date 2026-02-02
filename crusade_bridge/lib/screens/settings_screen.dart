import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/app_settings_provider.dart';
import '../providers/campaign_provider.dart';
import '../providers/crusade_provider.dart';
import '../services/google_drive_service.dart';
import '../services/storage_service.dart';
import '../utils/snackbar_utils.dart';
import '../utils/drive_restore_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = GoogleDriveService.currentUser;
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await GoogleDriveService.signIn();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });

      if (!mounted) return;

      if (user != null) {
        final settings = ref.read(appSettingsProvider);
        SnackBarUtils.showSuccess(
          context,
          'Signed in as ${user.email}',
          settings: settings,
        );
      } else {
        final settings = ref.read(appSettingsProvider);
        // Use the detailed error message from GoogleDriveService if available
        final errorMessage = GoogleDriveService.lastError ?? 'Sign-in failed';
        SnackBarUtils.showError(
          context,
          errorMessage,
          settings: settings,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      final settings = ref.read(appSettingsProvider);
      SnackBarUtils.showError(
        context,
        'Error signing in: $e',
        settings: settings,
      );
    }
  }

  Future<void> _handleSignOut() async {
    await GoogleDriveService.signOut();
    setState(() => _currentUser = null);

    if (!mounted) return;
    final settings = ref.read(appSettingsProvider);
    SnackBarUtils.showSuccess(
      context,
      'Signed out successfully',
      settings: settings,
    );
  }

  Future<void> _handleBackup() async {
    setState(() => _isLoading = true);
    try {
      final success = await GoogleDriveService.backupCrusades();
      setState(() => _isLoading = false);

      if (!mounted) return;
      final settings = ref.read(appSettingsProvider);

      if (success) {
        SnackBarUtils.showSuccess(
          context,
          'Backup completed successfully',
          settings: settings,
        );
      } else {
        SnackBarUtils.showError(
          context,
          'Backup failed',
          settings: settings,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      final settings = ref.read(appSettingsProvider);
      SnackBarUtils.showError(
        context,
        'Error creating backup: $e',
        settings: settings,
      );
    }
  }

  Future<void> _handleRestore() async {
    await DriveRestoreHelper.showRestoreDialog(
      context: context,
      ref: ref,
      useBottomSheet: true,
    );
  }

  Future<void> _clearLocalData() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will delete all locally stored crusades and campaigns. This action cannot be undone. Make sure you have backups on Google Drive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                // Clear all crusades from Hive
                await StorageService.crusadeBox.clear();

                // Clear all campaigns from Hive
                await StorageService.campaignBox.clear();

                // Reset the current crusade in the provider
                ref.read(currentCrusadeNotifierProvider.notifier).clearCurrent();

                // Clear campaigns from provider state (BUG-013/014 fix)
                ref.read(campaignsProvider.notifier).clear();

                setState(() => _isLoading = false);

                if (!mounted) return;
                final settings = ref.read(appSettingsProvider);
                SnackBarUtils.showSuccess(
                  context,
                  'Local data cleared successfully',
                  settings: settings,
                );

                // Navigate to landing page to ensure clean state
                if (mounted) {
                  context.go('/landing');
                }
              } catch (e) {
                setState(() => _isLoading = false);
                if (!mounted) return;
                final settings = ref.read(appSettingsProvider);
                SnackBarUtils.showError(
                  context,
                  'Error clearing data: $e',
                  settings: settings,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Defaults',
            onPressed: () {
              ref.read(appSettingsProvider.notifier).resetToDefaults();
              SnackBarUtils.showSuccess(
                context,
                'Settings reset to defaults',
                settings: settings,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SnackBar Settings Section
          const Text(
            'Notification Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Duration Slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notification Duration'),
                      Text(
                        '${settings.snackBarDurationSeconds}s',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.snackBarDurationSeconds.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '${settings.snackBarDurationSeconds}s',
                    onChanged: (value) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setSnackBarDuration(value.toInt());
                    },
                  ),
                  const Text(
                    'How long notifications stay on screen',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Show Icons Toggle
          Card(
            child: SwitchListTile(
              title: const Text('Show Icons'),
              subtitle: const Text('Display icons in notifications'),
              value: settings.snackBarShowIcon,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).updateSettings(
                      settings.copyWith(snackBarShowIcon: value),
                    );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Google Drive Sync Section
          const Text(
            'Cloud Backup',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_currentUser != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_circle, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser!.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _currentUser!.email,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleBackup,
                            icon: const Icon(Icons.backup),
                            label: const Text('Backup to Drive'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleRestore,
                            icon: const Icon(Icons.restore),
                            label: const Text('Restore from Drive'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _handleSignOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (_currentUser == null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (GoogleDriveService.isSupported) ...[
                      const Text(
                        'Sign in to Google Drive to backup and restore your crusades across devices.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleSignIn,
                          icon: const Icon(Icons.login),
                          label: const Text('Sign in with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          border: Border.all(color: Colors.orange[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Google Drive backup is not available on this platform. Use web or mobile to backup.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],

          const SizedBox(height: 24),

          // Local Data Management Section
          const Text(
            'Local Data',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clear all locally stored crusades and campaigns. This action cannot be undone.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearLocalData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear Local Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Test Buttons
          const Text(
            'Test Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              SnackBarUtils.showSuccess(
                context,
                'This is a success message!',
                settings: settings,
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Test Success'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: () {
              SnackBarUtils.showError(
                context,
                'This is an error message!',
                settings: settings,
              );
            },
            icon: const Icon(Icons.error),
            label: const Text('Test Error'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: () {
              SnackBarUtils.showMessage(
                context,
                'This is an info message!',
                settings: settings,
                icon: Icons.info,
              );
            },
            icon: const Icon(Icons.info),
            label: const Text('Test Info'),
          ),
        ],
      ),
    );
  }
}
