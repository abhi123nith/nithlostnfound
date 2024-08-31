import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController commentController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment(String postId, String commentText) async {
    String username = user!.email!.split('@')[0].toUpperCase();
    if (commentText.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('lost_items')
            .doc(postId)
            .collection('comments')
            .add({
          'text': commentText,
          'userId': user!.uid, // Replace with actual user ID
          'userProfile':
              user!.photoURL, // Replace with actual user profile URL
          'userName': username, // Replace with actual user name
          'timestamp': FieldValue.serverTimestamp(),
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
                    .collection('lost_items')
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
                    final userProfile = data['userProfile'] ?? '';
                    final userName = data['userName'] ?? 'Anonymous';

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: userProfile.isNotEmpty
                            ? NetworkImage(userProfile)
                            : null,
                        child: userProfile.isEmpty
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      title: Text(userName),
                      subtitle: Text(text),
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
