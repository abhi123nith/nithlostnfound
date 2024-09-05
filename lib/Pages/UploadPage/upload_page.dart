import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nithlostnfound/Pages/profile/user_profile_image.dart';

class UploadItemPage extends StatefulWidget {
  final bool isLostItem;
  const UploadItemPage({required this.isLostItem, super.key});

  @override
  _UploadItemPageState createState() => _UploadItemPageState();
}

class _UploadItemPageState extends State<UploadItemPage> {
  List<Uint8List>? _imageBytes;
  String _selectedLocation = 'Campus, NITH';
  String _selectedItemType = 'ID Card';
  String _description = '';
  String? _selectedSpecificLocation;
  bool _isLoading = false;
  bool _isSuccess = false;
  User user = FirebaseAuth.instance.currentUser!;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    String? profileImageUrl = await getUserProfileImage(user.uid);
    setState(() {
      profileImage = profileImageUrl;
    });
  }

  final List<String> _locations = [
    'Campus, NITH',
    'Boys Hostel',
    'Girls Hostel',
    'Department',
    'Library',
    'Computer Center',
    'Lecture Hall',
    'New LH',
    'Auditorium',
    'OAT',
    'Ground',
    'Central Gym',
    'SP',
    '4 H',
    'Verka',
    'Amul',
    'Admin Block',
    'Central Block',
    'Food Court',
    'Nescafe DBH',
    'GATE 1',
    'GATE 2',
    'Temple',
    'SAC',
  ];

  static const List<String> _boysHostels = [
    'KBH',
    'NBH',
    'DBH',
    'Himgiri',
    'Himadri',
    'UBH',
    'VBH'
  ];

  static const List<String> _girlsHostels = ['AGH', 'PGH', 'MMH', 'Satpura'];

  static const List<String> _departments = [
    'CSE',
    'ECE',
    'Mechanical',
    'Civil',
    'Electrical',
    'Chemical',
    'Material',
    'MNC',
    'Architecture',
    'EP',
  ];

  final List<String> _itemTypes = [
    'ID Card',
    'Book',
    'Mobile Phone',
    'Laptop',
    'Earbuds',
    'Mobile Charger',
    'Laptop Charger',
    'Specs',
    'Watch',
    'Jewelry',
    'Jackets/Coats',
    'Shoes',
    'Umbrella',
    'Keys',
    'Electronics Item',
    'Water bottle',
    'Cloth',
    'Other',
  ];

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        setState(() {
          _imageBytes = result.files.map((file) => file.bytes!).toList();
        });
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  Future<void> _submitData() async {
    if (!mounted) return;

    if (_description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required')),
      );
      return;
    }

    if (_selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }

    if ((_selectedLocation == 'Boys Hostel' ||
            _selectedLocation == 'Girls Hostel' ||
            _selectedLocation == 'Department') &&
        (_selectedSpecificLocation == null ||
            _selectedSpecificLocation!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_selectedLocation name is required')),
      );
      return;
    }

    if (_selectedItemType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item type is required')),
      );
      return;
    }

    if (_imageBytes == null || _imageBytes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }
    if (_selectedSpecificLocation == '') {
      _selectedSpecificLocation =
          "Not provided"; // or handle the absence of the value accordingly
    }

    setState(() {
      _isLoading = true;
      _isSuccess = false;
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final FirebaseStorage storage = FirebaseStorage.instance;
      User user = FirebaseAuth.instance.currentUser!;

      List<String> imageUrls = [];

      final uploadFutures = _imageBytes!.asMap().entries.map((entry) async {
        final index = entry.key;
        final imageByteData = entry.value;
        final fileName =
            'images/${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
        final ref = storage.ref().child(fileName);
        await ref.putData(imageByteData);
        return ref.getDownloadURL();
      });

      imageUrls = await Future.wait(uploadFutures);

      String username = user.email!.split('@')[0].toUpperCase();
      
      final locationString = _selectedLocation=='Campus, NITH'?_selectedLocation :
      _selectedSpecificLocation != null && _selectedSpecificLocation!.isNotEmpty
        ? '$_selectedSpecificLocation, $_selectedLocation, NITH'
        : '$_selectedLocation, NITH';
      final data = {
        'location': locationString,
        'specificLocation': _selectedSpecificLocation,
        'itemType': _selectedItemType,
        'description': _description,
        'imageUrls': imageUrls,
        'postmaker': username,
        'userProfile': profileImage,
        'timestamp': FieldValue.serverTimestamp(),
        'postmakerUserId': user.uid,
      };

      final collectionName = widget.isLostItem ? 'lost_items' : 'found_items';

      print('Submitting data: $data'); // Debug statement

      await firestore.collection(collectionName).add(data);

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item uploaded successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
      });
      print('Error submitting data: $e'); // Debug statement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading item')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageBytes!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2671), // Deep blue color
        title:
            Text(widget.isLostItem ? 'Upload Lost Item' : 'Upload Found Item'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1D2671),
              Color(0xFFC33764)
            ], // Deep blue to dark magenta
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 236, 231, 231),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        hint: const Text('Select Location'),
                        items: _locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value!;
                            _selectedSpecificLocation = null;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedLocation == 'Boys Hostel' ||
                          _selectedLocation == 'Girls Hostel' ||
                          _selectedLocation == 'Department')
                        DropdownButtonFormField<String>(
                          value: _selectedSpecificLocation,
                          hint: Text(
                            _selectedLocation == 'Boys Hostel'
                                ? 'Select Boys Hostel'
                                : _selectedLocation == 'Girls Hostel'
                                    ? 'Select Girls Hostel'
                                    : 'Select Department',
                          ),
                          items: (_selectedLocation == 'Boys Hostel'
                                  ? _boysHostels
                                  : _selectedLocation == 'Girls Hostel'
                                      ? _girlsHostels
                                      : _departments)
                              .map((specificLocation) {
                            return DropdownMenuItem(
                              value: specificLocation,
                              child: Text(specificLocation),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecificLocation = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedItemType,
                        hint: const Text('Select Item Type'),
                        items: _itemTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedItemType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.2),
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        onChanged: (text) {
                          setState(() {
                            _description = text;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Upload Images'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepOrange, // Deep blue color
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_imageBytes != null && _imageBytes!.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageBytes!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        _imageBytes![index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () => _removeImage(index),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitData,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.white,
                            backgroundColor: _isLoading
                                ? Colors.grey
                                : _isSuccess
                                    ? Colors.green
                                    : Colors.deepOrange, // Deep blue color
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(widget.isLostItem
                                  ? 'Upload Lost Item'
                                  : 'Upload Found Item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
