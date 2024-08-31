import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final String postId;
  final String description;
  final String userProfile;
  final String userName;
  final Timestamp? timestamp;
  final List<String> imageUrls;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onComment;
  final String location;
  final String? specificlocation;
  final bool isLost;

  const PostCard({
    super.key,
    required this.postId,
    required this.description,
    required this.userProfile,
    required this.userName,
    required this.timestamp,
    required this.imageUrls,
    required this.isLiked,
    required this.onLike,
    required this.onShare,
    required this.onComment,
    required this.location,
    required this.isLost,
    this.specificlocation,
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Found on Unknown date';
    }
    final date = timestamp.toDate();
    final dateFormat = DateFormat('d MMMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dateFormat.format(date)} at ${timeFormat.format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final displayLocation =
        specificlocation != null && specificlocation!.isNotEmpty
            ? '$specificlocation $location'
            : location;

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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(userProfile),
                        child: userProfile.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('Location: $displayLocation'),
                          Row(
                            children: [
                              Text(isLost ? 'Lost' : 'Found'),
                              Text(' on: ${_formatTimestamp(timestamp)}'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (imageUrls.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: true,
                    ),
                    items: imageUrls.map<Widget>((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
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
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: onShare,
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: onComment,
                    ),
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
