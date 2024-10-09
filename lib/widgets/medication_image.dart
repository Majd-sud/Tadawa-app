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

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _selectedImage = File(widget.initialImagePath!); 
    }
  }

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onImageSelected(pickedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera_alt_outlined),
      label: const Text('Take Picture'),
      onPressed: _takePicture,
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
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
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
