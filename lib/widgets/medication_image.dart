import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MedicationImage extends StatefulWidget {
  final Function(String) onImageSelected;
  final String? initialImagePath;

  const MedicationImage({
    super.key,
    required this.onImageSelected,
    this.initialImagePath,
  });

  @override
  State<MedicationImage> createState() {
    return _MedicationImageState();
  }
}

class _MedicationImageState extends State<MedicationImage> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _selectedImage = File(widget.initialImagePath!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final pickedImage = await imagePicker.pickImage(source: source, maxWidth: 600);

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });

        widget.onImageSelected(pickedImage.path);
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text('Take Picture'),
      onPressed: _showImageSourceSelection,
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _showImageSourceSelection,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      child: _isLoading
          ? const CircularProgressIndicator() // Show loading indicator
          : content,
    );
  }
}