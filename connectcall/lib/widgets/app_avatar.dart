import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Circle avatar that falls back to the user's initials when no
/// profile photo is available.
class AppAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;

  const AppAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.12),
      backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
          ? NetworkImage(photoUrl!)
          : null,
      child: (photoUrl == null || photoUrl!.isEmpty)
          ? Text(
              name.isEmpty ? '?' : name.trim()[0].toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}
