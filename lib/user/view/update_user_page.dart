import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:m3t_attendee/user/user_cubit.dart';

String? _resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return url;
  if (defaultTargetPlatform == TargetPlatform.android &&
      url.contains('localhost')) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }
  return url;
}

String _userInitials(AuthUser? user) {
  if (user == null) return '?';
  final name = user.name?.trim();
  final lastName = user.lastName?.trim();
  if (name != null &&
      name.isNotEmpty &&
      lastName != null &&
      lastName.isNotEmpty) {
    return '${name[0]}${lastName[0]}'.toUpperCase();
  }
  if (name != null && name.isNotEmpty) {
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase();
  }
  final email = user.email.trim();
  if (email.isNotEmpty) {
    final part = email.split('@').first;
    return part.length >= 2
        ? part.substring(0, 2).toUpperCase()
        : part[0].toUpperCase();
  }
  return '?';
}

final class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

final class _UpdateUserPageState extends State<UpdateUserPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserCubit>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    final userCubit = context.read<UserCubit>();
    await userCubit.updateProfile(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
    );

    final state = userCubit.state;
    if (!mounted) return;
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _showImageSourceBottomSheet() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImageAndUpload(ImageSource.gallery));
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImageAndUpload(ImageSource.camera));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageAndUpload(ImageSource source) async {
    final userCubit = context.read<UserCubit>();
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read image. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final path = picked.name.toLowerCase();
      final contentType = source == ImageSource.camera
          ? 'image/jpeg'
          : (path.endsWith('.png') ? 'image/png' : 'image/jpeg');

      await userCubit.updateAvatar(bytes: bytes, contentType: contentType);

      final state = userCubit.state;
      if (mounted && state.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isChannelError = e.code == 'channel-error';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isChannelError
                  ? 'Photo picker unavailable on emulator. '
                      'Stop app and do a full restart, or try on device.'
                  : 'Could not open photo picker: ${e.message ?? e.code}',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Could not open photo picker: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update profile')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          final user = state.user;
          final theme = Theme.of(context);
          final initials = _userInitials(user);
          final profilePictureUrl = user?.profilePictureUrl;

          Widget avatar;
          if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
            avatar = CircleAvatar(
              radius: 64,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: ClipOval(
                child: Image.network(
                  _resolveImageUrl(profilePictureUrl)!,
                  width: 128,
                  height: 128,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        initials,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            avatar = CircleAvatar(
              radius: 64,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initials,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: state.updatingAvatar
                          ? () {}
                          : _showImageSourceBottomSheet,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          avatar,
                          if (state.updatingAvatar)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: theme.colorScheme.onPrimaryContainer,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: TextEditingController(
                          text: user?.email ?? '',
                        ),
                        decoration: const InputDecoration(labelText: 'Email'),
                        enabled: false,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.updatingProfile
                            ? null
                            : _onSavePressed,
                        child: state.updatingProfile
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
