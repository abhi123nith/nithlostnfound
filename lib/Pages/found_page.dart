// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final User user = FirebaseAuth.instance.currentUser!;
  late String userId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    userId = user.uid;
  }

  Future<void> _likePost(String postId, bool isLiked) async {
    final postDoc = _firestore.collection('found_items').doc(postId);
    if (isLiked) {
      await postDoc.update({
        'likes': FieldValue.arrayUnion([userId]),
        'likeCount': FieldValue.increment(1),
      });
    } else {
      await postDoc.update({
        'likes': FieldValue.arrayRemove([userId]),
        'likeCount': FieldValue.increment(-1),
      });
    }
  }

  Future<bool> _hasLikedPost(String postId) async {
    final postDoc = await _firestore.collection('found_items').doc(postId).get();
    final data = postDoc.data();
    final likes = data?['likes'] as List<dynamic>? ?? [];
    return likes.contains(userId);
  }

  Future<void> _sharePost(String postId) async {
    final postDoc = await _firestore.collection('found_items').doc(postId).get();
    final data = postDoc.data();
    final content = data?['description'] ?? 'Check out this post!';
    Share.share(content, subject: 'Found Post');
  }

  Future<int> _getCommentCount(String postId) async {
    final commentsSnapshot = await _firestore
        .collection('found_items')
        .doc(postId)
        .collection('comments')
        .get();
    return commentsSnapshot.size;
  }

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2671), // Deep blue color
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8.0 : 16.0,
              vertical: 8.0,
            ),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by description or location...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query.toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ),
        ),
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
        child: StreamBuilder<QuerySnapshot>(
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

            final posts = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final postId = doc.id;
              final description = data['description'] ?? '';
              final userProfileId = data['userProfile'] ?? '';
              final userName = data['postmaker'] ?? 'NITH_USER';
              final timestamp = data['timestamp'] as Timestamp?;
              final imageUrls = List<String>.from(data['imageUrls'] ?? []);
              final location = data['location'] ?? '';
              final specificLocation = data['specificLocation'] ?? '';
              final postmakerId = data['postmakerUserId'] ?? '';
              final likeCount = data['likeCount'] ?? 0;
              final shareCount = data['shareCount'] ?? 0;
              final itemType = data['itemType'] ?? '';

              // Apply the search filter
              final matchesSearchQuery =
                  description.toLowerCase().contains(_searchQuery) ||
                      location.toLowerCase().contains(_searchQuery) ||
                      specificLocation.toLowerCase().contains(_searchQuery);

              if (!matchesSearchQuery) {
                return const SizedBox.shrink();
              }

              return FutureBuilder<bool>(
                future: _hasLikedPost(postId),
                builder: (context, likeSnapshot) {
                  final isLiked = likeSnapshot.data ?? false;

                  return FutureBuilder<int>(
                    future: _getCommentCount(postId),
                    builder: (context, commentCountSnapshot) {
                      final commentCount = commentCountSnapshot.data ?? 0;

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _fetchUserData(userProfileId),
                        builder: (context, userSnapshot) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8.0 : 16.0,
                              vertical: 8.0,
                            ),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
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
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return PostCard(
                                      itemType: itemType == 'All' || itemType == 'Other' ? '' : itemType,
                                      isLost: false,
                                      postId: postId,
                                      description: description,
                                      profilePicUrl: userProfileId,
                                      userName: userName,
                                      timestamp: timestamp,
                                      imageUrls: imageUrls,
                                      isLiked: isLiked,
                                      specificlocation: specificLocation,
                                      onLike: () async {
                                        final newLikeStatus = !isLiked;
                                        await _likePost(postId, newLikeStatus);
                                        setState(() {});
                                      },
                                      onShare: () => _sharePost(postId),
                                      onComment: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) => CommentsBottomSheet(postId: postId, isLost: false),
                                        );
                                      },
                                      location: location,
                                      currentuserId: userId,
                                      postmakerUserId: postmakerId,
                                      likeCount: likeCount,
                                      shareCount: shareCount,
                                      commentCount: commentCount,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }).toList();

            final filteredPosts =
                posts.where((post) => post != null).toList();

            return ListView(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 24),
              children: filteredPosts,
            );
          },
        ),
      ),
    );
  }
  
  // Build the query based on filters
  // ignore: unused_element
  Stream<QuerySnapshot> _buildQuery() {
    return _firestore
        .collection('found_items')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
