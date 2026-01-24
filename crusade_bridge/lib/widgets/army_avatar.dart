import 'dart:io';

import 'package:flutter/material.dart';

class ArmyAvatar extends StatelessWidget {
  final String? customPath;
  final String? factionAsset;
  final double radius;

  const ArmyAvatar({
    super.key,
    this.customPath,
    this.factionAsset,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (customPath != null && File(customPath!).existsSync()) {
      imageProvider = FileImage(File(customPath!));
    } else if (factionAsset != null) {
      imageProvider = AssetImage(factionAsset!);
    } else {
      imageProvider = const AssetImage('assets/icons/default_army.png');
    }

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CircleAvatar(
        radius: radius + 4,
        backgroundColor: Colors.pinkAccent.withOpacity(0.3),
        child: CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
          onBackgroundImageError: (exception, stackTrace) {
            debugPrint('Avatar load error: $exception');
          },
        ),
      ),
    );
  }
}  