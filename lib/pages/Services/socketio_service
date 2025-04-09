import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket socket;

  SocketService._internal();

  void initSocket(
    Function(String type, String message) onNotificationReceived,
  ) {
    socket = IO.io(
      'https://aquacare-application.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Websocket connected (APP)');
    });

    socket.on('Message', (data) {
      print('Recieved Message: $data');
    });

    socket.onDisconnect((_) => print('Disconnected from WebSocket'));

    socket.on('PHNotif', (data) {
      print('PH Notification: $data');
      onNotificationReceived('PH', data['alert']);
    });

    socket.on('TemperatureNotif', (data) {
      print('Temperature Notification: $data');
      onNotificationReceived('Temperature', data['alert']);
    });

    socket.on('TurbidityNotif', (data) {
      print('Turbidity Notification: $data');
      onNotificationReceived('Turbidity', data['alert']);
    });

    socket.connect();
  }

  void sendTestMessage() {
    socket.emit('message', 'muka ka burat');
    print('Sent test message to backend!');
  }

  void dispose() {
    socket.dispose();
  }
}
