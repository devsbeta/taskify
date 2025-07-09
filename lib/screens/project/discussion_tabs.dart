import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:taskify/bloc/project/project_state.dart';
import 'package:taskify/bloc/project_discussion/project_media/project_media_bloc.dart';
import 'package:taskify/bloc/project_discussion/project_media/project_media_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskify/data/model/project/media.dart';
import 'package:taskify/data/model/project/milestone.dart';
import 'package:taskify/screens/project/widgets/dateFilter.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../bloc/activity_log/activity_log_bloc.dart';
import '../../bloc/activity_log/activity_log_event.dart';
import '../../bloc/activity_log/activity_log_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../../bloc/project_discussion/project_milestone/project_milestone_state.dart';
import '../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_bloc.dart';
import '../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_event.dart';
import '../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_state.dart';
import '../../bloc/project_discussion/project_timeline/status_timeline_bloc.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user_profile/user_profile_bloc.dart';
import '../../config/app_images.dart';
import '../../config/constants.dart';
import '../../config/internet_connectivity.dart';
import '../../config/strings.dart';
import '../../data/model/project/status_timeline.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import '../../utils/widgets/circularprogress_indicator.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../../utils/widgets/shake_widget.dart';
import '../../utils/widgets/toast_widget.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/custom_container.dart';
import '../widgets/html_widget.dart';
import '../widgets/no_data.dart';
import '../widgets/no_permission_screen.dart';
import '../widgets/search_field.dart';
import '../widgets/speech_to_text.dart';
import 'discussion_screen/activity_log.dart';
import 'discussion_screen/media_screen.dart';
import 'discussion_screen/milestone_screen.dart';
import 'discussion_screen/status_timeline.dart';

class DiscussionTabs extends StatefulWidget {
  final bool? fromDetail;
  final int? id;
  const DiscussionTabs({super.key, this.fromDetail, this.id});

  @override
  State<DiscussionTabs> createState() => _DiscussionTabsState();
}

