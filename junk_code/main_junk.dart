// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:telephony/telephony.dart';

// onBackgroundMessage(SmsMessage message) {
//   debugPrint("onBackgroundMessage called");
// }

// void main() {
//   runApp(const MyApp());
// }

// enum ConnectionStatus { CONNECTING, CONNECTED, DISCONNECTING, DISCONNECTED }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String _message = "";
//   final telephony = Telephony.instance;

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   onMessage(SmsMessage message) async {
//     setState(() {
//       _message = message.body ?? "Error reading message body.";
//     });
//   }

//   onSendStatus(SendStatus status) {
//     setState(() {
//       _message = status == SendStatus.SENT ? "sent" : "delivered";
//     });
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.

//     final bool? result = await telephony.requestPhoneAndSmsPermissions;

//     if (result != null && result) {
//       telephony.listenIncomingSms(
//           onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
//     }

//     if (!mounted) return;
//   }

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: HomePage(
//         message: _message,
//       ),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   final String message;
//   const HomePage({super.key, required this.message});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   ConnectionStatus _connectionStatus = ConnectionStatus.DISCONNECTED;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Latest received SMS: ${widget.message}"),
//             const SizedBox(
//               height: 60,
//             ),
//             Transform.scale(
//               scale: 4,
//               child: Switch(
//                 value: _connectionStatus == ConnectionStatus.CONNECTED,
//                 onChanged: (value) async {
//                   setState(() {
//                     _connectionStatus = value
//                         ? ConnectionStatus.CONNECTING
//                         : ConnectionStatus.DISCONNECTING;
//                   });
//                   await Future.delayed(const Duration(seconds: 2));
//                   setState(
//                     () {
//                       _connectionStatus = value
//                           ? ConnectionStatus.CONNECTED
//                           : ConnectionStatus.DISCONNECTED;
//                     },
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 60),
//             Text(_connectionStatus.toString())
//           ],
//         ),
//       ),
//     );
//   }
// }
