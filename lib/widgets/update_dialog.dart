import 'package:flutter/material.dart';

import '../models/update_info.dart';
import '../services/update_service.dart';

Future<void> showUpdateDialog(
  BuildContext context,
  UpdateInfo updateInfo,
  bool mandatory,
) async {
  double progress = 0;
  bool downloading = false;

  await showDialog(
    context: context,
    barrierDismissible: !mandatory,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return PopScope(
            canPop: !mandatory && !downloading,
            child: AlertDialog(
              title: Text(mandatory ? 'Update Required' : 'Update Available'),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version '
                    '${updateInfo.latestVersion}'
                    ' is available.',
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'What\'s new:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  if (updateInfo.releaseNotes.isEmpty)
                    const Text('Bug fixes and improvements.'),

                  ...updateInfo.releaseNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('• $note'),
                    ),
                  ),

                  if (downloading) ...[
                    const SizedBox(height: 20),

                    LinearProgressIndicator(value: progress),

                    const SizedBox(height: 8),

                    Text('${(progress * 100).toStringAsFixed(0)}%'),
                  ],
                ],
              ),

              actions: [
                if (!mandatory && !downloading)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Later'),
                  ),

                ElevatedButton(
                  onPressed: downloading
                      ? null
                      : () async {
                          setState(() {
                            downloading = true;
                            progress = 0;
                          });

                          try {
                            await UpdateService().downloadAndInstall(
                              updateInfo.apkUrl,
                              onProgress: (value) {
                                setState(() {
                                  progress = value;
                                });
                              },
                            );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            setState(() {
                              downloading = false;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Update failed: $e')),
                              );
                            }
                          }
                        },
                  child: Text(downloading ? 'Downloading...' : 'Update Now'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
