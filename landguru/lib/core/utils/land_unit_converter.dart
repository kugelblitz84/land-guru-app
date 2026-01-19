import '../enums/land_unit.dart';

/// Utility class for land unit conversions
class LandUnitConverter {
  // Base unit is Sqft
  static const double sqftPerKatha = 720.0;
  static const double sqftPerDecimal = 435.6;
  static const double sqftPerAcre = 43560.0;
  static const double sqftPerBigha = 14400.0;

  /// Convert a value from one unit to sqft
  static double toSqft(double value, LandUnit unit) {
    switch (unit) {
      case LandUnit.sqft:
        return value;
      case LandUnit.katha:
        return value * sqftPerKatha;
      case LandUnit.decimal:
        return value * sqftPerDecimal;
      case LandUnit.acre:
        return value * sqftPerAcre;
      case LandUnit.bigha:
        return value * sqftPerBigha;
    }
  }

  /// Convert sqft to a specific unit
  static double fromSqft(double sqft, LandUnit unit) {
    switch (unit) {
      case LandUnit.sqft:
        return sqft;
      case LandUnit.katha:
        return sqft / sqftPerKatha;
      case LandUnit.decimal:
        return sqft / sqftPerDecimal;
      case LandUnit.acre:
        return sqft / sqftPerAcre;
      case LandUnit.bigha:
        return sqft / sqftPerBigha;
    }
  }

  /// Get all conversions for a given value and unit
  static Map<LandUnit, double> getAllConversions(
    double value,
    LandUnit fromUnit,
  ) {
    final sqft = toSqft(value, fromUnit);
    return {for (final unit in LandUnit.values) unit: fromSqft(sqft, unit)};
  }
}
