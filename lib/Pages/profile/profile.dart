import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> _userDetails;
  String? _profileImageUrl;
  String? _updatedName;
  bool _isEditing = false;
  bool _isUpdating = false; 
  String? _initialName;

  @override
  void initState() {
    super.initState();
    _userDetails = getUserDetails();
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdating = true; 
    });

    User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> updatedData = {};

    if (_profileImageUrl != null) {
      updatedData['profileImage'] = _profileImageUrl;
    }

    if (_updatedName != null && _updatedName!.isNotEmpty) {
      updatedData['name'] = _updatedName;
    }

    if (user != null && updatedData.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      setState(() {
        _updatedName = null;
        _profileImageUrl = null;
        _isEditing = false;
        _initialName = null;
        _isUpdating = false; 
      });

      // Refresh user details
      setState(() {
        _userDetails = getUserDetails();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      setState(() {
        _isUpdating = false; 
      });
    }
  }

  Future<void> _uploadProfileImage(Uint8List data) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profileImages/${DateTime.now().toString()}');
      final uploadTask = storageRef.putData(data);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        await _uploadProfileImage(file.bytes!);
      }
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not available';
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMMM yyyy').format(date); // Format date as "01 September 2024"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue.shade700, // Deep blue color
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'No user data found',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          final userData = snapshot.data!;
          final name = _updatedName ?? userData['name'];
          final profileImageUrl = _profileImageUrl ?? userData['profileImage'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                color: Colors.white.withOpacity(0.8), // Slightly transparent white background
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF1D2671), // Deep blue color
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: profileImageUrl != null
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage('assets/profile1.png') as ImageProvider,
                            ),
                          ),
                          if (_isEditing) 
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.black),
                                onPressed: _pickImage,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isEditing) ...[
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.12),
                          child: TextField(
                            
                            decoration: InputDecoration(
                            
                              hintText: _initialName ?? name,
                              border:  OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8), // Slightly transparent white background
                            ),
                            onChanged: (newName) {
                              _updatedName = newName;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:  Colors.deepOrange, // Deep blue color
                          ),
                          child: _isUpdating 
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('Update'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _updatedName = null; // Discard changes
                              _profileImageUrl = null; // Discard image changes
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ] else ...[
                        Text(
                          'Name: $name',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${userData['email']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Joined Date: ${_formatDate(userData['joinedDate'] as Timestamp?)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                              _initialName = name; // Store the current name
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:  Colors.deepOrange, // Deep blue color
                          ),
                          child: const Text('Edit'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
