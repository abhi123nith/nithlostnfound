import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getUserProfileImage(String userId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return userDoc.data()?['profileImage'];
    } else {
      print('User not found');
      return null;
    }
  } catch (e) {
    print('Error getting user data: $e');
    return null;
  }
}
