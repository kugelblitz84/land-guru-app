import '../../../core/enums/property_type.dart';

class PropertyFilterCriteria {
  final bool isApplied;
  final String propertyTypeKey;
  final double? minPrice;
  final double? maxPrice;
  final double? minSellableKatha;
  final double? maxSellableKatha;
  final double? minPlotKatha;
  final double? maxPlotKatha;
  final double? minDistanceMeters;
  final double? maxDistanceMeters;
  final String division;
  final String district;
  final String upazilla;
  final String pouroshova;
  final String wardNo;

  const PropertyFilterCriteria({
    required this.isApplied,
    required this.propertyTypeKey,
    this.minPrice,
    this.maxPrice,
    this.minSellableKatha,
    this.maxSellableKatha,
    this.minPlotKatha,
    this.maxPlotKatha,
    this.minDistanceMeters,
    this.maxDistanceMeters,
    this.division = '',
    this.district = '',
    this.upazilla = '',
    this.pouroshova = '',
    this.wardNo = '',
  });

  bool matches({
    required PropertyType propertyType,
    String? price,
    String? sellableLandAmount,
    String? plotSize,
    String? distanceFromRoadMin,
    String? distanceFromRoadMax,
    String? distanceFromRoad,
    String? location,
  }) {
    if (!isApplied) {
      return true;
    }

    if (!_matchesPropertyType(propertyType)) {
      return false;
    }

    if (!_matchesPrice(price)) {
      return false;
    }

    if (!_matchesLandAmount(
      rawValue: sellableLandAmount,
      min: minSellableKatha,
      max: maxSellableKatha,
    )) {
      return false;
    }

    if (!_matchesLandAmount(
      rawValue: plotSize,
      min: minPlotKatha,
      max: maxPlotKatha,
    )) {
      return false;
    }

    if (!_matchesDistance(
      distanceFromRoad: distanceFromRoad,
      distanceFromRoadMin: distanceFromRoadMin,
      distanceFromRoadMax: distanceFromRoadMax,
    )) {
      return false;
    }

    if (!_matchesLocation(location)) {
      return false;
    }

    return true;
  }

  bool _matchesPropertyType(PropertyType propertyType) {
    switch (propertyTypeKey) {
      case 'all':
        return true;
      case 'plainLand':
        return propertyType == PropertyType.plainLand;
      case 'waterLand':
        return propertyType == PropertyType.waterLand;
      case 'flat':
        return propertyType == PropertyType.flat;
      default:
        return false;
    }
  }

  bool _matchesPrice(String? priceText) {
    if (minPrice == null && maxPrice == null) {
      return true;
    }

    final parsedPrice = _extractFirstNumber(priceText);
    if (parsedPrice == null) {
      return true;
    }

    if (minPrice != null && parsedPrice < minPrice!) {
      return false;
    }
    if (maxPrice != null && parsedPrice > maxPrice!) {
      return false;
    }

    return true;
  }

  bool _matchesLandAmount({
    required String? rawValue,
    required double? min,
    required double? max,
  }) {
    if (min == null && max == null) {
      return true;
    }

    final parsedValue = _extractFirstNumber(rawValue);
    if (parsedValue == null) {
      return true;
    }

    if (min != null && parsedValue < min) {
      return false;
    }
    if (max != null && parsedValue > max) {
      return false;
    }

    return true;
  }

  bool _matchesDistance({
    String? distanceFromRoad,
    String? distanceFromRoadMin,
    String? distanceFromRoadMax,
  }) {
    if (minDistanceMeters == null && maxDistanceMeters == null) {
      return true;
    }

    double? minDistance = _extractFirstNumber(distanceFromRoadMin);
    double? maxDistance = _extractFirstNumber(distanceFromRoadMax);

    if (minDistance == null && maxDistance == null) {
      final parsedRange = _parseDistanceRange(distanceFromRoad);
      if (parsedRange == null) {
        return true;
      }
      minDistance = parsedRange[0];
      maxDistance = parsedRange[1];
    } else {
      minDistance ??= maxDistance;
      maxDistance ??= minDistance;
    }

    final effectiveMinDistance = minDistance!;
    final effectiveMaxDistance = maxDistance!;
    final selectedMin = minDistanceMeters ?? effectiveMinDistance;
    final selectedMax = maxDistanceMeters ?? effectiveMaxDistance;

    return effectiveMaxDistance >= selectedMin &&
        effectiveMinDistance <= selectedMax;
  }

  bool _matchesLocation(String? rawLocation) {
    final location = (rawLocation ?? '').trim().toLowerCase();

    if (division.isNotEmpty && !location.contains(division)) {
      return false;
    }
    if (district.isNotEmpty && !location.contains(district)) {
      return false;
    }
    if (upazilla.isNotEmpty && !location.contains(upazilla)) {
      return false;
    }
    if (pouroshova.isNotEmpty && !location.contains(pouroshova)) {
      return false;
    }
    if (wardNo.isNotEmpty && !location.contains(wardNo)) {
      return false;
    }

    return true;
  }

  static double? extractFirstNumber(String? text) {
    return _extractFirstNumber(text);
  }

  static double? _extractFirstNumber(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawValue);
    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(1)!);
  }

  static List<double>? parseDistanceRange(String? rawDistance) {
    return _parseDistanceRange(rawDistance);
  }

  static List<double>? _parseDistanceRange(String? rawDistance) {
    if (rawDistance == null || rawDistance.trim().isEmpty) {
      return null;
    }

    final matches = RegExp(r'(\d+(?:\.\d+)?)')
        .allMatches(rawDistance)
        .map((match) => double.tryParse(match.group(1)!))
        .whereType<double>()
        .toList();

    if (matches.isEmpty) {
      return null;
    }

    if (matches.length == 1) {
      return [matches.first, matches.first];
    }

    return [matches.first, matches.last];
  }
}
