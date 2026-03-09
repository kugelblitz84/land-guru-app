class FeaturedProperty {
  final String id;
  final String postId;
  final String title;
  final String location;
  final String price;
  final String propertyType;
  final String postType;
  final bool isVerified;
  final bool isLocked;
  final String? imageUrl;
  final String? description;
  final String? sellableLandAmount;
  final String? plotSize;
  final String? distanceFromRoad;
  final String? postedBy;
  final String? postedByAvatarUrl;
  final bool postedByVerified;
  final String? postedTime;

  FeaturedProperty({
    required this.id,
    this.postId = '',
    required this.title,
    required this.location,
    required this.price,
    required this.propertyType,
    required this.postType,
    required this.isVerified,
    this.isLocked = true,
    this.imageUrl,
    this.description,
    this.sellableLandAmount,
    this.plotSize,
    this.distanceFromRoad,
    this.postedBy,
    this.postedByAvatarUrl,
    this.postedByVerified = false,
    this.postedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'title': title,
      'location': location,
      'price': price,
      'propertyType': propertyType,
      'postType': postType,
      'isVerified': isVerified,
      'isLocked': isLocked,
      'imageUrl': imageUrl,
      'description': description,
      'sellableLandAmount': sellableLandAmount,
      'plotSize': plotSize,
      'distanceFromRoad': distanceFromRoad,
      'postedBy': postedBy,
      'postedByAvatarUrl': postedByAvatarUrl,
      'postedByVerified': postedByVerified,
      'postedTime': postedTime,
      'propertyPhotos': imageUrl != null ? [imageUrl] : <String>[],
    };
  }
}
