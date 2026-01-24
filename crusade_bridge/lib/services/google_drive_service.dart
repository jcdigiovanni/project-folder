import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../models/crusade_models.dart';
import 'storage_service.dart';

/// Service for Google Drive backup/restore operations
class GoogleDriveService {
  static late final GoogleSignIn _googleSignIn;
  static bool _isSupported = false;

  static GoogleSignInAccount? _currentUser;
  static drive.DriveApi? _driveApi;

  /// Get current signed-in user
  static GoogleSignInAccount? get currentUser => _currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => _currentUser != null;

  /// Check if platform supports Google Sign-In
  static bool get isSupported => _isSupported;

  /// Initialize Google Sign-In
  static Future<void> init() async {
    // Google Sign-In is only supported on Android, iOS, and Web
    _isSupported = kIsWeb || (Platform.isAndroid || Platform.isIOS);
    
    if (!_isSupported) {
      print('Google Sign-In is not supported on this platform');
      return;
    }

    _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );

    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
    });

    // Try to sign in silently on app start
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      print('Silent sign-in failed: $e');
    }
  }

  /// Sign in to Google account
  static Future<GoogleSignInAccount?> signIn() async {
    if (!_isSupported) {
      print('Google Sign-In is not supported on this platform');
      return null;
    }

    try {
      final account = await _googleSignIn.signIn();
      _currentUser = account;

      if (account != null) {
        final authHeaders = await account.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _driveApi = drive.DriveApi(authenticateClient);
      }

      return account;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  /// Sign out from Google account
  static Future<void> signOut() async {
    if (!_isSupported) {
      return;
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
    _currentUser = null;
    _driveApi = null;
  }

  /// Backup all crusades to Google Drive
  static Future<bool> backupCrusades() async {
    if (!_isSupported) {
      print('Google Drive backup is not supported on this platform');
      return false;
    }

    if (_driveApi == null || _currentUser == null) {
      return false;
    }

    try {
      final crusades = StorageService.loadAllCrusades();
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'crusades': crusades.map((c) => c.toJson()).toList(),
      };

      final jsonContent = jsonEncode(backupData);
      final fileName = 'crusade_bridge_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      // Create file metadata
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/json';

      // Upload file
      final media = drive.Media(
        Stream.value(utf8.encode(jsonContent)),
        jsonContent.length,
      );

      await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      return true;
    } catch (e) {
      print('Error backing up crusades: $e');
      return false;
    }
  }

  /// Upload a single crusade to Google Drive
  static Future<bool> uploadCrusade(Crusade crusade) async {
    if (!_isSupported) {
      print('Google Drive upload is not supported on this platform');
      return false;
    }

    if (_driveApi == null || _currentUser == null) {
      return false;
    }

    try {
      // Use the same format as backupCrusades for consistency
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'crusades': [crusade.toJson()],  // Wrap single crusade in array
      };
      final jsonContent = jsonEncode(backupData);
      // Use consistent naming with backup files so retrieval works
      final fileName = 'crusade_bridge_backup_${crusade.id}.json';

      // Create file metadata
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/json';

      // Check if file already exists
      final existingFiles = await _driveApi!.files.list(
        q: "name='$fileName' and mimeType='application/json'",
        spaces: 'drive',
      );

      final media = drive.Media(
        Stream.value(utf8.encode(jsonContent)),
        jsonContent.length,
      );

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        // Update existing file
        await _driveApi!.files.update(
          driveFile,
          existingFiles.files!.first.id!,
          uploadMedia: media,
        );
      } else {
        // Create new file
        await _driveApi!.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      return true;
    } catch (e) {
      print('Error uploading crusade: $e');
      return false;
    }
  }

  /// Get list of backup files from Google Drive
  static Future<List<drive.File>> getBackupFiles() async {
    if (_driveApi == null || _currentUser == null) {
      return [];
    }

    try {
      final fileList = await _driveApi!.files.list(
        q: "name contains 'crusade_bridge_backup' and mimeType='application/json'",
        orderBy: 'modifiedTime desc',
        spaces: 'drive',
      );

      return fileList.files ?? [];
    } catch (e) {
      print('Error fetching backup files: $e');
      return [];
    }
  }

  /// Download a crusade file from Google Drive
  static Future<Map<String, dynamic>?> downloadCrusade(String fileId) async {
    if (_driveApi == null || _currentUser == null) {
      return null;
    }

    try {
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final dataStream = media.stream;
      final chunks = <List<int>>[];
      await for (var chunk in dataStream) {
        chunks.add(chunk);
      }
      final bytes = chunks.expand((chunk) => chunk).toList();

      final jsonString = utf8.decode(bytes);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error downloading crusade: $e');
      return null;
    }
  }

  /// Restore crusades from a specific backup file
  static Future<bool> restoreFromBackup(String fileId) async {
    if (_driveApi == null || _currentUser == null) {
      return false;
    }

    try {
      // Download file content
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Collect bytes from stream
      final dataStream = media.stream;
      final chunks = <List<int>>[];
      await for (var chunk in dataStream) {
        chunks.add(chunk);
      }
      final bytes = chunks.expand((chunk) => chunk).toList();

      final jsonString = utf8.decode(bytes);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      List<Crusade> crusades;

      // Check if this is the new format with 'crusades' array wrapper
      if (backupData.containsKey('crusades')) {
        // New format: { "version": "1.0", "timestamp": "...", "crusades": [...] }
        final crusadesJson = backupData['crusades'] as List<dynamic>?;

        if (crusadesJson == null || crusadesJson.isEmpty) {
          print('No crusades found in backup file');
          return false;
        }

        crusades = crusadesJson
            .map((json) => Crusade.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Legacy format: bare crusade object
        // Try to parse the entire backup data as a single crusade
        try {
          final crusade = Crusade.fromJson(backupData);
          crusades = [crusade];
          print('Restored legacy format backup (single crusade)');
        } catch (e) {
          print('Failed to parse backup as legacy format: $e');
          return false;
        }
      }

      // Save each crusade
      for (final crusade in crusades) {
        StorageService.saveCrusade(crusade);
      }

      return true;
    } catch (e) {
      print('Error restoring from backup: $e');
      return false;
    }
  }

  /// Delete a backup file from Google Drive
  static Future<bool> deleteBackup(String fileId) async {
    if (_driveApi == null || _currentUser == null) {
      return false;
    }

    try {
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      print('Error deleting backup: $e');
      return false;
    }
  }
}

/// HTTP client for Google Drive authentication
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
