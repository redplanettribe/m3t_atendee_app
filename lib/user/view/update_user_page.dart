import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:m3t_attendee/user/bloc/user_cubit.dart';
import 'package:m3t_attendee/user/view/user_avatar.dart';

final class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

final class _UpdateUserPageState extends State<UpdateUserPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserCubit>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fire-and-forget: BlocListener handles the result reactively.
  void _onSavePressed() {
    unawaited(
      context.read<UserCubit>().updateProfile(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: .min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImageAndUpload(.gallery));
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImageAndUpload(.camera));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageAndUpload(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        if (!mounted) return;
        _showSnackBar('Could not read image. Please try again.');
        return;
      }

      final path = picked.name.toLowerCase();
      final contentType = source == .camera
          ? 'image/jpeg'
          : (path.endsWith('.png') ? 'image/png' : 'image/jpeg');

      if (!mounted) return;
      // Fire-and-forget: BlocListener handles avatar-update result.
      unawaited(
        context.read<UserCubit>().updateAvatar(
          bytes: bytes,
          contentType: contentType,
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isChannelError = e.code == 'channel-error';
      _showSnackBar(
        isChannelError
            ? 'Photo picker unavailable on emulator. '
                  'Stop app and do a full restart, or try on device.'
            : 'Could not open photo picker: ${e.message ?? e.code}',
        duration: const Duration(seconds: 5),
      );
    } on Object catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not open photo picker: $e');
    }
  }

  void _showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: .floating,
          duration: duration ?? const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Profile save completed — show success or error.
        BlocListener<UserCubit, UserState>(
          listenWhen: (previous, current) =>
              previous.updatingProfile && !current.updatingProfile,
          listener: (context, state) {
            if (state.errorMessage != null) {
              _showSnackBar(state.errorMessage!);
            } else {
              _showSnackBar('Profile updated');
            }
          },
        ),
        // Avatar upload completed — show error only (success is visual).
        BlocListener<UserCubit, UserState>(
          listenWhen: (previous, current) =>
              previous.updatingAvatar && !current.updatingAvatar,
          listener: (context, state) {
            if (state.errorMessage != null) {
              _showSnackBar(state.errorMessage!);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Update profile')),
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final theme = Theme.of(context);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      GestureDetector(
                        onTap: state.updatingAvatar
                            ? null
                            : _showImageSourceBottomSheet,
                        child: Stack(
                          alignment: .bottomRight,
                          children: [
                            UserAvatar(user: state.user, radius: 64),
                            if (state.updatingAvatar)
                              const Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    shape: .circle,
                                  ),
                                  child: Center(
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
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                        ),
                        textCapitalization: .words,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                        ),
                        textCapitalization: .words,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        enabled: false,
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
      ),
    );
  }
}
