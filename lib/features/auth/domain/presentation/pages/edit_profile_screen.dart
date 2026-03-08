import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/profile_provider.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  
  File? _avatarFile;
  File? _coverFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _websiteController = TextEditingController(text: user?.website ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAvatar) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isAvatar) {
          _avatarFile = File(pickedFile.path);
        } else {
          _coverFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    try {
      final userProvider = context.read<UserProvider>();
      
      // Update basic details
      final success = await userProvider.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        website: _websiteController.text.trim(),
      );

      if (success) {
        // Upload images if any
        if (_avatarFile != null) {
          await userProvider.uploadAvatar(_avatarFile!);
        }
        if (_coverFile != null) {
          await userProvider.uploadCover(_coverFile!);
        }
        
        if (mounted) {
          // Refresh profile provider to reflect changes immediately
          final profileProv = context.read<ProfileProvider>();
          final currentUser = userProvider.user;
          if (currentUser != null) {
             profileProv.loadProfile(currentUser.username);
          }
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Photo
            GestureDetector(
              onTap: () => _pickImage(false),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: _coverFile != null
                      ? DecorationImage(image: FileImage(_coverFile!), fit: BoxFit.cover)
                      : (user?.coverImage != null
                          ? DecorationImage(
                              image: NetworkImage(MediaUtils.resolveImageUrl(user!.coverImage!)),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  ),
                ),
              ),
            ),
            
            // Avatar
            Transform.translate(
              offset: const Offset(0, -40),
              child: GestureDetector(
                onTap: () => _pickImage(true),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff15202b) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _avatarFile != null
                            ? Image.file(_avatarFile!,
                                width: 100, height: 100, fit: BoxFit.cover)
                            : (user?.image != null
                                ? CustomImage(
                                    imageUrl: MediaUtils.resolveImageUrl(user!.image!),
                                    width: 100,
                                    height: 100,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.person, size: 50),
                                  )),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      radius: 50,
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildTextField('Name', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField('Bio', _bioController, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Location', _locationController),
                  const SizedBox(height: 16),
                  _buildTextField('Website', _websiteController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
