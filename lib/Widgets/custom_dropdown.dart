// reusable_widgets.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String label;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class ImagePickerButton extends StatelessWidget {
  final void Function() onPressed;

  const ImagePickerButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.collections),
      label: const Text(
        'Pick Images',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final bool isUploading;
  final void Function() onPressed;
  final String label;

  const UploadButton({
    super.key,
    required this.isUploading,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return isUploading
        ? const CircularProgressIndicator()
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.upload),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            label: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          );
  }
}

class ImagePreview extends StatelessWidget {
  final List<PlatformFile> files;

  const ImagePreview({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: files.map((file) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(file.bytes!),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        );
      }).toList(),
    );
  }
}
