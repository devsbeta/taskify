import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:taskify/screens/settings/setting_screen.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../config/internet_connectivity.dart';
import '../../config/strings.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import '../home_screen/home_screen.dart';
import '../task/all_task_from_dash_screen.dart';
import '../Project/project_from_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'bottomNavWidget.dart';

class DashBoard extends StatefulWidget {
  final int initialIndex;
  const DashBoard({super.key, this.initialIndex = 0});
// Update constructor

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // final Connectivity _connectivity = Connectivity();
  // String _connectionStatus = 'unknown';
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selBottom = 0;
  int _selectedIndex = 0;
  String? currency;
  String? statusPending;
  late TabController _tabController;

  void isAA() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTimeUserKey', false);
  }

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  String? workSpaceTitle;
  getWorkspace() async {
    // setState(() async {
    var box = await Hive.openBox(userBox);
    workSpaceTitle = box.get('workspace_title');
    if (mounted) {
      BlocProvider.of<AuthBloc>(context)
          .add(WorkspaceUpdate(workspaceTitle: workSpaceTitle));
    }
    // });
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (mounted && results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (mounted) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });

    _selectedIndex = widget.initialIndex;
    getWorkspace();
    // BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    // BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    // BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());
    // BlocProvider.of<LeaveRequestBloc>(context).add(GetPendingLeaveRequest());
    // Set initial index from the passed value

    super.initState();
    isAA();

    Future.delayed(Duration.zero, () {
      _tabController = TabController(
        length: 5,
        vsync: this,
        initialIndex: _selectedIndex,
      );

      _tabController.addListener(
        () {
          Future.delayed(const Duration(microseconds: 10)).then(
            (value) {
              setState(
                () {
                  selBottom = _tabController.index;
                },
              );
            },
          );
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  final List<Widget> _widgetOptions = [
    const HomeScreen(),
    const ProjectScreen(),
    const AllTaskScreen(),
    const Settingscreen(),
  ];
  Future<bool?> _onWillPop() async {


    if (_selectedIndex == 0) {
      // Show exit confirmation dialog
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.r), // Set the desired radius here
          ),
          backgroundColor:
              Theme.of(context).colorScheme.alertBoxBackGroundColor,
          title: Text(
            AppLocalizations.of(context)!.exitApp,
          ),
          content: Text(
            AppLocalizations.of(context)!.doyouwanttoexitApp,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Stay in the app
              child: Text(AppLocalizations.of(context)!.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm exit
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        ),
      );
      if (shouldExit ?? false) {
        SystemNavigator.pop(); // This will exit the app
        return true; // Indicate that the app should exit
      } else {
        return false; // Stay in app
      } // Default to staying if dialog is dismissed
    } else if (_selectedIndex == 1 ||
        _selectedIndex == 2 ||
        _selectedIndex == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const DashBoard(initialIndex: 0),
        ),
      );
    }
    {
      setState(() {
        _selectedIndex = 0;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const DashBoard(initialIndex: 0),
          ),
        );
      });
      return false; // Stay in app if navigating to home screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {

        if (didPop) {

          return;
        }
        final bool shouldPop = await _onWillPop() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: false,
        extendBody: true,
        // drawer: drawerIn(),
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: _connectionStatus.contains(connectivityCheck)
            ? NoInternetScreen()
            : Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),

        bottomNavigationBar: _getBottomBar(isLightTheme),
      ),
    );
  }

  _getBottomBar(isLightTheme) {
    return ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.4, sigmaY: 83.4),
            child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GlowIconButton(
                          icon: HeroIcons.home,
                          isSelected: _selectedIndex == 0,
                          glowColor: Colors.white,
                          selectedColor: Theme.of(context).colorScheme.textClrChange,
                          unselectedColor: AppColors.greyForgetColor, onTap: ()=>_navigateToIndex(0),
                        ),

                    GlowIconButton(
                      icon: HeroIcons.wallet,
                      isSelected: _selectedIndex == 1,
                      onTap: () => _navigateToIndex(1),
                      glowColor: Colors.white,
                      selectedColor: Theme.of(context).colorScheme.textClrChange,
                      unselectedColor: AppColors.greyForgetColor,
                    ),
                    GlowIconButton(
                      icon: HeroIcons.documentCheck,
                      isSelected: _selectedIndex == 2,
                      onTap: () => _navigateToIndex(2),
                      glowColor: Colors.white,
                      selectedColor: Theme.of(context).colorScheme.textClrChange,
                      unselectedColor: AppColors.greyForgetColor,
                    ),
                    GlowIconButton(
                      icon: HeroIcons.cog8Tooth,
                      isSelected: _selectedIndex == 3,
                      onTap: () => _navigateToIndex(3),
                      glowColor: Colors.white,
                      selectedColor: Theme.of(context).colorScheme.textClrChange,
                      unselectedColor: AppColors.greyForgetColor,
                    ),
                  ],
                )
            )));
  }
}





