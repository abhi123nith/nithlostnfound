import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnimatedBox extends StatelessWidget {
  final VoidCallback onClose;
final  String postId;

  const AnimatedBox({super.key, required this.onClose, required this.postId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ModalRoute.of(context)!.animation!,
      builder: (context, child) {
        final animation = ModalRoute.of(context)!.animation!;
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: slideAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Post'),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close the animated box
                    await _deletePost(context);
                  },
                ),
                // Add more options here if needed
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }
}
