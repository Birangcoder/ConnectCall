import 'package:flutter/material.dart';

import '../services/update_service.dart';
import '../widgets/update_dialog.dart';

class UpdateChecker {
  static Future<void> check(BuildContext context) async {
    try {
      final service = UpdateService();

      final update = await service.checkForUpdate();

      if (update == null) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      final mandatory = await service.isMandatoryUpdate(update);

      if (!context.mounted) {
        return;
      }

      await showUpdateDialog(context, update, mandatory);
    } catch (e) {
      debugPrint('Update checker error: $e');
    }
  }
}
