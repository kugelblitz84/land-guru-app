/// Land measurement units - used across the app for land size conversions
enum LandUnit {
  sqft('Sqft'),
  katha('Katha'),
  decimal('Decimal'),
  acre('Acre'),
  bigha('Bigha');

  final String label;
  const LandUnit(this.label);
}
