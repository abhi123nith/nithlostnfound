import 'package:cloud_firestore/cloud_firestore.dart';

class FoundItem {
  final String? itemType;
  final String? location;
  final String? profileImageUrl;
  final String? userName;
  final String? userEmail;
  final String? description;
  final List<String> itemImages;
  final Timestamp? postTime;

  FoundItem({
    this.itemType,
    this.location,
    this.profileImageUrl,
    this.userName,
    this.userEmail,
    this.description,
    this.itemImages = const [],
    this.postTime,
  });

  factory FoundItem.fromJson(Map<String, dynamic> json) {
    return FoundItem(
      itemType: json['itemType'] as String?,
      location: json['location'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      description: json['description'] as String?,
      itemImages: List<String>.from(json['itemImages'] ?? []),
      postTime: json['postTime'] as Timestamp?,
    );
  }
}
