import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nithlostnfound/full_screen_image_viewer.dart';
import 'user_profile_page.dart'; // Import the new user profile page

class PostCard extends StatelessWidget {
  final String postId;
  final String description;
  final String profilePicUrl;
  final String userName;
  final String currentuserId;
  final String postmakerUserId;
  final Timestamp? timestamp;
  final List<String> imageUrls;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onComment;
  final String location;
  final String? specificlocation;
  final bool isLost;
  final String itemType;
  final int likeCount;
  final int shareCount;
  final int commentCount;

  const PostCard({
    super.key,
    required this.postId,
    required this.description,
    required this.profilePicUrl,
    required this.userName,
    required this.timestamp,
    required this.imageUrls,
    required this.isLiked,
    required this.onLike,
    required this.onShare,
    required this.onComment,
    required this.location,
    this.specificlocation,
    required this.currentuserId,
    required this.postmakerUserId,
    required this.likeCount,
    required this.shareCount,
    required this.commentCount,
    required this.isLost,
    required this.itemType,
  });

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final dateFormat = DateFormat('d MMMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dateFormat.format(date)} at ${timeFormat.format(date)}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      backgroundColor: Colors.deepOrange,
                      content: Text('Post deleted successfully')),
                );

                await _deletePost(context); // Perform the delete action
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    String collectionName = isLost ? 'lost_items' : 'found_items';
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(postId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.0),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayLocation;
    if (specificlocation != null && specificlocation!.isNotEmpty) {
      displayLocation = specificlocation == location
          ? specificlocation!
          : '$specificlocation, $location';
    } else {
      displayLocation = location;
    }

    final String itemStatus = isLost ? 'Lost' : 'Found';
    final String displayItemType = itemType == 'Other' ? '' : itemType;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth =
            constraints.maxWidth < 600 ? constraints.maxWidth * 0.9 : 600;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(userId: postmakerUserId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl)
                              : const AssetImage('assets/nith_logo.png')
                                  as ImageProvider,
                          child: profilePicUrl.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Location: $location',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                "$itemStatus ${displayItemType.isNotEmpty ? displayItemType : ''}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isLost ? Colors.red : Colors.green,
                                ),
                              ),
                              Text(
                                'On: ${_formatTimestamp(timestamp!)}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        if (currentuserId == postmakerUserId)
                          IconButton(
                            onPressed: () => _showDeleteDialog(context),
                            icon: const Icon(Icons.more_vert),
                          ),
                      ],
                    ),
                  ),
                ),
                if (imageUrls.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.5,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: true,
                    ),
                    items: imageUrls.map<Widget>((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullscreenImageViewer(
                                    imageUrls: imageUrls,
                                    initialIndex: imageUrls.indexOf(imageUrl),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(description),
                ),
                OverflowBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: onLike,
                    ),
                    Text('$likeCount'),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: onShare,
                    ),
                    Text('$shareCount'),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: onComment,
                    ),
                    Text('$commentCount'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
