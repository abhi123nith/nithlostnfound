import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nithlostnfound/comment_bottom_sheet.dart';
import 'package:nithlostnfound/post_card.dart';
import 'package:share_plus/share_plus.dart';

class FoundPage extends StatefulWidget {
  const FoundPage({super.key});

  @override
  _FoundPageState createState() => _FoundPageState();
}

class _FoundPageState extends State<FoundPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'current_user_id'; // Replace with actual user ID

  Future<void> _likePost(String postId, bool isLiked) async {
    final postDoc = _firestore.collection('found_items').doc(postId);
    if (isLiked) {
      await postDoc.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    } else {
      await postDoc.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    }
  }

  Future<bool> _hasLikedPost(String postId) async {
    final postDoc =
        await _firestore.collection('found_items').doc(postId).get();
    final data = postDoc.data();
    final likes = data?['likes'] as List<dynamic>? ?? [];
    return likes.contains(userId);
  }

  Future<void> _sharePost(String postId) async {
    final postDoc =
        await _firestore.collection('found_items').doc(postId).get();
    final data = postDoc.data();
    final content = data?['description'] ?? 'Check out this post!';
    Share.share(content, subject: 'Found Post');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('found_items')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No found items found.'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final posts = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final postId = doc.id;
                final description = data['description'] ?? '';
                final userProfile = data['userProfile'] ?? '';
                final userName = data['postmaker'] ?? '';
                final timestamp = data['timestamp'] as Timestamp?;
                final imageUrls = List<String>.from(data['imageUrls'] ?? []);
                final location = data['location'] ?? '';
                final specificlocation = data['specificLocation'] ?? '';

                return FutureBuilder<bool>(
                  future: _hasLikedPost(postId),
                  builder: (context, likeSnapshot) {
                    final isLiked = likeSnapshot.data ?? false;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8.0 : 16.0,
                        vertical: 8.0,
                      ),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: PostCard(
                            isLost: false,
                            postId: postId,
                            description: description,
                            userProfile: userProfile,
                            userName: userName,
                            timestamp: timestamp,
                            imageUrls: imageUrls,
                            isLiked: isLiked,
                            specificlocation: specificlocation,
                            onLike: () async {
                              await _likePost(postId, !isLiked);
                              setState(() {});
                            },
                            onShare: () => _sharePost(postId),
                            onComment: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    CommentsBottomSheet(postId: postId),
                              );
                            },
                            location: location,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList();

              return ListView(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 24),
                children: posts,
              );
            },
          );
        },
      ),
    );
  }
}
