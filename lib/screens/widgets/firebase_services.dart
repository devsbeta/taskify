import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../routes/routes.dart';

class NotificationService {
  late BuildContext? context;
  NotificationService({this.context});
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> initFirebaseMessaging(BuildContext context) async {
    await Firebase.initializeApp();

    await _requestNotificationPermissions();

    String? fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        print('Type: ${message.data['type']}');
      }
      print('Foreground TITLE: ${message.notification?.title}');
      print('Foreground BODY: ${message.notification?.body}');

      _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      final payload = {
        'type': message.data['type'],
        'item': jsonDecode(message.data['item']),
      };
      handleNavigation(payload);
    });

    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      print('New FCM Token: $newToken');
    });
  }


  Future<void> _requestNotificationPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    // await Firebase.initializeApp();
  }

  void _showForegroundNotification(RemoteMessage message) async {

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    String? title = message.notification?.title ?? "Default Title";
    String? body = message.notification?.body ?? "Default Body";
debugPrint("$body $title");
    final payload = {
      'type': message.data['type'],
      'item': message.data['item'],
    }.toString();

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: payload,
    );
  }

  void listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened app: ${message.notification?.title}');
      final payload = ({
        'type': message.data['type'],
        'item': jsonDecode(message.data['item']),
      });
      handleNavigation(payload); // Pass the RemoteMessage object
    });
  }

  void handleNavigation(Map<String, dynamic> payload) {
    final Map<String, dynamic> data = (payload["item"]);

    final String type = data['type'];

    if (type == "project") {
      final Map<String, dynamic> item = data['item'];

      final int id = item['id'];
      router.push('/projectdetails', extra: {"id": id, "fromNoti": true});
    } else if (type == "task") {
      final Map<String, dynamic> item = data['item'];
      router.push(
        '/taskdetail',
        extra: {
          "fromNoti": true,
          "id": item['id'],
        },
      );
    } else if (type == "meeting") {
      router.push('/meetings', extra: {"fromNoti": true});
    } else if (type == "leave_request") {
      router.push('/leaverequest', extra: {"fromNoti": true});
    } else if (type == "workspace") {
      router.push('/workspaces', extra: {
        "fromNoti": true,
      });
    }
  }
}

