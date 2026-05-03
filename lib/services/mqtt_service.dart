import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const String broker = '192.168.178.192';
  static const int port = 1883;
  static const String distanceTopic = 'rcar/sensors/distance';

  MqttServerClient? _client;
  StreamController<Map<String, double?>>? _distanceController;
  Stream<Map<String, double?>> get distanceStream {
    _distanceController ??= StreamController<Map<String, double?>>.broadcast();
    return _distanceController!.stream;
  }

  bool _isConnected = false;
  bool get isConnected => _isConnected;
  bool _disposed = false;

  Future<void> connect() async {
    _disposed = false;
    _distanceController ??= StreamController<Map<String, double?>>.broadcast();
    
    _client = MqttServerClient(broker, 'flutter_app_');
    _client!.port = port;
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.onConnected = () {
      print('[MQTT] Connected');
      _isConnected = true;
      _subscribe();
    };
    _client!.onDisconnected = () {
      print('[MQTT] Disconnected');
      _isConnected = false;
    };
    _client!.onAutoReconnect = () => print('[MQTT] Reconnecting...');
    _client!.onAutoReconnected = () {
      print('[MQTT] Reconnected');
      _isConnected = true;
      _subscribe();
    };

    try {
      await _client!.connect();
    } catch (e) {
      print('[MQTT] Connection failed: ');
    }
  }

  void _subscribe() {
    _client!.subscribe(distanceTopic, MqttQos.atMostOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      if (_disposed || _distanceController == null || _distanceController!.isClosed) return;
      for (final msg in messages) {
        final payload = (msg.payload as MqttPublishMessage).payload.message;
        final jsonStr = utf8.decode(payload);
        final data = jsonDecode(jsonStr);
        _distanceController!.add({
          'sensor1': data['sensor1']?.toDouble(),
          'sensor2': data['sensor2']?.toDouble(),
        });
      }
    });
  }

  void disconnect() {
    _disposed = true;
    _isConnected = false;
    _client?.disconnect();
    _distanceController?.close();
    _distanceController = null;
  }
}
