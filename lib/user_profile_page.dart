import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data();
  }

  Future<int> _getPostCount(String userId, bool isLost) async {
    final collection = isLost ? 'lost_items' : 'found_items';
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('postmakerUserId', isEqualTo: userId)
        .get();
    return querySnapshot.size;
  }

  void _showFullImage(BuildContext context, String profilePicUrl) {
    print("Tapped on profile picture");
    if (profilePicUrl.isNotEmpty) {

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  profilePicUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      );
    } else {
      print("No profile picture URL found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }

        final userData = snapshot.data!;
        final email = userData['email'] ?? 'No email provided';
        final username = userData['name'] ?? 'NITH_USER';
        final profilePicUrl = userData['profileImage'] ?? '';
        final joinedDate =
            (userData['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateFormat = DateFormat('d MMMM yyyy');
        final joinedDateString = dateFormat.format(joinedDate);
        final rollNumber = email.split('@')[0].toUpperCase();

        return Scaffold(
          appBar: AppBar(
            title: Text(username),
            backgroundColor: const Color(0xFF1D2671), // Deep blue
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1D2671), // Deep blue
                  Color(0xFFC33764), // Dark magenta
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Card(
                  elevation: 12.0, // Increased elevation for the card
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Increased border radius
                  ),
                  color: Colors.white.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0), // Increased padding
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showFullImage(context, profilePicUrl);
                          },
                          child: CircleAvatar(
                            radius: 60, // Increased size of profile picture
                            backgroundImage: profilePicUrl.isNotEmpty
                                ? NetworkImage(profilePicUrl)
                                : const AssetImage('assets/nith_logo.png')
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(
                            height: 24), // Increased space between widgets
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 24, // Increased font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Email: $email',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Joined: $joinedDateString',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Roll Number: $rollNumber',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FutureBuilder<int>(
                          future: _getPostCount(userId, true),
                          builder: (context, lostPostCountSnapshot) {
                            final lostPostsCount =
                                lostPostCountSnapshot.data ?? 0;

                            return FutureBuilder<int>(
                              future: _getPostCount(userId, false),
                              builder: (context, foundPostCountSnapshot) {
                                final foundPostsCount =
                                    foundPostCountSnapshot.data ?? 0;

                                return Text(
                                  'Posts: Lost: $lostPostsCount, Found: $foundPostsCount',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
