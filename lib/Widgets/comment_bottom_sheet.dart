import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nithlostnfound/Pages/profile/user_profile_image.dart';
import 'package:nithlostnfound/Pages/profile/user_profile_page.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final bool isLost;
  const CommentsBottomSheet({super.key, required this.postId, required this.isLost});

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController commentController = TextEditingController();

  User user = FirebaseAuth.instance.currentUser!;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  // Getting user profile image and storing along with post data so other users can see and can directly access it
  Future<void> _fetchUserProfileImage() async {
    String? profileImageUrl = await getUserProfileImage(user.uid);
    setState(() {
      profileImage = profileImageUrl;
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  String formatRelativeTime(Timestamp? timestamp) {
    if (timestamp == null) return 'now';

    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds${difference.inSeconds == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
  }

  Future<void> _addComment(String postId, String commentText) async {
    String username = user.email!.split('@')[0].toUpperCase();
    String collectionName = widget.isLost ? 'lost_items' : 'found_items';

    if (commentText.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(postId)
            .collection('comments')
            .add({
          'text': commentText,
          'userId': user.uid,
          'userProfile': profileImage,
          'userName': username,
          'timestamp': DateTime.now(),
        });
      } catch (e) {
        print('Error adding comment: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Type your comment here...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _addComment(widget.postId, commentController.text);
                      commentController.clear();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(widget.isLost ? 'lost_items' : 'found_items')
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading comments.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }
                  final comments = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final text = data['text'] ?? '';
                    final userProfile = data['userProfile'] ?? 'assets/nith_logo.png';
                    final userName = data['userName'] ?? 'NITH_USER';
                    final commentTime = data['timestamp'] ?? '';
                    final userId = data['userId'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(userId: userId),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: userProfile.isNotEmpty
                              ? NetworkImage(userProfile)
                              : const NetworkImage('assets/nith_logo.png'),
                          child: userProfile.isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        title: Text(userName),
                        subtitle: Row(
                          children: [
                            Expanded(child: Text(text)),
                            Text(formatRelativeTime(commentTime).toString()),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                  return ListView(children: comments);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
