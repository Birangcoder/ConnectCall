import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/presence_service.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/common_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await PresenceService.instance.stopPresence();
      // Logout from ZEGOCLOUD first.
      await ref.read(callingServiceProvider).logout();

      // Logout from Firebase Auth.
      await ref.read(authServiceProvider).logout();

      if (!context.mounted) return;

      context.go('/login');
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  // ---------------------------------------------------------------------------
  // EDIT PROFILE
  // ---------------------------------------------------------------------------

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String currentName,
    String? currentPhoto,
  ) async {
    final nameController = TextEditingController(text: currentName);

    XFile? selectedImage;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isUploading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profile'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---------------------------------------------------------
                    // PROFILE IMAGE
                    // ---------------------------------------------------------
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: selectedImage != null
                          ? FileImage(File(selectedImage!.path))
                          : (currentPhoto != null && currentPhoto.isNotEmpty
                                ? NetworkImage(currentPhoto)
                                : null),
                      child:
                          selectedImage == null &&
                              (currentPhoto == null || currentPhoto.isEmpty)
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),

                    const SizedBox(height: AppSizes.sm),

                    // ---------------------------------------------------------
                    // CHANGE PHOTO
                    // ---------------------------------------------------------
                    TextButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              try {
                                final picker = ImagePicker();

                                final image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
                                  maxWidth: 1000,
                                  maxHeight: 1000,
                                );

                                if (image == null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedImage = image;
                                });
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not select image: $e'),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Change Photo'),
                    ),

                    const SizedBox(height: AppSizes.sm),

                    // ---------------------------------------------------------
                    // DISPLAY NAME
                    // ---------------------------------------------------------
                    TextField(
                      controller: nameController,
                      enabled: !isUploading,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),

                    if (isUploading) ...[
                      const SizedBox(height: AppSizes.md),

                      const LinearProgressIndicator(),

                      const SizedBox(height: AppSizes.xs),

                      const Text('Uploading profile photo...'),
                    ],
                  ],
                ),
              ),

              actions: [
                // -------------------------------------------------------------
                // CANCEL
                // -------------------------------------------------------------
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () {
                          Navigator.pop(dialogContext, false);
                        },
                  child: const Text('Cancel'),
                ),

                // -------------------------------------------------------------
                // SAVE
                // -------------------------------------------------------------
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          final name = nameController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Display name cannot be empty.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isUploading = true;
                          });

                          try {
                            String? photoUrl = currentPhoto;

                            // -------------------------------------------------
                            // UPLOAD NEW IMAGE
                            // -------------------------------------------------

                            if (selectedImage != null) {
                              photoUrl = await CloudinaryService.instance
                                  .uploadProfileImage(selectedImage!);
                            }

                            // -------------------------------------------------
                            // UPDATE FIRESTORE
                            // -------------------------------------------------

                            await ref
                                .read(userServiceProvider)
                                .updateProfile(
                                  uid: uid,
                                  name: name,
                                  photoUrl: photoUrl,
                                );

                            // -------------------------------------------------
                            // UPDATE FIREBASE AUTH DISPLAY NAME
                            // -------------------------------------------------

                            await FirebaseAuth.instance.currentUser
                                ?.updateDisplayName(name);

                            if (!context.mounted) return;

                            Navigator.pop(dialogContext, true);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully.'),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isUploading = false;
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update profile: $e'),
                              ),
                            );
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    // Dispose controller after dialog closes.
    nameController.dispose();

    // Refresh profile after successful update.
    if (result == true) {
      ref.invalidate(userProfileProvider);
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),

      body: profile.when(
        // ---------------------------------------------------------------------
        // LOADING
        // ---------------------------------------------------------------------
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        // ---------------------------------------------------------------------
        // ERROR
        // ---------------------------------------------------------------------
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),

                  const SizedBox(height: AppSizes.md),

                  Text(
                    'Could not load profile.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.xs),

                  Text('$error', textAlign: TextAlign.center),

                  const SizedBox(height: AppSizes.md),

                  FilledButton(
                    onPressed: () {
                      ref.invalidate(userProfileProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },

        // ---------------------------------------------------------------------
        // DATA
        // ---------------------------------------------------------------------
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Profile not found'));
          }

          final presence = ref.watch(presenceProvider(user!.id));
          final isOnline = presence.when(
            loading: () => false,
            error: (_, __) => false,
            data: (value) => value.isOnline,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.lg),

                  // -----------------------------------------------------------
                  // PROFILE AVATAR
                  // -----------------------------------------------------------
                  AppAvatar(
                    name: user.name,
                    photoUrl: user.photoUrl,
                    radius: AppSizes.avatarXl / 2,
                  ),

                  const SizedBox(height: AppSizes.md),

                  // -----------------------------------------------------------
                  // NAME
                  // -----------------------------------------------------------
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.xs),

                  // -----------------------------------------------------------
                  // EMAIL
                  // -----------------------------------------------------------
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.xs),

                  // -----------------------------------------------------------
                  // ONLINE STATUS
                  // -----------------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: isOnline ? AppColors.online : AppColors.offline,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isOnline
                              ? AppColors.online
                              : AppColors.offline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // -----------------------------------------------------------
                  // EDIT PROFILE
                  // -----------------------------------------------------------
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit Profile'),
                    onTap: () => _editProfile(
                      context,
                      ref,
                      user.id,
                      user.name,
                      user.photoUrl,
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // -----------------------------------------------------------
                  // LOGOUT
                  // -----------------------------------------------------------
                  CommonButton(
                    text: 'Logout',
                    backgroundColor: AppColors.error,
                    onPressed: () => _logout(context, ref),
                  ),

                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
