import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({
    super.key,
    required this.onPickImage,
    this.initialImageUrl, // Accepts an initial image URL
  });

  final void Function(File pickedImage) onPickImage;
  final String? initialImageUrl; // Stores the initial image URL

  @override
  State<ProfileImage> createState() {
    return _ProfileImageState();
  }
}

class _ProfileImageState extends State<ProfileImage> {
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    // Initialize the picked image file based on the initial image URL
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      _pickedImageFile = null; // Indicates that a default image should be shown
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show a dialog to choose image source
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source == null) return; // User canceled the dialog

    // Pick the image from the chosen source
    final pickedImage = await picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
      widget.onPickImage(_pickedImageFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile != null 
              ? FileImage(_pickedImageFile!)
              : widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
                  ? NetworkImage(widget.initialImageUrl!)
                  : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}