class _DiscussionTabsState extends State<DiscussionTabs>
    with TickerProviderStateMixin {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool? isLoading = true;
  bool isLoadingMore = false;
  int _selectedIndex = 0;
  String? selectedColorName;
  final Connectivity _connectivity = Connectivity();
  TextEditingController searchController = TextEditingController();
  TextEditingController mediaSearchController = TextEditingController();
  TextEditingController activityLogSearchController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  String fromDate = "";
  String toDate = "";
  TextEditingController startDateBetweenController = TextEditingController();
  TextEditingController endDateBetweenController = TextEditingController();
  TextEditingController startDateBetweenstartController =
      TextEditingController();
  TextEditingController endDateBetweenendController = TextEditingController();
  String fromDateBetween = "";
  String toDateBetween = "";
  String fromEndDateBetweenStart = "";
  String toDateEndBetweenEnd = "";
  late SpeechToTextHelper speechHelper;
  String selectedTabText = "";
  int isWhichIndex = 0;
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  DateTime selectedDateBetweenStarts = DateTime.now();
  DateTime? selectedDateBetweenEnds = DateTime.now();
  DateTime selectedDateEndBetweenStarts = DateTime.now();
  DateTime? selectedDateEndBetweenEnds = DateTime.now();
  bool? isFirstTimeUSer;
  bool? isFirst;
  String mileStoneSearchQuery = '';
  String mediaSearchQuery = '';
  String activityLogSearchQuery = '';

  TextEditingController titleController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late TabController _tabController;
  final GlobalKey _one = GlobalKey();
  String? statusname;
  bool isDownloading = false;
  double progress = 0.0;

  List<String> status = ["Complete", "Incomplete"];
  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Date between');

  String filterName = 'Date between';

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  _handleStartEndDate(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    print("fihdid $toDate");
  }

  _handleStartdateBetween(String from, String to) {
    setState(() {
      fromDateBetween = from;
      toDateBetween = to;
    });
  }

  __handleEnddateBetween(String from, String to) {
    setState(() {
      fromEndDateBetweenStart = from;
      toDateEndBetweenEnd = to;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    // filterCount = 0;
    BlocProvider.of<ProjectMilestoneBloc>(context)
        .add(MileStoneList(id: widget.id));
    BlocProvider.of<ProjectMediaBloc>(context).add(MediaList(id: widget.id));

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }

  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
  }

  Future<void> downloadFile(file, fileName) async {
    print("sjfgdjk $fileName");
    // Check storage permissions (only needed for Android)
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied");
        return;
      }
    }

    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
      });

      Dio dio = Dio();
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/$fileName";
      print("sofudlgj asas $filePath");
      await dio.download(
        file,
        filePath,
        onReceiveProgress: (received, total) {
          setState(() {
            progress = (received / total);
            print("sofudlgj $progress");
          });
        },
      );

      setState(() {
        isDownloading = false;
      });

      flutterToastCustom(
          msg: "Download completed: $fileName", color: AppColors.primary);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }

  void onShowCaseCompleted() {
    _setIsFirst(false);
  }

  final List<String> filter = [
    'Date between',
    'Start date between',
    'End date between',
    'Statuses',
  ];
  Widget _getFilteredWidget(filterName, isLightTheme) {
    switch (filterName) {
      case 'Date between':
        return DateList(
          onSelected: _handleStartEndDate,
          startController: startController,
          endController: endController,
          fromDate: fromDate,
          toDate: toDate,
          selectedDateEnds: selectedDateEnds,
          selectedDateStarts: selectedDateStarts,
        ); // Show ClientList if filterName is "client"
      case 'Start date between':
        return DateList(
          onSelected: _handleStartdateBetween,
          startController: startDateBetweenController,
          endController: endDateBetweenController,
          fromDate: fromDateBetween,
          toDate: toDateBetween,
          selectedDateEnds: selectedDateBetweenEnds,
          selectedDateStarts: selectedDateBetweenStarts,
        ); // Show UserList if filterName is "user"
      case 'End date between':
        return DateList(
          onSelected: __handleEnddateBetween,
          startController: startDateBetweenstartController,
          endController: endDateBetweenendController,
          fromDate: fromEndDateBetweenStart,
          toDate: toDateEndBetweenEnd,
          selectedDateEnds: selectedDateEndBetweenStarts,
          selectedDateStarts: selectedDateEndBetweenEnds,
        );
      case 'Statuses':
        return StatusOfMilestoneField(); // Show TagsList if filterName is "tags"
      default:
        return DateList(
          startController: startController,
          endController: endController,
          fromDate: fromDate,
          toDate: toDate,
          selectedDateEnds: selectedDateEnds,
          selectedDateStarts: selectedDateStarts,
        ); // Default view
    }
  }

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
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
      }
    });
    searchController.addListener(() {
      setState(() {});
    });
    mediaSearchController.addListener(() {
      setState(() {});
    });
    activityLogSearchController.addListener(() {
      setState(() {});
    });
    _tabController = TabController(length: 4, vsync: this);
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ProjectMilestoneBloc>().add(SearchProjectMilestone(
              widget.id, mileStoneSearchQuery, "", "", "", "", "", "", ""));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _getFirstTimeUser();
    BlocProvider.of<ProjectMilestoneBloc>(context)
        .add(MileStoneList(id: widget.id));
    BlocProvider.of<ActivityLogBloc>(context)
        .add(AllActivityLogList(type: "project", typeId: widget.id));
    BlocProvider.of<ProjectMediaBloc>(context).add(MediaList(id: widget.id));
    BlocProvider.of<StatusTimelineBloc>(context)
        .add(StatusTimelineList(id: widget.id));
  }

  ValueNotifier<List<File>> selectedFilesNotifier = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'jpg',
          'xlsx',
          'png',
          'zip',
          'rar',
          'txt'
        ],
      );

      if (result != null) {
        List<File> pickedFiles =
            result.paths.whereType<String>().map((path) => File(path)).toList();

        // Update the ValueNotifier
        selectedFilesNotifier.value = [
          ...selectedFilesNotifier.value,
          ...pickedFiles
        ];

        print("Selected Files: ${selectedFilesNotifier.value}");
      }
    }

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _appBar(isLightTheme),
              SizedBox(height: 20.h),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    MileStoneScreen(
                      id: widget.id,
                    ),
                    MediaScreen(id: widget.id),
                    StatusTimeline(id: widget.id),
                    ProjectActivityLogScreen(id: widget.id)
                  ],
                ),
              ),
              // Add bottom space to ensure content is visible behind the floating bar
              // SizedBox(height: 60.h),
            ],
          ),

          // Floating action button
          Visibility(
            visible: _selectedIndex != 2 &&
                _selectedIndex != 3, // Hide for index 2 and 3
            child: Positioned(
              right: 20.w,
              bottom: 100.h,
              child: FloatingActionButton(
                isExtended: true,
                onPressed: () {
                  switch (_selectedIndex) {
                    case 0: // Milestone tab
                      router.push("/milestone", extra: {
                        "isCreate": true,
                        "projectId": widget.id,
                        "milestone": Milestone(
                          id: 0,
                          title: "",
                          description: "",
                          startDate: "",
                          status: "",
                          endDate: "",
                          progress: 0,
                          createdAt: "",
                          cost: "",
                          createdBy: "",
                          updatedAt: "",
                        )
                      });
                      break;
                    case 1: // Media tab
                      _uploadFile(
                          pickFile: _pickFile,
                          selectedFileName: selectedFilesNotifier);
                      break;
                    default:
                      break;
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.add,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),

          // Floating bottom navigation
          Positioned(
            bottom: 20.h,
            left: 18.w,
            right: 18.w,
            child: _floatingBottomNavBar(context, isLightTheme),
          ),
        ],
      ),
    );
  }

  void _filterDialog(BuildContext context, isLightTheme) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.containerDark,
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to take the full height
      builder: (BuildContext context) {
        return FractionallySizedBox(
            heightFactor: 0.5, // 80% of the screen height
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Minimize the size of the bottom sheet
                children: <Widget>[
                  SizedBox(height: 10),
                  // Title
                  CustomText(
                    text: AppLocalizations.of(context)!.selectfilter,
                    color: AppColors.primary,
                    size: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 20), // Spacing

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 230.h, // Set a specific height if needed
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filter.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    filterNameNotifier.value = filter[index];
                                    filterName = filter[index];
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  child: Container(
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        isLightTheme
                                            ? MyThemesFilter.lightThemeShadow
                                            : MyThemesFilter.darkThemeShadow,
                                      ],
                                      color: Theme.of(context)
                                          .colorScheme
                                          .containerDark,
                                    ),
                                    child: Row(
                                      children: [
                                        ValueListenableBuilder<String>(
                                          valueListenable: filterNameNotifier,
                                          builder:
                                              (context, filterName, child) {
                                            return filterName == filter[index]
                                                ? Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      width: 2,
                                                      color: AppColors.primary,
                                                    ),
                                                  )
                                                : Expanded(
                                                    flex: 1, child: SizedBox());
                                          },
                                        ),
                                        Expanded(
                                          flex: 35,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 5.w),
                                            child: Text(
                                              filter[index],
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Vertical Divider

                      // Second Column (Placeholder for future content)
                      Expanded(
                        flex: 4,
                        child: ValueListenableBuilder<String>(
                          valueListenable: filterNameNotifier,
                          builder: (context, filterName, child) {
                            return _getFilteredWidget(filterName, isLightTheme);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h), // Spacing between content and buttons

                  // Actions (Buttons)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // Apply Button
                        InkWell(
                          onTap: () {
                            if (statusname != null) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                    ProjectUpdateFilterCountOfMileStone(
                                        filterType: 'status', isSelected: true),
                                  );
                            }
                            if (fromDate.isNotEmpty) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                    ProjectUpdateFilterCountOfMileStone(
                                        filterType: 'dateBetweenStart',
                                        isSelected: true),
                                  );
                            }

                            if (toDateEndBetweenEnd.isNotEmpty) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                    ProjectUpdateFilterCountOfMileStone(
                                        filterType: 'startDateBetweenStart',
                                        isSelected: true),
                                  );
                            }
                            if (fromDateBetween.isNotEmpty) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                    ProjectUpdateFilterCountOfMileStone(
                                        filterType: 'endDateBetweenStart',
                                        isSelected: true),
                                  );
                            }
                            BlocProvider.of<ProjectMilestoneBloc>(context).add(
                              MileStoneList(
                                id: widget.id,
                                dateBetweenFrom: fromDate,
                                dateBetweenTo: toDate,
                                endDateTo: toDateEndBetweenEnd,
                                endDateFrom: fromEndDateBetweenStart,
                                startDateFrom: fromDateBetween,
                                startDateTo: toDateBetween,
                                status: statusname,
                                fromDate: "",
                              ),
                            );

                            // Clear search controllers
                            startController.clear();
                            endController.clear();
                            startDateBetweenController.clear();
                            endDateBetweenController.clear();
                            startDateBetweenController.clear();
                            endDateBetweenController.clear();
                            startDateBetweenstartController.clear();
                            endDateBetweenendController.clear();

                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 35.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 0.h),
                              child: Center(
                                child: CustomText(
                                  text: AppLocalizations.of(context)!.apply,
                                  size: 12.sp,
                                  color: AppColors.pureWhiteColor,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 30.w),
                        // Clear Button
                        InkWell(
                          onTap: () {
                            setState(() {
                              // // Reset all filter selections
                              context
                                  .read<FilterCountOfMilestoneBloc>()
                                  .add(ProjectResetFilterCountOfMilestone());
                              //
                              // // Clear all selected IDs
                              fromDate = "";
                              toDate = "";
                              toDateEndBetweenEnd = "";
                              fromEndDateBetweenStart = "";
                              fromDateBetween = "";
                              toDateBetween = "";
                              statusname = "";
                              startController.clear();
                              endController.clear();
                              startDateBetweenController.clear();
                              endDateBetweenController.clear();
                              startDateBetweenController.clear();
                              endDateBetweenController.clear();
                              startDateBetweenstartController.clear();
                              endDateBetweenendController.clear();
                              filterNameNotifier.value = 'Date between';
                              BlocProvider.of<ProjectMilestoneBloc>(context)
                                  .add(
                                MileStoneList(
                                  id: widget.id,
                                ),
                              );

                              Navigator.of(context).pop();
                            });
                          },
                          child: Container(
                            height: 35.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Center(
                                child: CustomText(
                                  text: AppLocalizations.of(context)!.clear,
                                  size: 12.sp,
                                  color: AppColors.pureWhiteColor,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }

  Widget _tabItem(
    HeroIcons icon,
    String text,
    Color color,
    int index,
  ) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _navigateToIndex(index);
        isWhichIndex = index;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(
            icon,
            style: HeroIconStyle.outline,
            size: 18.sp,
            color: color,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: isSelected
                ? Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Text(
                      text,
                      key: ValueKey(text), // Smooth transition
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _appBar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        onTap: () {
          router.pop();
        },
        projectId: widget.id,
        discussionScreen: "projectDiscussion",
        iSBackArrow: true,
        iscreatePermission: true,
        title: (() {
          switch (_selectedIndex) {
            case 0:
              return AppLocalizations.of(context)!.milestone;
            case 1:
              return AppLocalizations.of(context)!.media;
            case 2:
              return AppLocalizations.of(context)!.statustimeline;
            case 3:
              return AppLocalizations.of(context)!.activityLog;
            default:
              return AppLocalizations.of(context)!.milestone;
          }
        })(),
        onPress: () {
          // _createEditStatus(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _floatingBottomNavBar(BuildContext context, bool isLightTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: 50.h, // Reduced height
          decoration: BoxDecoration(
            color: isLightTheme
                ? Colors.white
                    .withOpacity(0.15) // More transparent for light theme
                : Colors.black
                    .withOpacity(0.15), // More transparent for dark theme
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isLightTheme
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLightTheme
                    ? Colors.black.withOpacity(0.05)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _tabItem(HeroIcons.listBullet, "Milestone",
                  AppColors.mileStoneColor, 0),
              _tabItem(HeroIcons.photo, "Media", AppColors.photoColor, 1),
              _tabItem(HeroIcons.bars3, "Status", AppColors.yellow, 2),
              _tabItem(HeroIcons.chartBar, "Activity",
                  AppColors.activityLogColor, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget mileStone(isLightTheme) {
    return RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: context.read<PermissionsBloc>().isManageProject == true
            ? Column(
                children: [
                  CustomSearchField(
                    isLightTheme: isLightTheme,
                    controller: searchController,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (searchController.text.isNotEmpty)
                          SizedBox(
                            width: 20.w,
                            // color: AppColors.red,
                            child: IconButton(
                              highlightColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.clear,
                                size: 20.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textFieldColor,
                              ),
                              onPressed: () {
                                // Clear the search field
                                setState(() {
                                  searchController.clear();
                                });
                                // Optionally trigger the search event with an empty string
                                context.read<ProjectMilestoneBloc>().add(
                                    SearchProjectMilestone(
                                        widget.id,
                                        mileStoneSearchQuery,
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        ""));
                              },
                            ),
                          ),
                        SizedBox(
                          width: 30.w,
                          child: IconButton(
                            icon: Icon(
                              !speechHelper.isListening
                                  ? Icons.mic_off
                                  : Icons.mic,
                              size: 20.sp,
                              color:
                                  Theme.of(context).colorScheme.textFieldColor,
                            ),
                            onPressed: () {
                              if (speechHelper.isListening) {
                                speechHelper.stopListening();
                              } else {
                                speechHelper.startListening(
                                    context, searchController, SearchPopUp());
                              }
                            },
                          ),
                        ),
                        // BlocBuilder<FilterCountBloc, FilterCountState>(
                        //   builder: (context, state) {
                        //     return
                        BlocBuilder<FilterCountOfMilestoneBloc,
                            FilterCountStateOfMilestone>(
                          builder: (context, state) {
                            return SizedBox(
                              width: 35.w,
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: HeroIcon(
                                      HeroIcons.adjustmentsHorizontal,
                                      style: HeroIconStyle.solid,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textFieldColor,
                                      size: 30.sp,
                                    ),
                                    onPressed: () {
                                      // Your existing filter dialog logic
                                      _filterDialog(context, isLightTheme);
                                    },
                                  ),
                                  if (state.count > 0)
                                    Positioned(
                                      right: 5.w,
                                      top: 7.h,
                                      child: Container(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.center,
                                        height: 12.h,
                                        width: 10.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CustomText(
                                          text: state.count.toString(),
                                          color: Colors.white,
                                          size: 6,
                                          textAlign: TextAlign.center,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        )

                        //   },
                        // )
                      ],
                    ),
                    onChanged: (value) {
                      mileStoneSearchQuery = value;
                      context.read<ProjectMilestoneBloc>().add(
                          SearchProjectMilestone(
                              widget.id,
                              mileStoneSearchQuery,
                              "",
                              "",
                              "",
                              "",
                              "",
                              "",
                              ""));
                    },
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: BlocConsumer<ProjectMilestoneBloc,
                        ProjectMilestoneState>(
                      listener: (context, state) {
                        if (state is ProjectMilestonePaginated) {
                          isLoadingMore = false;
                          setState(() {});
                        }
                      },
                      builder: (context, state) {
                        if (state is ProjectMilestoneLoading) {
                          return const NotesShimmer();
                        } else if (state is ProjectMilestonePaginated) {
                          // Show notes list with pagination
                          return NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo is ScrollStartNotification) {
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss keyboard
                              }
                              // Check if the user has scrolled to the end and load more notes if needed
                              if (!state.hasReachedMax &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent &&
                                  isLoadingMore == false) {
                                isLoadingMore = true;
                                setState(() {});
                                context.read<ProjectMilestoneBloc>().add(
                                    ProjectMilestoneLoadMore(
                                        widget.id,
                                        mileStoneSearchQuery,
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        ""));
                              }
                              return false;
                            },
                            child: context
                                        .read<PermissionsBloc>()
                                        .isManageProject ==
                                    true
                                ? state.ProjectMilestone.isNotEmpty
                                    ? ListView.builder(
                                        padding: EdgeInsets.only(
                                            left: 18.w,
                                            right: 18.w,
                                            bottom: 70.h),
                                        // physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.hasReachedMax
                                            ? state.ProjectMilestone.length
                                            : state.ProjectMilestone.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index <
                                              state.ProjectMilestone.length) {
                                            Milestone milestone =
                                                state.ProjectMilestone[index];
                                            String? startDate;
                                            String? endDate;

                                            if (milestone.startDate != null) {
                                              startDate = formatDateFromApi(
                                                  milestone.startDate!,
                                                  context);
                                            }
                                            if (milestone.endDate != null) {
                                              endDate = formatDateFromApi(
                                                  milestone.endDate!, context);
                                            }
                                            double result =
                                                milestone.progress! / 100;
                                            return index == 0 &&
                                                    isFirstTimeUSer == true
                                                ? Showcase(
                                                    onTargetClick: () {
                                                      ShowCaseWidget.of(context)
                                                          .completed(
                                                              _one); // Manually complete the step
                                                      if (ShowCaseWidget.of(
                                                                  context)
                                                              .activeWidgetId ==
                                                          1) {
                                                        onShowCaseCompleted(); // Trigger this after the last showcase step
                                                      }
                                                      _setIsFirst(false);
                                                    },
                                                    disposeOnTap: true,
                                                    key: _one,
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .swipe,
                                                    titleAlignment:
                                                        Alignment.center,
                                                    // Center the title text
                                                    descriptionAlignment:
                                                        Alignment.center,
                                                    description:
                                                        "${AppLocalizations.of(context)!.swipelefttodelete} \n${AppLocalizations.of(context)!.swiperighttoedit}",
                                                    tooltipBackgroundColor:
                                                        AppColors.primary,
                                                    textColor: Colors.white,
                                                    child: ShakeWidget(
                                                        child: milestoneCard(
                                                            state
                                                                .ProjectMilestone,
                                                            index,
                                                            milestone,
                                                            startDate,
                                                            endDate,
                                                            result)))
                                                : index == 0 ||
                                                        isFirstTimeUSer == false
                                                    ? ShakeWidget(
                                                        child: milestoneCard(
                                                            state
                                                                .ProjectMilestone,
                                                            index,
                                                            milestone,
                                                            startDate,
                                                            endDate,
                                                            result))
                                                    : milestoneCard(
                                                        state.ProjectMilestone,
                                                        index,
                                                        milestone,
                                                        startDate,
                                                        endDate,
                                                        result); // No
                                          } else {
                                            // Show a loading indicator when more notes are being loaded
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              child: Center(
                                                child: state.hasReachedMax
                                                    ? const Text('')
                                                    : const SpinKitFadingCircle(
                                                        color:
                                                            AppColors.primary,
                                                        size: 40.0,
                                                      ),
                                              ),
                                            );
                                          }
                                        })
                                    : NoData(
                                        isImage: true,
                                      )
                                : NoPermission(),
                          );
                        } else if (state is ProjectError) {
                          // Show error message
                          return const NotesShimmer();
                        } else if (state is ProjectSuccess) {}
                        // Handle other states
                        return Container();
                      },
                    ),
                  )
                ],
              )
            : const NoPermission());
  }

  Widget milestoneCard(
      projectMilestone, index, milestone, startDate, endDate, result) {
    return DismissibleCard(
        direction: context.read<PermissionsBloc>().isdeleteProject == true &&
                context.read<PermissionsBloc>().iseditProject == true
            ? DismissDirection.horizontal // Allow both directions
            : context.read<PermissionsBloc>().isdeleteProject == true
                ? DismissDirection.endToStart // Allow delete
                : context.read<PermissionsBloc>().iseditProject == true
                    ? DismissDirection.startToEnd // Allow edit
                    : DismissDirection.none,
        title: milestone.id.toString(),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.startToEnd) {
            if (context.read<PermissionsBloc>().iseditProject == true) {
              router.push('/milestone', extra: {
                'isCreate': false,
                'milestone': milestone,
                "projectId": widget.id
              });
              // router.push(
              // '/createproject',
              // extra: {
              // "id": project.id,
              // "isCreate": false,
              // "title": project.title,
              // "desc": project.description,
              // "start": project.startDate ?? "",
              // "end": project.endDate ?? "",
              // "budget": project.budget,
              // 'priority': project.priority,
              // 'priorityId': project.priorityId,
              // 'statusId': project.statusId,
              // 'note': project.note,
              // "clientNames": clientList,
              // "userNames": userList,
              // "tagNames": tagList,
              // "userId": project.userId,
              // "tagId": project.tagIds,
              // "canClientDiscuss": project.clientCanDiscuss,
              // "clientId": project.clientId,
              // "access": project.taskAccessibility,
              // 'status': project.status,
              // },
              // );

              // Prevent the widget from being dismissed
              return false;
            } else {
              // No edit permission, prevent swipe
              return false;
            }
          }

          // Handle deletion confirmation
          if (direction == DismissDirection.endToStart) {
            return await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.confirmDelete),
                      content: Text(AppLocalizations.of(context)!.areyousure),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(true), // Confirm
                          child: const Text('Delete'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false), // Cancel
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                ) ??
                false; // Default to false if dialog is dismissed without action
          }

          return false; // Default case for other directions
        },
        onDismissed: (DismissDirection direction) {
          if (direction == DismissDirection.endToStart &&
              context.read<PermissionsBloc>().isdeleteProject == true) {
            setState(() {
              projectMilestone.removeAt(index);
              BlocProvider.of<ProjectMilestoneBloc>(context)
                  .add(DeleteProjectMilestone(milestone.id));
              BlocProvider.of<ProjectMilestoneBloc>(context)
                  .add(MileStoneList(id: widget.id));
            });
          } else if (direction == DismissDirection.startToEnd &&
              context.read<PermissionsBloc>().iseditProject == true) {}
        },
        dismissWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: customContainer(
            context: context,
            addWidget: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "#${milestone.id.toString()}",
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.h),
                    child: SizedBox(
                      width: 300.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 40.h,
                            child: CustomText(
                              text: milestone.title!,
                              size: 24,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            width: 100.w,
                            height: 40.h,
                            child: CustomText(
                              text: milestone.cost.toString(),
                              size: 14,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  milestone.description == null || milestone.description == ""
                      ? SizedBox()
                      : htmlWidget(milestone.description!, context,
                          height: 38.h),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 25.h,
                    width: 110.w, //
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors
                            .red.shade800), // Set the height of the dropdown
                    child: Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: CustomText(
                            text: milestone.status!,
                            color: AppColors.whiteColor,
                            size: 15.sp,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: startDate ?? "",
                          size: 12.sp,
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                        ),
                        Icon(
                          Icons.compare_arrows,
                          color: AppColors.greyColor,
                          size: 20,
                        ),
                        CustomText(
                          text: endDate ?? "",
                          size: 12.sp,
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Container(
                          child: LinearPercentIndicator(
                            padding: EdgeInsets.zero,
                            width: 200.w,
                            animation: true,
                            lineHeight: 8.0,
                            barRadius: Radius.circular(10),
                            animationDuration: 2500,
                            percent: result,
                            // center: Text(
                            //   "80.0%",
                            //   style: TextStyle(
                            //       fontSize: 10, fontWeight: FontWeight.bold),
                            // ),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: AppColors.primary,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: CustomText(
                            text: "${milestone.progress.toString()} %",
                            size: 15,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget mediaCard(
    projectMedia,
    index,
    media,
    startDate,
    endDate,
  ) {
    return DismissibleCard(
      direction: context.read<PermissionsBloc>().isdeleteProject == true &&
              context.read<PermissionsBloc>().iseditProject == true
          ? DismissDirection.horizontal // Allow both directions
          : context.read<PermissionsBloc>().isdeleteProject == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().iseditProject == true
                  ? DismissDirection.startToEnd // Allow edit
                  : DismissDirection.none,
      title: index.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (context.read<PermissionsBloc>().iseditProject == true) {
            return false;
          } else {
            // No edit permission, prevent swipe
            return false;
          }
        }

        // Handle deletion confirmation
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmDelete),
                    content: Text(AppLocalizations.of(context)!.areyousure),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(true), // Confirm
                        child: const Text('Delete'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false), // Cancel
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              ) ??
              false; // Default to false if dialog is dismissed without action
        }

        return false; // Default case for other directions
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteProject == true) {
          // setState(() {
          //   stateProject.removeAt(index);
          //   _onDeleteProject(id: stateProject[index].id);
          // });
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditProject == true) {}
      },
      dismissWidget: InkWell(
          onTap: () {
            // router.push('/projectdetails', extra: {
            //   "id": stateProject[index].id,
            // });
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: customContainer(
              context: context,
              addWidget: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Container(
                    // color: Colors.teal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "#${media.id.toString()}",
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  height: 50.h,
                                  width: 50.w,
                                  decoration: BoxDecoration(
                                    // color: Colors.red,
                                    image: DecorationImage(
                                        image: NetworkImage(media.preview),
                                        fit: BoxFit.cover),
                                  )),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                // color: Colors.yellow,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: media.fileName,
                                            size: 15.sp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                            fontWeight: FontWeight.w700,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Container(
                                        //     height: 20.h,
                                        //     width: 20.w,
                                        //     decoration: BoxDecoration(
                                        //       // color: Colors.red,
                                        //       image: DecorationImage(
                                        //           image:
                                        //           AssetImage(AppImages.downloadGif),
                                        //           fit: BoxFit.cover),
                                        //     ))
                                        InkWell(
                                          onTap: () {
                                            print("DZgfxzg ${media.file}");
                                            context
                                                .read<ProjectMediaBloc>()
                                                .add(StartDownload(
                                                    fileUrl: media.file,
                                                    fileName: media.fileName));

                                            // downloadFile(media.file,media.fileName);
                                          },
                                          child: HeroIcon(
                                            HeroIcons.documentArrowDown,
                                            style: HeroIconStyle.outline,
                                            size: 25.sp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          text: media.fileSize,
                                          size: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          fontWeight: FontWeight.w700,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: CustomText(
                                              text: startDate,
                                              size: 12.sp,
                                              color: AppColors.greyColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Center(
                                              child: Icon(
                                                Icons.compare_arrows,
                                                color: AppColors.greyColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: CustomText(
                                              text: endDate,
                                              size: 12.sp,
                                              color: AppColors.greyColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget StatusTimelineCard(projectTimelineList, projectTimeline, index) {
    Color? colorOfNewStatus;
    Color? colorOfOldStatus;

    switch (projectTimeline.oldColor) {
      case "primary":
        colorOfOldStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfOldStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfOldStatus = Colors.green;
        break;
      case "danger":
        colorOfOldStatus = Colors.red;
        break;
      case "warning":
        colorOfOldStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfOldStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfOldStatus = Colors.black;
        break;
      default:
        colorOfOldStatus = Colors.grey; // Fallback color
    }
    switch (projectTimeline.newColor) {
      case "primary":
        colorOfNewStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfNewStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfNewStatus = Colors.green;
        break;
      case "danger":
        colorOfNewStatus = Colors.red;
        break;
      case "warning":
        colorOfNewStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfNewStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfNewStatus = Colors.black;
        break;
      default:
        colorOfNewStatus = Colors.grey; // Fallback color
    }
    // Output: 2025-03-03
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: TimelineTile(
        isFirst: index == 0,
        isLast: index == projectTimelineList.length - 1,
        beforeLineStyle: LineStyle(color: colorOfNewStatus, thickness: 3),
        indicatorStyle: IndicatorStyle(
          width: 15.w,
          color: colorOfNewStatus,
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(10.0),
          child: customContainer(
              addWidget: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          projectTimeline.timeDiff,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.textClrChange),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "${projectTimeline.changedAt}  ${projectTimeline.changedAtTime}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      "changed status from ",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.textClrChange),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          // width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  colorOfOldStatus), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: CustomText(
                                  text: projectTimeline.previousStatus,
                                  color: AppColors.whiteColor,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                        Text(
                          " >> ",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.textClrChange),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          // width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  colorOfNewStatus), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: CustomText(
                                  text: projectTimeline.status,
                                  color: AppColors.whiteColor,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              context: context),
        ),
      ),
    );
  }

  Widget media(isLightTheme) {
    context
        .read<FilterCountOfMilestoneBloc>()
        .add(ProjectResetFilterCountOfMilestone());
    return RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: context.read<PermissionsBloc>().isManageProject == true
            ? Column(
                children: [
                  CustomSearchField(
                    isLightTheme: isLightTheme,
                    controller: mediaSearchController,
                    suffixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (mediaSearchController.text.isNotEmpty)
                            SizedBox(
                              width: 20.w,
                              // color: AppColors.red,
                              child: IconButton(
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.clear,
                                  size: 20.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textFieldColor,
                                ),
                                onPressed: () {
                                  // Clear the search field
                                  setState(() {
                                    mediaSearchController.clear();
                                  });
                                  // Optionally trigger the search event with an empty string
                                  context
                                      .read<ProjectMediaBloc>()
                                      .add(SearchMedia("", widget.id));
                                },
                              ),
                            ),
                          SizedBox(
                            width: 30.w,
                            child: IconButton(
                              icon: Icon(
                                !speechHelper.isListening
                                    ? Icons.mic_off
                                    : Icons.mic,
                                size: 20.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textFieldColor,
                              ),
                              onPressed: () {
                                if (speechHelper.isListening) {
                                  speechHelper.stopListening();
                                } else {
                                  speechHelper.startListening(
                                      context, searchController, SearchPopUp());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (value) {
                      mediaSearchQuery = value;
                      context
                          .read<ProjectMediaBloc>()
                          .add(SearchMedia(value, widget.id));
                      print("jksfglzkghzk $mileStoneSearchQuery");
                    },
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: BlocConsumer<ProjectMediaBloc, ProjectMediaState>(
                      listener: (context, state) {
                        if (state is ProjectMediaPaginated) {
                          isLoadingMore = false;
                          setState(() {});
                        } else if (state is DownloadSuccess) {
                          BlocProvider.of<ProjectMediaBloc>(context)
                              .add(MediaList(id: widget.id));

                          flutterToastCustom(
                              msg: "Download completed: ${state.fileName}",
                              color: AppColors.primary);
                        } else if (state is DownloadFailure) {
                          flutterToastCustom(
                              msg: "Download failed: ${state.error}",
                              color: AppColors.primary);
                        } else if (state is DownloadInProgress) {
                          showToastWithProgress(context, state.progress);
                          if (state.progress == 0.0) {
                            BlocProvider.of<ProjectMediaBloc>(context)
                                .add(MediaList(id: widget.id));
                          }
                        } else if (state is ProjectMediaDeleteSuccess) {
                          flutterToastCustom(
                              msg: AppLocalizations.of(context)!
                                  .deletedsuccessfully,
                              color: AppColors.red);
                          BlocProvider.of<ProjectMediaBloc>(context)
                              .add(MediaList(id: widget.id));
                        }
                        ;
                      },
                      builder: (context, state) {
                        if (state is ProjectMediaLoading) {
                          return const NotesShimmer();
                        } else if (state is ProjectMediaPaginated) {
                          // Show notes list with pagination
                          return NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo is ScrollStartNotification) {
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss keyboard
                              }
                              // Check if the user has scrolled to the end and load more notes if needed
                              if (!state.hasReachedMax &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent &&
                                  isLoadingMore == false) {
                                isLoadingMore = true;
                                setState(() {});
                                context.read<ProjectMilestoneBloc>().add(
                                    ProjectMilestoneLoadMore(
                                        widget.id,
                                        mileStoneSearchQuery,
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        ""));
                              }
                              return false;
                            },
                            child: context
                                        .read<PermissionsBloc>()
                                        .isManageProject ==
                                    true
                                ? state.ProjectMedia.isNotEmpty
                                    ? ListView.builder(
                                        padding: EdgeInsets.only(
                                            left: 18.w,
                                            right: 18.w,
                                            bottom: 70.h),
                                        // physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.hasReachedMax
                                            ? state.ProjectMedia.length
                                            : state.ProjectMedia.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index <
                                              state.ProjectMedia.length) {
                                            MediaModel media =
                                                state.ProjectMedia[index];
                                            String? startDate;
                                            String? endDate;

                                            if (media.updatedAt != null) {
                                              startDate = formatDateFromApi(
                                                  media.updatedAt!, context);
                                            }
                                            if (media.createdAt != null) {
                                              endDate = formatDateFromApi(
                                                  media.createdAt!, context);
                                            }

                                            return index == 0 &&
                                                    isFirstTimeUSer == true
                                                ? Showcase(
                                                    onTargetClick: () {
                                                      ShowCaseWidget.of(context)
                                                          .completed(
                                                              _one); // Manually complete the step
                                                      if (ShowCaseWidget.of(
                                                                  context)
                                                              .activeWidgetId ==
                                                          1) {
                                                        onShowCaseCompleted(); // Trigger this after the last showcase step
                                                      }
                                                      _setIsFirst(false);
                                                    },
                                                    disposeOnTap: true,
                                                    key: _one,
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .swipe,
                                                    titleAlignment:
                                                        Alignment.center,
                                                    // Center the title text
                                                    descriptionAlignment:
                                                        Alignment.center,
                                                    description:
                                                        "${AppLocalizations.of(context)!.swipelefttodelete} \n${AppLocalizations.of(context)!.swiperighttoedit}",
                                                    tooltipBackgroundColor:
                                                        AppColors.primary,
                                                    textColor: Colors.white,
                                                    child: ShakeWidget(
                                                        child: mediaCard(
                                                            state.ProjectMedia,
                                                            index,
                                                            media,
                                                            startDate,
                                                            endDate)))
                                                : index == 0 ||
                                                        isFirstTimeUSer == false
                                                    ? ShakeWidget(
                                                        child: mediaCard(
                                                            state.ProjectMedia,
                                                            index,
                                                            media,
                                                            startDate,
                                                            endDate))
                                                    : mediaCard(
                                                        state.ProjectMedia,
                                                        index,
                                                        media,
                                                        startDate,
                                                        endDate); // No
                                          } else {
                                            // Show a loading indicator when more notes are being loaded
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              child: Center(
                                                child: state.hasReachedMax
                                                    ? const Text('')
                                                    : const SpinKitFadingCircle(
                                                        color:
                                                            AppColors.primary,
                                                        size: 40.0,
                                                      ),
                                              ),
                                            );
                                          }
                                        })
                                    : NoData(
                                        isImage: true,
                                      )
                                : NoPermission(),
                          );
                        } else if (state is ProjectError) {
                          // Show error message
                          return const NotesShimmer();
                        } else if (state is ProjectSuccess) {}
                        // Handle other states
                        return Container();
                      },
                    ),
                  )
                ],
              )
            : const NoPermission());
  }

  Widget statusTimeline(isLightTheme) {
    context
        .read<FilterCountOfMilestoneBloc>()
        .add(ProjectResetFilterCountOfMilestone());
    return RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: context.read<PermissionsBloc>().isManageProject == true
            ? Column(
                children: [
                  Expanded(
                    child:
                        BlocConsumer<StatusTimelineBloc, StatusTimelineState>(
                      listener: (context, state) {
                        if (state is ProjectStatusTimelinePaginated) {
                          isLoadingMore = false;
                          setState(() {});
                        }
                      },
                      builder: (context, state) {
                        print("fdxgxg $state");
                        if (state is ProjectMediaLoading) {
                          return const NotesShimmer();
                        } else if (state is ProjectStatusTimelinePaginated) {
                          // Show notes list with pagination
                          return NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo is ScrollStartNotification) {
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss keyboard
                              }
                              // Check if the user has scrolled to the end and load more notes if needed
                              if (!state.hasReachedMax &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent &&
                                  isLoadingMore == false) {
                                isLoadingMore = true;
                                setState(() {});
                                // context.read<ProjectMilestoneBloc>().add(
                                //     ProjectMilestoneLoadMore(
                                //         widget.id,
                                //         mileStoneSearchQuery,
                                //         "",
                                //         "",
                                //         "",
                                //         "",
                                //         "",
                                //         "",
                                //         ""));
                              }
                              return false;
                            },
                            child: context
                                        .read<PermissionsBloc>()
                                        .isManageProject ==
                                    true
                                ? state.ProjectTimeline.isNotEmpty
                                    ? ListView.builder(
                                        padding: EdgeInsets.only(
                                            left: 18.w,
                                            right: 18.w,
                                            bottom: 150.h),
                                        // physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.hasReachedMax
                                            ? state.ProjectTimeline.length
                                            : state.ProjectTimeline.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index <
                                              state.ProjectTimeline.length) {
                                            StatusTimelineModel timline =
                                                state.ProjectTimeline[index];
                                            String? startDate;
                                            String? endDate;

                                            // if (media.updatedAt != null) {
                                            //   startDate = formatDateFromApi(
                                            //       media.updatedAt!, context);
                                            // }
                                            // if (media.createdAt != null) {
                                            //   endDate = formatDateFromApi(
                                            //       media.createdAt!, context);
                                            // }

                                            return index == 0 &&
                                                    isFirstTimeUSer == true
                                                ? Showcase(
                                                    onTargetClick: () {
                                                      ShowCaseWidget.of(context)
                                                          .completed(
                                                              _one); // Manually complete the step
                                                      if (ShowCaseWidget.of(
                                                                  context)
                                                              .activeWidgetId ==
                                                          1) {
                                                        onShowCaseCompleted(); // Trigger this after the last showcase step
                                                      }
                                                      _setIsFirst(false);
                                                    },
                                                    disposeOnTap: true,
                                                    key: _one,
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .swipe,
                                                    titleAlignment:
                                                        Alignment.center,
                                                    // Center the title text
                                                    descriptionAlignment:
                                                        Alignment.center,
                                                    description:
                                                        "${AppLocalizations.of(context)!.swipelefttodelete} \n${AppLocalizations.of(context)!.swiperighttoedit}",
                                                    tooltipBackgroundColor:
                                                        AppColors.primary,
                                                    textColor: Colors.white,
                                                    child: ShakeWidget(
                                                        child: StatusTimelineCard(
                                                            state
                                                                .ProjectTimeline,
                                                            state.ProjectTimeline[
                                                                index],
                                                            index)))
                                                : index == 0 ||
                                                        isFirstTimeUSer == false
                                                    ? ShakeWidget(
                                                        child: StatusTimelineCard(
                                                            state
                                                                .ProjectTimeline,
                                                            state.ProjectTimeline[
                                                                index],
                                                            index))
                                                    : StatusTimelineCard(
                                                        state.ProjectTimeline,
                                                        state.ProjectTimeline[index],
                                                        index); // No
                                          } else {
                                            // Show a loading indicator when more notes are being loaded
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              child: Center(
                                                child: state.hasReachedMax
                                                    ? const Text('')
                                                    : const SpinKitFadingCircle(
                                                        color:
                                                            AppColors.primary,
                                                        size: 40.0,
                                                      ),
                                              ),
                                            );
                                          }
                                        })
                                    : NoData(
                                        isImage: true,
                                      )
                                : NoPermission(),
                          );
                        } else if (state is ProjectError) {
                          // Show error message
                          return const NotesShimmer();
                        } else if (state is ProjectSuccess) {}
                        // Handle other states
                        return Container();
                      },
                    ),
                  )
                ],
              )
            : const NoPermission());
    // return Padding(
    //   padding: EdgeInsets.symmetric(horizontal: 18.w),
    //   child: ListView.builder(
    //     padding: EdgeInsets.zero,
    //     itemCount: statuses.length,
    //     itemBuilder: (context, index) {
    //       final status = statuses[index];
    //       return TimelineTile(
    //         isFirst: index == 0,
    //         isLast: index == statuses.length - 1,
    //         beforeLineStyle: LineStyle(
    //             color: status['isCompleted'] ? status['color'] : Colors.grey,
    //             thickness: 3),
    //         indicatorStyle: IndicatorStyle(
    //           width: 15.w,
    //           color: status['isCompleted'] ? status['color'] : Colors.grey,
    //         ),
    //         endChild: Padding(
    //           padding: const EdgeInsets.all(10.0),
    //           child: customContainer(
    //               addWidget: Padding(
    //                 padding: const EdgeInsets.all(16.0),
    //                 child: Column(
    //                   children: [
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.end,
    //                       children: [
    //                         Text(
    //                           "3 days ago",
    //                           style: TextStyle(
    //                               fontSize: 10,
    //                               fontWeight: FontWeight.bold,
    //                               color: Theme.of(context)
    //                                   .colorScheme
    //                                   .textClrChange),
    //                         ),
    //                       ],
    //                     ),
    //                     SizedBox(
    //                       height: 10.h,
    //                     ),
    //                     Text(
    //                       "March 03, 2025 06:23:34 am",
    //                       style: TextStyle(
    //                           fontSize: 15,
    //                           fontWeight: FontWeight.bold,
    //                           color: status['color']),
    //                     ),
    //                     Text(
    //                       "changed status from ",
    //                       style: TextStyle(
    //                           fontSize: 12,
    //                           color:
    //                               Theme.of(context).colorScheme.textClrChange),
    //                     ),
    //                     SizedBox(
    //                       height: 5.h,
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Container(
    //                           alignment: Alignment.center,
    //                           height: 20.h,
    //                           // width: 110.w, //
    //                           decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(10),
    //                               color: Colors.blue
    //                                   .shade800), // Set the height of the dropdown
    //                           child: Center(
    //                             child: Padding(
    //                                 padding:
    //                                     EdgeInsets.symmetric(horizontal: 10.w),
    //                                 child: CustomText(
    //                                   text: status['status'],
    //                                   color: AppColors.whiteColor,
    //                                   size: 12.sp,
    //                                   fontWeight: FontWeight.w600,
    //                                 )),
    //                           ),
    //                         ),
    //                         Text(
    //                           " >> ",
    //                           style: TextStyle(
    //                               fontSize: 15,
    //                               fontWeight: FontWeight.bold,
    //                               color: Theme.of(context)
    //                                   .colorScheme
    //                                   .textClrChange),
    //                         ),
    //                         Container(
    //                           alignment: Alignment.center,
    //                           height: 20.h,
    //                           // width: 110.w, //
    //                           decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(10),
    //                               color: Colors.blue
    //                                   .shade800), // Set the height of the dropdown
    //                           child: Center(
    //                             child: Padding(
    //                                 padding:
    //                                     EdgeInsets.symmetric(horizontal: 10.w),
    //                                 child: CustomText(
    //                                   text: status['status'],
    //                                   color: AppColors.whiteColor,
    //                                   size: 12.sp,
    //                                   fontWeight: FontWeight.w600,
    //                                 )),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               context: context),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  Future<void> _uploadFile({pickFile, selectedFileName}) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              height: 450.h,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                height: 40.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.greyColor
                                      .withValues(alpha: 0.3),
                                ),
                                child: HeroIcon(
                                  HeroIcons.cloudArrowUp,
                                  style: HeroIconStyle.outline,
                                  size: 25.sp,
                                  color: AppColors.greyColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Upload files",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text("Select and upload the files ",
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 35,
                          // color: Colors.red,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(
                          border: DashedBorder.fromBorderSide(
                              dashLength: 15,
                              side: BorderSide(
                                  color: AppColors.greyColor, width: 1)),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Container(
                              height: 70.h,
                              width: 70.w,
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                image: DecorationImage(
                                    image: AssetImage(AppImages.cloudGif),
                                    fit: BoxFit.cover),
                              )),
                          const SizedBox(height: 8),
                          FittedBox(
                            child: CustomText(
                                text: AppLocalizations.of(context)!
                                    .chooseafileorclickbelow,
                                size: 20.sp,
                                textAlign:
                                    TextAlign.center, // Center align if needed
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange),
                          ),
                          CustomText(
                            text: AppLocalizations.of(context)!.formatandsize,
                            color: AppColors.greyColor,
                            size: 15.sp,
                            textAlign: TextAlign
                                .center, // Make sure it wraps instead of cutting off
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: pickFile,
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6)),
                                height: 30.h,
                                width: 100.w,
                                margin: EdgeInsets.symmetric(vertical: 10.h),
                                child: CustomText(
                                  text:
                                      AppLocalizations.of(context)!.browsefile,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.pureWhiteColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    InkWell(
                      onTap: () {
                        print("gklr dlgknv ");
                        context.read<ProjectMediaBloc>().add(UploadMedia(
                            id: widget.id!,
                            media: selectedFilesNotifier.value));
                        selectedFilesNotifier.value = [];
                        router.pop();
                      },
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6)),
                          height: 30.h,
                          width: 100.w,
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          child: CustomText(
                            text: AppLocalizations.of(context)!.upload,
                            size: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pureWhiteColor,
                          )),
                    ),
                    // if (selectedFilesNotifier.value.isNotEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 12),
                    //     child: Text("Selected File: ${selectedFilesNotifier.value}"),
                    //   ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget StatusOfMilestoneField() {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return Container(
        constraints: BoxConstraints(maxHeight: 900.h),
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: status.length,
          itemBuilder: (BuildContext context, int index) {
            final isSelected = statusname == status[index];

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    statusname = status[index];
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 35.h,
                    decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.purpleShade
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.purple
                                : Colors.transparent)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120.w,
                              // color: Colors.red,
                              child: CustomText(
                                text: status[index],
                                fontWeight: FontWeight.w500,
                                size: 18.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color: isSelected
                                    ? AppColors.purple
                                    : Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                              ),
                            ),
                            isSelected
                                ? const HeroIcon(HeroIcons.checkCircle,
                                    style: HeroIconStyle.solid,
                                    color: AppColors.purple)
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget activityLog(isLightTheme) {
    return RefreshIndicator(
      color: AppColors.primary, // Spinner color
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      onRefresh: _onRefresh,
      child: Column(
        children: [
          CustomSearchField(
            isLightTheme: isLightTheme,
            controller: activityLogSearchController,
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activityLogSearchController.text.isNotEmpty)
                    SizedBox(
                      width: 20.w,
                      // color: AppColors.red,
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.clear,
                          size: 20.sp,
                          color: Theme.of(context).colorScheme.textFieldColor,
                        ),
                        onPressed: () {
                          // Clear the search field
                          setState(() {
                            activityLogSearchController.clear();
                          });
                          // Optionally trigger the search event with an empty string
                          context
                              .read<ActivityLogBloc>()
                              .add(SearchActivityLog("", widget.id, "project"));
                        },
                      ),
                    ),
                  SizedBox(
                    width: 30.w,
                    child: IconButton(
                      icon: Icon(
                        !speechHelper.isListening ? Icons.mic_off : Icons.mic,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.textFieldColor,
                      ),
                      onPressed: () {
                        if (speechHelper.isListening) {
                          speechHelper.stopListening();
                        } else {
                          speechHelper.startListening(
                              context, searchController, SearchPopUp());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            onChanged: (value) {
              activityLogSearchQuery = value;
              context.read<ActivityLogBloc>().add(SearchActivityLog(
                  activityLogSearchQuery, widget.id, "project"));
            },
          ),
          SizedBox(height: 10.h),
          BlocConsumer<ActivityLogBloc, ActivityLogState>(
            listener: (context, state) {
              if (state is ActivityLogDeleteSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<ActivityLogBloc>(context)
                    .add(AllActivityLogList());
              } else if (state is ActivityLogError) {
                BlocProvider.of<ActivityLogBloc>(context)
                    .add(AllActivityLogList());

                flutterToastCustom(msg: state.errorMessage);
              } else if (state is ActivityLogDeleteError) {
                BlocProvider.of<ActivityLogBloc>(context)
                    .add(AllActivityLogList());

                flutterToastCustom(msg: state.errorMessage);
              }
            },
            builder: (context, state) {
              if (state is ActivityLogLoading) {
                return Expanded(
                  child: NotesShimmer(
                    height: 190.h,
                    count: 4,
                  ),
                );
              } else if (state is ActivityLogPaginated) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      context
                          .read<ActivityLogBloc>()
                          .add(LoadMoreActivityLog(""));
                    }
                    return false;
                  },
                  child: state.activityLog.isNotEmpty
                      ? _activityLogList(
                          isLightTheme, state.hasReachedMax, state.activityLog)

                      // height: 500,

                      : NoData(
                          isImage: true,
                        ),
                );
              }
              // Handle other states
              return const Text("");
            },
          ),
        ],
      ),
    );
  }

  Widget _activityLogList(isLightTheme, hasReachedMax, activityLog) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 0.h),
        // shrinkWrap: true,
        itemCount: hasReachedMax
            ? activityLog.length // No extra item if all data is loaded
            : activityLog.length + 1, // Add 1 for the loading indicator
        itemBuilder: (context, index) {
          if (index < activityLog.length) {
            final activity = activityLog[index];
            String? dateCreated;
            dateCreated = formatDateFromApi(activity.createdAt!, context);
            return index == 0
                ? ShakeWidget(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 18.w),
                        child: DismissibleCard(
                          title: activityLog[index].id.toString(),
                          confirmDismiss: (DismissDirection direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // Right to left swipe (Delete action)
                              final result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    title: Text(
                                      AppLocalizations.of(context)!
                                          .confirmDelete,
                                    ),
                                    content: Text(
                                      AppLocalizations.of(context)!.areyousure,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(true); // Confirm deletion
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.delete,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(false); // Cancel deletion
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.cancel,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return result;
                            }
                            return false;
                          },
                          dismissWidget: _activityChild(
                              isLightTheme, activityLog[index], dateCreated),
                          direction: context
                                      .read<PermissionsBloc>()
                                      .isdeleteActivityLog ==
                                  true
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          onDismissed: (DismissDirection direction) {
                            if (direction == DismissDirection.endToStart) {
                              setState(() {
                                activityLog.removeAt(index);
                                // onDeleteActivityLog(activity.id!);
                              });
                            }
                          },
                        )),
                  )
                : Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                    child: DismissibleCard(
                      title: activityLog[index].id.toString(),
                      confirmDismiss: (DismissDirection direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Right to left swipe (Delete action)
                          final result = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.r), // Set the desired radius here
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .alertBoxBackGroundColor,
                                title: Text(
                                  AppLocalizations.of(context)!.confirmDelete,
                                ),
                                content: Text(
                                  AppLocalizations.of(context)!.areyousure,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(true); // Confirm deletion
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.delete,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(false); // Cancel deletion
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return result;
                        }
                        return false;
                      },
                      dismissWidget: _activityChild(
                          isLightTheme, activityLog[index], dateCreated),
                      direction:
                          context.read<PermissionsBloc>().isdeleteActivityLog ==
                                  true
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                      onDismissed: (DismissDirection direction) {
                        if (direction == DismissDirection.endToStart) {
                          setState(() {
                            activityLog.removeAt(index);
                            // onDeleteActivityLog(activity.id!);
                          });
                        }
                      },
                    ));
          } else {
            // Show a loading indicator when more Meeting are being loaded
            return CircularProgressIndicatorCustom(
              hasReachedMax: hasReachedMax,
            );
          }
        },
      ),
    );
  }

  Widget _activityChild(isLightTheme, activityLog, dateCreated) {
    String? profilePic;
    if (context.read<UserProfileBloc>().profilePic != null) {
      profilePic = context.read<UserProfileBloc>().profilePic;
    }
    return Container(
        decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(12)),
        // height: 170.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.h, left: 18.w, right: 18.w),
                      child: SizedBox(
                        // height: 40.h,

                        // color: Colors.yellow,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "#${activityLog.id.toString()}",
                                          size: 12.sp,
                                          color: AppColors.projDetailsSubText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        SizedBox(
                                          // color: Colors.red,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                // width:30.w,
                                                // alignment: Alignment.center,
                                                child: CircleAvatar(
                                                  radius: 25.r,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .backGroundColor,
                                                  child: profilePic != null
                                                      ? CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  profilePic),
                                                          radius: 25
                                                              .r, // Size of the profile image
                                                        )
                                                      : CircleAvatar(
                                                          radius: 25
                                                              .r, // Size of the profile image
                                                          backgroundColor:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 20.sp,
                                                            color: Colors.grey,
                                                          ), // Replace with your image URL
                                                        ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              SizedBox(
                                                width: 140.w,
                                                // color: Colors.orange,
                                                child: CustomText(
                                                  text: activityLog.actorName ??
                                                      "",
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                  size: 17,
                                                  maxLines: 2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 0.w),
                                          child: SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start, // Align text to the top
                                                  children: [
                                                    HeroIcon(
                                                      HeroIcons.envelope,
                                                      style:
                                                          HeroIconStyle.outline,
                                                      color: AppColors
                                                          .projDetailsSubText,
                                                      size: 20.sp,
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth: 180
                                                              .w), // Adjust width accordingly
                                                      child: CustomText(
                                                        text: activityLog
                                                                .message ??
                                                            "No message",
                                                        color: Colors.grey,
                                                        size: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        maxLines: null,
                                                        softwrap: true,
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10.w,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    HeroIcon(
                                                      HeroIcons.clock,
                                                      style:
                                                          HeroIconStyle.outline,
                                                      color: AppColors
                                                          .projDetailsSubText,
                                                      size: 20.sp,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    Container(
                                                      // width: 220.w,
                                                      alignment:
                                                          Alignment.topLeft,
                                                      // color: Colors.orange,
                                                      child: CustomText(
                                                        text: dateCreated,
                                                        color: Colors.grey,
                                                        size: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.w,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Divider(color: colors.darkColor),
                  ]),
            ),
            // Flexible(
            //   flex: 1,
            //   child: Container(
            //     // color: Colors.red,
            //     child: Image.asset(AppImages.activityImage,
            //         height: 70.h, width: 70.w),
            //   ),
            // )
          ],
        ));
  }

  void showToastWithProgress(BuildContext context, double progress) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.4),
              color: Theme.of(context).colorScheme.containerDark,
            ),

            // height: 50.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text:
                        "Downloading... ${(progress * 100).toStringAsFixed(0)} %",
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 15.sp,
                  ),
                  SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        Theme.of(context).colorScheme.textClrChange,
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Remove after a few seconds or upon completion
    Future.delayed(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}
