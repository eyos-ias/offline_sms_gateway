import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  runApp(const MyApp());
}

enum ConnectionStatus { CONNECTING, CONNECTED, DISCONNECTING, DISCONNECTED }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    startServer();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  void startServer() {
    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_echoRequest);

    io.serve(handler, '0.0.0.0', 8080);
    print("server");
  }

  shelf.Response _echoRequest(shelf.Request request) {
    return shelf.Response.ok('Request for "${request.url}"');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(
        message: _message,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String message;
  const HomePage({super.key, required this.message});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ConnectionStatus _connectionStatus = ConnectionStatus.DISCONNECTED;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Latest received SMS: ${widget.message}"),
            const SizedBox(
              height: 60,
            ),
            Transform.scale(
              scale: 4,
              child: Switch(
                value: _connectionStatus == ConnectionStatus.CONNECTED,
                onChanged: (value) async {
                  setState(() {
                    _connectionStatus = value
                        ? ConnectionStatus.CONNECTING
                        : ConnectionStatus.DISCONNECTING;
                  });
                  await Future.delayed(const Duration(seconds: 2));
                  setState(
                    () {
                      _connectionStatus = value
                          ? ConnectionStatus.CONNECTED
                          : ConnectionStatus.DISCONNECTED;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 60),
            Text(_connectionStatus.toString()),
            ElevatedButton(
              onPressed: () async {
                final Telephony telephony = Telephony.instance;

                telephony.sendSms(
                  to: "09209450855",
                  message: "Hello world!",
                  statusListener: (SendStatus status) {
                    if (status == SendStatus.DELIVERED) {
                      print("SMS has been delivered!");
                    } else if (status == SendStatus.SENT) {
                      print("SMS has been sent!");
                    } else {
                      print("Failed to send SMS!");
                    }
                  },
                );
              },
              child: Text('Send SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
