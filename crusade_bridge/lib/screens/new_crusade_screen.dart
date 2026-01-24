import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../models/crusade_models.dart';
import '../services/storage_service.dart';
import '../services/reference_data_service.dart';
import '../providers/crusade_provider.dart';
import '../utils/snackbar_utils.dart';

class NewCrusadeScreen extends ConsumerStatefulWidget {
  const NewCrusadeScreen({super.key});

  @override
  ConsumerState<NewCrusadeScreen> createState() => _NewCrusadeScreenState();
}

class _NewCrusadeScreenState extends ConsumerState<NewCrusadeScreen> {
  final _nameController = TextEditingController();
  String? _faction;
  String? _detachment;
  bool _isCustomDetachment = false;
  final _customDetachmentController = TextEditingController();
  String? _armyIconPath;

  @override
  void initState() {
    super.initState();
    // Clear any currently loaded crusade when starting new crusade creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentCrusadeNotifierProvider.notifier).clearCurrent();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customDetachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Crusade'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox.expand(  // Forces full screen size
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Crusade Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _faction,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Faction',
                          border: OutlineInputBorder(),
                        ),
                        items: ReferenceDataService.getFactions().map((faction) {
                          return DropdownMenuItem<String>(
                            value: faction,
                            child: Text(faction),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _faction = value;
                            _detachment = null;
                            _isCustomDetachment = false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _detachment,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Detachment',
                          border: OutlineInputBorder(),
                        ),
                        items: (_faction != null
                                ? ReferenceDataService.getDetachments(_faction!)
                                : <String>[])
                            .map((det) => DropdownMenuItem<String>(
                                  value: det,
                                  child: Text(det),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _detachment = value;
                            _isCustomDetachment = value == 'Custom';
                          });
                        },
                      ),
                      if (_isCustomDetachment) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _customDetachmentController,
                          decoration: const InputDecoration(
                            labelText: 'Custom Detachment Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Temporarily comment out avatar row to isolate
                      // Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     ArmyAvatar(
                      //       factionAsset: _faction != null
                      //           ? ReferenceDataService.getFactionIcon(_faction!)
                      //           : null,
                      //       customPath: _armyIconPath,
                      //     ),
                      //     const SizedBox(width: 16),
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(content: Text('Change Icon tapped – coming soon')),
                      //         );
                      //       },
                      //       child: const Text('Change Icon'),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.trim().isEmpty ||
                                _faction == null ||
                                (_detachment == null && !_isCustomDetachment) ||
                                (_isCustomDetachment && _customDetachmentController.text.trim().isEmpty)) {
                              SnackBarUtils.showError(context, 'Please fill all required fields');
                              return;
                            }
                            // Determine detachment name first
                            final detachmentName = _isCustomDetachment
                                ? _customDetachmentController.text.trim()
                                : _detachment!;

                            // Create the Crusade object
                            final newCrusade = Crusade(
                              id: const Uuid().v4(),
                              name: _nameController.text.trim(),
                              faction: _faction!,
                              detachment: detachmentName,
                              supplyLimit: 1000,
                              rp: 5,
                              armyIconPath: _armyIconPath,
                              factionIconAsset: ReferenceDataService.getFactionIcon(_faction!),
                            );

                            StorageService.saveCrusade(newCrusade);

                            // Set as current crusade in provider
                            ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(newCrusade);

                            context.go('/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          child: const Text('Create Crusade'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );  
  }
}