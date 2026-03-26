import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class SensorData {
  final double ultraS1, ultraS2;
  final double tpmsFL_p, tpmsFR_p, tpmsRL_p, tpmsRR_p;
  final double tpmsFL_t, tpmsFR_t, tpmsRL_t, tpmsRR_t;
  final double gpsSpeed, gpsLat, gpsLon, inclination;
  final bool connected;

  SensorData({
    required this.ultraS1, required this.ultraS2,
    required this.tpmsFL_p, required this.tpmsFR_p,
    required this.tpmsRL_p, required this.tpmsRR_p,
    required this.tpmsFL_t, required this.tpmsFR_t,
    required this.tpmsRL_t, required this.tpmsRR_t,
    required this.gpsSpeed, required this.gpsLat,
    required this.gpsLon, required this.inclination,
    required this.connected,
  });
}

class MockSensorService extends ChangeNotifier {
  final _rng = Random();
  double _dist = 180.0;
  bool _reversing = true;
  Timer? _timer;

  bool _debugMode = false;
  bool get debugMode => _debugMode;
  void setDebugMode(bool v) { _debugMode = v; notifyListeners(); }

  // ── Debug-Variablen ──────────────────────────────────────────
  double dbgFL_p = 2.4, dbgFR_p = 2.4, dbgRL_p = 2.4, dbgRR_p = 2.4;
  double dbgFL_t = 22,  dbgFR_t = 22,  dbgRL_t = 22,  dbgRR_t = 22;
  double dbgDist = 200.0;
  double dbgSpeed = 0.0;
  double dbgInclination = 0.0;

  void setDbg(String key, double val) {
    switch (key) {
      case 'FL_p': dbgFL_p = val; break;
      case 'FR_p': dbgFR_p = val; break;
      case 'RL_p': dbgRL_p = val; break;
      case 'RR_p': dbgRR_p = val; break;
      case 'FL_t': dbgFL_t = val; break;
      case 'FR_t': dbgFR_t = val; break;
      case 'RL_t': dbgRL_t = val; break;
      case 'RR_t': dbgRR_t = val; break;
      case 'dist':  dbgDist  = val; break;
      case 'speed': dbgSpeed = val; break;
      case 'incl':  dbgInclination = val; break;
    }
    notifyListeners();
  }

  SensorData _data = SensorData(
    ultraS1: 3800, ultraS2: 3800,
    tpmsFL_p: 2.4, tpmsFR_p: 2.4, tpmsRL_p: 2.4, tpmsRR_p: 2.4,
    tpmsFL_t: 22,  tpmsFR_t: 22,  tpmsRL_t: 22,  tpmsRR_t: 22,
    gpsSpeed: 0, gpsLat: 48.1351, gpsLon: 11.5820,
    inclination: 1.2, connected: true,
  );

  SensorData get data => _data;

  void startMock() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_debugMode) {
        // ── Alle Debug-Werte direkt übernehmen ──────────────
        _data = SensorData(
          ultraS1: dbgDist * 10,
          ultraS2: dbgDist * 10,
          tpmsFL_p: dbgFL_p, tpmsFR_p: dbgFR_p,
          tpmsRL_p: dbgRL_p, tpmsRR_p: dbgRR_p,
          tpmsFL_t: dbgFL_t, tpmsFR_t: dbgFR_t,
          tpmsRL_t: dbgRL_t, tpmsRR_t: dbgRR_t,
          gpsSpeed:    dbgSpeed,        // ← war vorher 0 hardcoded!
          gpsLat: 48.1351, gpsLon: 11.5820,
          inclination: dbgInclination,  // ← war vorher 1.2 hardcoded!
          connected: true,
        );
      } else {
        if (_reversing) {
          _dist -= 1.8 + _rng.nextDouble() * 0.6;
          if (_dist <= 8) { _dist = 8; _reversing = false; }
        } else {
          _dist += 2.0;
          if (_dist >= 180) { _dist = 180; _reversing = true; }
        }
        final s = _dist + _rng.nextDouble() * 3 - 1.5;
        _data = SensorData(
          ultraS1: s.clamp(5, 400) * 10,
          ultraS2: (s + _rng.nextDouble() * 2 - 1).clamp(5, 400) * 10,
          tpmsFL_p: 2.35 + _rng.nextDouble() * 0.08,
          tpmsFR_p: 2.35 + _rng.nextDouble() * 0.08,
          tpmsRL_p: 2.35 + _rng.nextDouble() * 0.08,
          tpmsRR_p: 2.35 + _rng.nextDouble() * 0.08,
          tpmsFL_t: 22 + _rng.nextDouble(),
          tpmsFR_t: 22 + _rng.nextDouble(),
          tpmsRL_t: 22 + _rng.nextDouble(),
          tpmsRR_t: 22 + _rng.nextDouble(),
          gpsSpeed: _reversing ? 2.5 + _rng.nextDouble() * 0.5 : 0.0,
          gpsLat: 48.1351, gpsLon: 11.5820,
          inclination: 1.2 + _rng.nextDouble() * 0.2,
          connected: true,
        );
      }
      notifyListeners();
    });
  }

  void stop() => _timer?.cancel();
}