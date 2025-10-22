import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquacare_v5/core/models/sensor_model.dart';
import 'package:aquacare_v5/core/models/threshold_model.dart';
import 'package:aquacare_v5/core/services/health_calculator.dart';

class AquariumDetailState {
  final Sensor sensor;
  final Threshold threshold;
  final double health;
  final double tempHealth;
  final double turbidityHealth;
  final double phHealth;

  AquariumDetailState({
    required this.sensor,
    required this.threshold,
    required this.health,
    required this.tempHealth,
    required this.turbidityHealth,
    required this.phHealth,
  });

  factory AquariumDetailState.initial() {
    return AquariumDetailState(
      sensor: const Sensor(temperature: 0, turbidity: 0, ph: 0),
      threshold: const Threshold(
        tempMin: 22,
        tempMax: 28,
        turbidityMin: 3,
        turbidityMax: 52,
        phMin: 6.5,
        phMax: 7.5,
      ),
      health: 0.0,
      tempHealth: 0.0,
      turbidityHealth: 0.0,
      phHealth: 0.0,
    );
  }

  AquariumDetailState copyWith({
    Sensor? sensor,
    Threshold? threshold,
    double? health,
    double? tempHealth,
    double? turbidityHealth,
    double? phHealth,
  }) {
    return AquariumDetailState(
      sensor: sensor ?? this.sensor,
      threshold: threshold ?? this.threshold,
      health: health ?? this.health,
      tempHealth: tempHealth ?? this.tempHealth,
      turbidityHealth: turbidityHealth ?? this.turbidityHealth,
      phHealth: phHealth ?? this.phHealth,
    );
  }
}

class AquariumDetailViewModel extends StateNotifier<AquariumDetailState> {
  AquariumDetailViewModel() : super(AquariumDetailState.initial());

  void updateSensor(Sensor sensor) {
    _calculateAndUpdate(sensor: sensor);
  }

  void updateThreshold(Threshold threshold) {
    _calculateAndUpdate(threshold: threshold);
  }

  void _calculateAndUpdate({Sensor? sensor, Threshold? threshold}) {
    final currentSensor = sensor ?? state.sensor;
    final currentThreshold = threshold ?? state.threshold;

    final health = HealthCalculator.calculateAquariumHealth(
      temperature: currentSensor.temperature,
      ph: currentSensor.ph,
      turbidity: currentSensor.turbidity,
      tempMin: currentThreshold.tempMin,
      tempMax: currentThreshold.tempMax,
      phMin: currentThreshold.phMin,
      phMax: currentThreshold.phMax,
      turbidityMin: currentThreshold.turbidityMin,
      turbidityMax: currentThreshold.turbidityMax,
    );

    final tempHealth = _calculateHealthPercentage(
      value: currentSensor.temperature,
      min: currentThreshold.tempMin,
      max: currentThreshold.tempMax,
    );

    final turbidityHealth = _calculateHealthPercentage(
      value: currentSensor.turbidity,
      min: currentThreshold.turbidityMin,
      max: currentThreshold.turbidityMax,
    );

    final phHealth = _calculateHealthPercentage(
      value: currentSensor.ph,
      min: currentThreshold.phMin,
      max: currentThreshold.phMax,
    );

    state = state.copyWith(
      sensor: currentSensor,
      threshold: currentThreshold,
      health: health,
      tempHealth: tempHealth,
      turbidityHealth: turbidityHealth,
      phHealth: phHealth,
    );
  }

  double _calculateHealthPercentage({
    required double value,
    required double min,
    required double max,
  }) {
    if (value <= min) return 0.0;
    if (value >= max) return 1.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  bool isTempInRange() {
    return HealthCalculator.isParameterInRange(
      state.sensor.temperature,
      state.threshold.tempMin,
      state.threshold.tempMax,
    );
  }

  bool isTurbidityInRange() {
    return HealthCalculator.isParameterInRange(
      state.sensor.turbidity,
      state.threshold.turbidityMin,
      state.threshold.turbidityMax,
    );
  }

  bool isPhInRange() {
    return HealthCalculator.isParameterInRange(
      state.sensor.ph,
      state.threshold.phMin,
      state.threshold.phMax,
    );
  }

  String getHealthStatus() {
    final wqi = state.health;
    if (wqi >= 76) return 'Excellent';
    if (wqi >= 51) return 'Good';
    if (wqi >= 26) return 'Fair';
    return 'Poor';
  }
}

final aquariumDetailViewModelProvider = StateNotifierProvider.family<
  AquariumDetailViewModel,
  AquariumDetailState,
  String
>((ref, aquariumId) {
  return AquariumDetailViewModel();
});
