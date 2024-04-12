import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:offline_gateway/cli_output.dart';
import 'package:telephony/telephony.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelfRouter;

import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

SmsMessage onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
  return message;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SmsMessage> receivedMessages = [];
  List<SmsMessage> sentMessages = [];
  String output = 'App launched\n';

  bool serviceStarted = false;
  String connectionStatus = "Server is offline";
  String? wifiIp;
  HttpServer? server;

  final telephony = Telephony.instance;

  onMessage(SmsMessage message) async {
    setState(() {
      receivedMessages.add(message);
    });
    updateOutput("received new message from ${message.address}");
  }

  void updateOutput(String newOutput) {
    setState(() {
      output +=
          '> $newOutput [${DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now())}]\n';
    });
  }

  Future<void> startServer() async {
    final NetworkInfo networkInfo = NetworkInfo();
    wifiIp = await networkInfo.getWifiIP();

    final router = shelfRouter.Router();

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    //handle the get requests (get sms and stuff)
    router.get('/get-sms/<time|.*>',
        (shelf.Request request, String time) async {
      updateOutput("fetching sms");

      // Convert the time parameter to a DateTime object
      DateTime filterDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(time) * 1000);

      List<SmsMessage> messages = await telephony.getInboxSms();
      print("filter time ${time}");
      List<Map<String, String>> smsList = [];
      print(messages[0].date);
      for (SmsMessage message in messages) {
        DateTime messageDate =
            DateTime.fromMillisecondsSinceEpoch((message.date ?? 0) * 1000);

        // Only add the message to the list if its date is after the filter date

        if (message.date! > int.parse(time)) {
          smsList.add({
            'address': message.address ?? "unknown",
            'body': message.body ?? "unknown",
            'date': message.date.toString(),
          });
        }
      }

      updateOutput("Received GET request");

      var data = {
        'message': 'This is a GET request',
        'timestamp': DateTime.now().toIso8601String(),
        'data': smsList,
      };

      return shelf.Response.ok(
        jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
    });



//handles all the sms
router.get('/get-sms', (shelf.Request request) async {
  updateOutput("fetching sms");

  List<SmsMessage> messages = await telephony.getInboxSms();
  List<Map<String, String>> smsList = [];
  for (SmsMessage message in messages) {
    smsList.add({
      'address': message.address ?? "unknown",
      'body': message.body ?? "unknown",
      'date': message.date.toString(),
    });
  }

  updateOutput("Received GET request");

  var data = {
    'message': 'This is a GET request',
    'timestamp': DateTime.now().toIso8601String(),
    'data': smsList,
  };

  return shelf.Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
});


//get sent sms without any parameters
router.get('/get-sent-sms', (shelf.Request request) async {
  updateOutput("fetching sent sms");

  List<SmsMessage> messages = await telephony.getSentSms();
  List<Map<String, String>> smsList = [];
  for (SmsMessage message in messages) {
    smsList.add({
      'address': message.address ?? "unknown",
      'body': message.body ?? "unknown",
      'date': message.date.toString(),
    });
  }

  updateOutput("Received GET request");

  var data = {
    'message': 'This is a GET request',
    'timestamp': DateTime.now().toIso8601String(),
    'data': smsList,
  };

  return shelf.Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
});

// handles all the sent sms wth timestamps
    router.get('/get-sent-sms/<time|.*>',
        (shelf.Request request, String time) async {
      updateOutput("fetching sent sms");

      // Convert the time parameter to a DateTime object
      DateTime filterDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(time) * 1000);

      List<SmsMessage> messages = await telephony.getSentSms();
      print("filter time ${time}");
      List<Map<String, String>> smsList = [];
      print(messages[0].date);
      for (SmsMessage message in messages) {
        DateTime messageDate =
            DateTime.fromMillisecondsSinceEpoch((message.date ?? 0) * 1000);

        // Only add the message to the list if its date is after the filter date
        if (message.date! > int.parse(time)) {
          smsList.add({
            'address': message.address ?? "unknown",
            'body': message.body ?? "unknown",
            'date': message.date.toString(),
          });
        }
      }

      updateOutput("Received GET request");

      var data = {
        'message': 'This is a GET request',
        'timestamp': DateTime.now().toIso8601String(),
        'data': smsList,
      };

      return shelf.Response.ok(
        jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/send-sms', (shelf.Request request) async {
      final Map<String, dynamic> data =
          jsonDecode(await request.readAsString());

      final String phoneNumber = data['phoneNumber'];
      final String message = data['message'];

      // Send an SMS
      await telephony.sendSms(
        to: phoneNumber,
        isMultipart: true,
        message: message,
      );
      updateOutput("SMS sent to $phoneNumber");
      return shelf.Response.ok('SMS sent to $phoneNumber');
    });

    print("Wi-Fi IP: $wifiIp");
    var handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(router);

    server = await io.serve(handler, '0.0.0.0', 8080);
    debugPrint("server started");
    updateOutput("server Running on port $wifiIp:8080");
    updateOutput("listening for messages");
  }

  void stopServer() {
    server?.close(force: true);
    debugPrint("server stopped");
    updateOutput("Server stopped");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Offline Gateway'),
            Text(
              'v0.0.2',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 70),
              child: Transform.scale(
                scale: 4,
                child: Switch(
                    value: serviceStarted,
                    onChanged: (value) async {
                      setState(() {
                        serviceStarted = value;
                      });
                      if (value) {
                        updateOutput("connecting");
                        await startServer();
                      } else {
                        stopServer();
                      }
                      serviceStarted = value;
                    }),
              ),
            ),
            Text(
              serviceStarted
                  ? "Service is online on $wifiIp:8080"
                  : "Service is offline",
              style: TextStyle(
                  color: serviceStarted ? Colors.green : null,
                  fontWeight: serviceStarted ? FontWeight.bold : null),
            ),
            "$wifiIp" == "null" && serviceStarted
                ? const Text(
                    "mobile data is needed to establish a connection between master and OG")
                : const SizedBox(),
            const Spacer(),
            CLIOutput(
              output: output.toLowerCase(),
              updateOutput: updateOutput,
            )
          ],
        ),
      ),
    );
  }
}
