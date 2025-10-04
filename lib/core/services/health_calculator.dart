/// Water Quality Index (WQI) Calculator for Aquarium Health
/// Based on the logic from calc.dart reference file

class Parameter {
  final String name;
  final double vMin;
  final double vMax;
  final double vCurrent;
  final double weight;

  Parameter({
    required this.name,
    required this.vMin,
    required this.vMax,
    required this.vCurrent,
    required this.weight,
  }) : assert(vMin <= vMax, 'V_Min must be less than or equal to V_Max'),
       assert(
         weight >= 0 && weight <= 1.0,
         'Weight must be between 0.0 and 1.0',
       );

  double get rangeSize => vMax - vMin;

  double get qualityRating {
    // Handle case where min and max are the same (zero thresholds)
    if (vMin == vMax) {
      return vCurrent == vMin ? 100.0 : 0.0;
    }

    // A. If the value is INSIDE the Threshold
    if (vCurrent >= vMin && vCurrent <= vMax) {
      return 100.0;
    }

    // B. If the value is OUTSIDE the Threshold (Penalty Zone)
    final double halfRangePenalty = 0.5 * rangeSize;

    // --- Too LOW Values (V_Current < V_Min) ---
    if (vCurrent < vMin) {
      final double vZeroLow = vMin - halfRangePenalty;
      final double denominator = vMin - vZeroLow;

      if (denominator == 0) return 0.0;

      double qi = 100.0 * (vCurrent - vZeroLow) / denominator;
      return qi.clamp(0.0, 100.0);
    }

    // --- Too HIGH Values (V_Current > V_Max) ---
    if (vCurrent > vMax) {
      final double vZeroHigh = vMax + halfRangePenalty;
      final double denominator = vZeroHigh - vMax;

      if (denominator == 0) return 0.0;

      double qi = 100.0 * (vZeroHigh - vCurrent) / denominator;
      return qi.clamp(0.0, 100.0);
    }

    return 0.0;
  }

  double get weightedScore => qualityRating * weight;
}

class WqiCalculator {
  final List<Parameter> parameters;

  WqiCalculator(this.parameters) {
    _validateFixedWeights();
  }

  void _validateFixedWeights() {
    final double totalWeight = parameters.fold(0.0, (sum, p) => sum + p.weight);
    if ((totalWeight - 1.0).abs() > 0.001) {
      throw ArgumentError(
        'Total weights must sum to 1.0 (currently ${totalWeight.toStringAsFixed(3)}). Check Parameter definitions.',
      );
    }
  }

  double calculateWQI() {
    double totalWQI = 0.0;
    for (final parameter in parameters) {
      totalWQI += parameter.weightedScore;
    }
    return double.parse(totalWQI.toStringAsFixed(2));
  }
}

class HealthCalculator {
  static double calculateAquariumHealth({
    required double temperature,
    required double ph,
    required double turbidity,
    required double tempMin,
    required double tempMax,
    required double phMin,
    required double phMax,
    required double turbidityMin,
    required double turbidityMax,
  }) {
    // Fixed weights as per reference: Temperature 40%, pH 35%, Turbidity 25%
    final temp = Parameter(
      name: 'Temperature',
      vMin: tempMin,
      vMax: tempMax,
      vCurrent: temperature,
      weight: 0.40,
    );

    final phParam = Parameter(
      name: 'pH Level',
      vMin: phMin,
      vMax: phMax,
      vCurrent: ph,
      weight: 0.35,
    );

    final turbidityParam = Parameter(
      name: 'Turbidity',
      vMin: turbidityMin,
      vMax: turbidityMax,
      vCurrent: turbidity,
      weight: 0.25,
    );

    final calculator = WqiCalculator([temp, phParam, turbidityParam]);
    return calculator.calculateWQI();
  }

  static bool isParameterInRange(double value, double min, double max) {
    return value >= min && value <= max;
  }
}
