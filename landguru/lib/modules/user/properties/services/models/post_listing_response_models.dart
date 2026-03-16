import 'package:landguru/modules/user/properties/models/property_listing.dart';
import 'package:landguru/modules/user/properties/wanted_and_needs/models/land_wanted_post.dart';

class SellPostListingResponse {
  SellPostListingResponse({required this.posts, required this.total});

  final List<PropertyListing> posts;
  final int total;
}

class BuyPostListingResponse {
  BuyPostListingResponse({required this.posts, required this.total});

  final List<LandWantedPost> posts;
  final int total;
}
