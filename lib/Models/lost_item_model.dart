import 'package:cloud_firestore/cloud_firestore.dart';

class LostItem {
  final String? id;
  final String? userName;
  final String? userEmail;
  final String? itemType;
  final String? location;
  final String? description;
  final Timestamp? postTime;
  final List<String>? imageUrls; // Add this field for item images

  LostItem({
    this.id,
    this.userName,
    this.userEmail,
    this.itemType,
    this.location,
    this.description,
    this.postTime,
    this.imageUrls,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      id: json['id'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      itemType: json['itemType'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      postTime: json['postTime'] as Timestamp?,
      imageUrls: json['itemImageUrl'] as List<String>?, // Parse this field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userEmail': userEmail,
      'itemType': itemType,
      'location': location,
      'description': description,
      'postTime': postTime,
      'itemImageUrl': imageUrls, // Convert this field
    };
  }
}
