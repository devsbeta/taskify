import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskify/data/GlobalVariable/globalvariable.dart';
import 'package:taskify/config/constants.dart';
import '../config/strings.dart';
import '../screens/widgets/firebase_services.dart';


bool isDarkTheme = false;

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  GlobalUserData();

  // Open Hive boxes
  await Future.wait([
    Hive.openBox(authBox),
    Hive.openBox(themeBox),
    Hive.openBox(userBox),
    Hive.openBox(headerBox),
    Hive.openBox(permissionsBox),
    Hive.openBox(languageBoxName),
    Hive.openBox(settingsBox),
  ]);

  // Load theme preference
  final themeBoxIs = Hive.box(themeBox);
  isDarkTheme = themeBoxIs.get(isDarkThemeKey, defaultValue: false);

  // Initialize local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');


  DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );


  InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        var payloadData = convertStringToMap(notificationResponse.payload!);
        NotificationService().handleNavigation(payloadData);
      }
    },
  );

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
