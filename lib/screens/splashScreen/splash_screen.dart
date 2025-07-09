import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskify/bloc/setting/settings_state.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/config/app_images.dart';
import 'package:taskify/data/localStorage/hive.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/permissions/permissions_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/setting/settings_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import '../../data/GlobalVariable/globalvariable.dart';
import '../../data/repositories/Auth/auth_repo.dart';
import '../../routes/routes.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/toast_widget.dart';

class StreamSubscriptionManager {
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _permissionsSubscription;

  void dispose() {
    _settingsSubscription?.cancel();
    _permissionsSubscription?.cancel();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen(
      {super.key,
      required this.navigateAfterSeconds,
      required this.imageUrl,
      this.title});

  final int navigateAfterSeconds;
  final String imageUrl;
  final String? title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String? fromDate;
  String? toDate;
  bool? isFirstTimeUSer;

  String connectionStatus = 'Unknown';
  String? fcmToken;
  void _getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      fcmToken = token;
    });
    AuthRepository().getFcmId(fcmId: token);
    await HiveStorage.setFcm(token!);
  }

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  PermissionsBloc? permission;
  @override
  void initState() {
    // router.go('/login');
    super.initState();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
        debugPrint("$_connectivitySubscription");
        debugPrint("$_connectionStatus");
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      } else {
        flutterToastCustom(
            msg: AppLocalizations.of(context)!.nointernet,
            color: AppColors.red);
      }
    });
    permission = context.read<PermissionsBloc>();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        context.read<PermissionsBloc>().add(GetPermissions());
        final payload = ({
          'type': message.data['type'],
          'item': jsonDecode(message.data['item']),
        });
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
      } else {
        Future.delayed(Duration(seconds: 2), () {
          _initializeAsync();
        });
      }
    });

    _getFirstTimeUser();
    _getLanguage();
    _getFCMToken();
  }

  final _subscriptionManager = StreamSubscriptionManager();

  Future<void> _getLanguage() async {
    await LanguageBloc.initLanguage();
  }

  Future<void> _initializeAsync() async {
    try {
      final token = await HiveStorage.isToken();

      if (token == false && isFirstTimeUSer == true) {
        router.go('/onboarding');
        return;
      }

      if (isFirstTimeUSer == false && token == false) {
        router.go('/login');
        return;
      }

      if (token == true && isFirstTimeUSer == false) {
        final context = navigatorKey.currentContext;
        if (context == null) {
          print("[Debug] Error: No valid context");
          return;
        }

        // Get bloc references first
        final settingsBloc = navigatorKey.currentContext!.read<SettingsBloc>();
        final permissionsBloc =
            navigatorKey.currentContext!.read<PermissionsBloc>();
        // Set up permissions stream BEFORE adding events
        _subscriptionManager._permissionsSubscription?.cancel();
        _subscriptionManager._permissionsSubscription =
            permissionsBloc.stream.listen(
          (state) {
            if (state is PermissionsSuccess) {
              router.go('/dashboard');
            } else if (state is PermissionsError) {
              router.go("/emailVerification");
            }
          },
          onError: (error) {
            print("[Debug] Permissions stream error: $error");
            router.go("/emailVerification");
          },
        );

        print("[Debug] Permissions stream listener set up");

        // Set up settings stream
        _subscriptionManager._settingsSubscription?.cancel();
        _subscriptionManager._settingsSubscription = settingsBloc.stream.listen(
          (state) {
            print("[Debug] Settings stream received state: $state");
            if (state is SettingsSuccess) {
              print("[Debug] Settings Success");
            } else if (state is SettingsError) {
              print("[Debug] Settings Error");
              router.go("/emailVerification");
              flutterToastCustom(msg: state.errorMessage);
            }
          },
          onError: (error) {
            print("[Debug] Settings stream error: $error");
            router.go("/emailVerification");
          },
        );

        print("[Debug] All streams set up, now adding events");

        // Now dispatch events
        settingsBloc.add(const SettingsList("general_settings"));
        permissionsBloc.add(GetPermissions());

        print("[Debug] Events dispatched");
      }
    } catch (e) {
      print("[Debug] Initialization error: $e");
      router.go("/emailVerification");
    }
  }

  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.primary,
              image:
                  DecorationImage(image: AssetImage(AppImages.splashLogoGif))),
        ),
      ),
    );
  }
}
