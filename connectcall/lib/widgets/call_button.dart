import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

/// Circular call-control button (mute / speaker / camera / switch / end)
/// with an optional caption underneath, matching the assignment mockups.
class CallButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final Color color;
  final Color iconColor;
  final bool active;

  const CallButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.color = AppColors.controlInactive,
    this.iconColor = Colors.white,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: active ? AppColors.controlActive : color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Container(
              width: AppSizes.callControlButton,
              height: AppSizes.callControlButton,
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(label!, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ],
    );
  }
}