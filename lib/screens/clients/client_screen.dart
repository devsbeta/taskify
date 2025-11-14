import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/l10n/app_localizations.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../widgets/edit_delete_pop.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';

class ClientScreen extends StatefulWidget {
//   final String title;
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  TextEditingController searchController = TextEditingController();

  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();

  bool? isLoading = true;
  bool? isFirst = false;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  double level = 0.0;
  static final bool _onDevice = false;

  String searchword = "";
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  late SpeechToTextHelper speechHelper;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  final options = SpeechListenOptions(
      onDevice: _onDevice,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
      autoPunctuation: true,
      enableHapticFeedback: true);

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  void onDeleteClient(client) {
    context.read<ClientBloc>().add(DeleteClients(client));

    final clientt = context.read<ClientBloc>();
    clientt.stream.listen((state) {
      if (state is ClientDeleteSuccess) {
        router.push(
          '/client',
        );
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ClientDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  @override
  void initState() {
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
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context)
            .startShowCase([globalKeyOne, globalKeyTwo, globalKeyThree]));

    searchController.addListener(() {
      setState(() {});
    });
    listenForPermissions();
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ClientBloc>(context).add(ClientList());
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ClientBloc>().add(SearchClients(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<ClientBloc>(context).add(ClientList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.read<PermissionsBloc>().isManageClient;
    context.read<PermissionsBloc>().iscreateClient;
    context.read<PermissionsBloc>().iseditClient;
    context.read<PermissionsBloc>().isdeleteClient;

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: SizedBox(
                // height: 400,
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: BackArrow(
                        iSBackArrow: true,
                        iscreatePermission:
                            context.read<PermissionsBloc>().iscreateClient,
                        title: AppLocalizations.of(context)!.clientsFordrawer,
                        isAdd: context.read<PermissionsBloc>().iscreateClient,
                        onPress: () {
                          router.push(
                            '/createclient',
                            extra: {
                              'isCreate': true,
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 25.h),
                      child: CustomSearchField(
                        isLightTheme: isLightTheme,
                        controller: searchController,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Row(
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
                                      searchController.clear();
                                      // Optionally trigger the search event with an empty string
                                      context
                                          .read<ClientBloc>()
                                          .add(SearchClients(""));
                                    },
                                  ),
                                ),
                              IconButton(
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
                                    speechHelper.startListening(context,
                                        searchController, SearchPopUp());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        onChanged: (value) {
                          searchword = value;
                          context.read<ClientBloc>().add(SearchClients(value));
                          setState(() {});
                        },
                      ),
                    ),
                    // SizedBox(height: 20.h),
                    Expanded(
                      child: Container(
                          color: Theme.of(context).colorScheme.backGroundColor,
                          child: RefreshIndicator(
                              color: AppColors.primary, // Spinner color
                              backgroundColor:
                                  Theme.of(context).colorScheme.backGroundColor,
                              onRefresh: _onRefresh,
                              child: _clientGridList(isLightTheme))),
                    )
                  ],
                ),
              ),
            ));
  }

  Widget _clientGridList(isLightTheme) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientInitial) {
          return GridShimmer(
            count: 10,
          );
        } else if (state is ClientLoading) {
          return GridShimmer(
            count: 10,
          );
        } else if (state is ClientPaginated) {
        } else if (state is ClientError) {
          return Text("ERROR ${state.errorMessage}");
        }
        return AbsorbPointer(
          absorbing: false,
          child: BlocBuilder<ClientBloc, ClientState>(
            builder: (context, state) {
              if (state is ClientPaginated) {
                return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!state.hasReachedMax &&
                          state.isLoading &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent;
                        BlocProvider.of<ClientBloc>(context)
                            .add(ClientLoadMore(searchword));
                      }
                      return false;
                    },
                    child: context
                        .read<PermissionsBloc>()
                        .isManageClient ==
                        true ?state.client.isNotEmpty
                        ? Stack(children: [
                            MasonryGridView.count(
                              padding: EdgeInsets.only(
                                  top: 0.h,
                                  bottom: 50.h,
                                  left: 18.w,
                                  right: 18.w),
                              crossAxisCount: 2,
                              mainAxisSpacing: 13,
                              crossAxisSpacing: 15,
                              itemCount: state.hasReachedMax
                                  ? state.client.length
                                  : state.client.length + 1,
                              itemBuilder: (context, index) {
                                if (index < state.client.length) {
                                  bool? hasPhoneNumber;

                                  hasPhoneNumber =
                                      state.client[index].phone != null &&
                                          state.client[index].phone!.isNotEmpty;
                                  // AllClientModel client = state.client[index];
                                  return _clientListCard(
                                      state.client[index].id,
                                      hasPhoneNumber,
                                      isLightTheme,
                                      index,
                                      state.client[index],
                                      state.client,
                                      state.isLoading);
                                } else {
                                  return SizedBox.shrink();
                                  // return CircularProgressIndicatorCustom(
                                  //   hasReachedMax: state.hasReachedMax,
                                  // );
                                }
                              },
                            ),
                          ])
                        : NoData(
                            isImage: true,
                          ):NoPermission());
              }
              return SizedBox.shrink();
              // return GridShimmer(count: 2,);
            },
          ),
        );
      },
    );
  }

  Widget _clientListCard(
      clientId, hasPhone, isLightTheme, index, clientIndex, client, isLoading) {
    return Padding(
      padding: EdgeInsets.only(top: 0.w),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          router.push(
            '/clientdetails',
            extra: {
              "isClient": "client",
              "id": clientId, // Pass the specific client object directly
            },
          );

          // router.push(
          //   '/Clientdetail',
          //   extra: {
          //     'req': [
          //       state.Client[index].toJson()
          //     ],
          //     'index': index
          //   },
          // );
        },
        child: Container(
          height: hasPhone == false ? 205.h : 225.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: "#${clientIndex.id!}",
                      size: 12.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                      fontWeight: FontWeight.w600,
                    ),
                    context.read<PermissionsBloc>().iseditClient == true ||
                            context.read<PermissionsBloc>().isdeleteClient ==
                                true
                        ? SizedBox(
                            // color: Colors.red,
                            height: 30.h,
                            child: Row(
                              children: [
                                Container(
                                  width: 30.w,
                                  // n color: Colors.yellow,
                                  margin: EdgeInsets.zero,
                                  padding: EdgeInsets.zero,

                                  child: CustomPopupMenuButton(
                                    isEditAllowed: context
                                            .read<PermissionsBloc>()
                                            .iseditClient ==
                                        true,
                                    isDeleteAllowed: context
                                            .read<PermissionsBloc>()
                                            .isdeleteClient ==
                                        true,
                                    onSelected: (value) {
                                      if (value == 'Edit') {
                                        router.push(
                                          '/createclient',
                                          extra: {
                                            'isCreate': false,
                                            "index": index,
                                            "client": client,
                                            "clientModel": clientIndex
                                          },
                                        );
                                      } else if (value == "Delete") {
                                        // if (isDemo ) {
                                        //   flutterToastCustom(
                                        //       msg: AppLocalizations.of(context)!
                                        //           .isDemooperation);
                                        // } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10
                                                        .r), // Set the desired radius here
                                              ),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .alertBoxBackGroundColor,
                                              title: Text(
                                                AppLocalizations.of(context)!
                                                    .confirmDelete,
                                              ),
                                              content: Text(
                                                AppLocalizations.of(context)!
                                                    .areyousure,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    onDeleteClient(
                                                        clientIndex.id);
                                                    context
                                                        .read<ClientBloc>()
                                                        .add(ClientList());
                                                    Navigator.of(context).pop(
                                                        true); // Confirm deletion
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        false); // Cancel deletion
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        // }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                Row(
                  children: [
                    clientIndex.profile != null
                        ? CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 20.r,
                            backgroundImage: NetworkImage(clientIndex.profile!),
                          )
                        : CircleAvatar(
                            radius: 20.r,
                            backgroundColor: Colors.grey[200],
                          ),
                    SizedBox(
                      width: 10.h,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 70.w,
                          // color: Colors.red,
                          child: CustomText(
                            text: clientIndex.firstName!,
                            size: 14.sp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            color: Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 70.w,
                          // color: Colors.red,
                          child: CustomText(
                            text: clientIndex.email!,
                            size: 12.sp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            color: Theme.of(context).colorScheme.colorChange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  width: 150.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          CustomText(
                            text:
                                AppLocalizations.of(context)!.projectwithCounce,
                            size: 12.sp,
                            color: Theme.of(context).colorScheme.colorChange,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                            // height: 15.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: CustomText(
                                text: clientIndex.assigned != null
                                    ? clientIndex.assigned!.projects.toString()
                                    : "0",
                                size: 12.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          CustomText(
                            text: AppLocalizations.of(context)!.tasks,
                            size: 12.sp,
                            color: Theme.of(context).colorScheme.colorChange,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                            // height: 15.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: CustomText(
                                text: clientIndex.assigned!.tasks.toString(),
                                size: 12.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  width: 150.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            text: AppLocalizations.of(context)!.status,
                            size: 12.sp,
                            color: Theme.of(context).colorScheme.colorChange,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          clientIndex.status == 1
                              ? Column(
                                  children: [
                                    Container(
                                      height: 20.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Center(
                                        child: CustomText(
                                          text:
                                              "Active", // Ensure status is treated as a string
                                          size: 10.sp,
                                          color: AppColors.pureWhiteColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: 20.h,
                                  width: 60.w,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                    child: CustomText(
                                      text:
                                          "InActive", // Ensure status is treated as a string
                                      size: 10.sp,
                                      color: AppColors.pureWhiteColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60.w,
                            child: CustomText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: AppLocalizations.of(context)!.emailverified,
                              size: 12.sp,
                              color: Theme.of(context).colorScheme.colorChange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          clientIndex.emailVerificationMailSent == 1
                              ? Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  // height: 20.h,
                                  // width: 60.w,
                                  // decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                    child: HeroIcon(
                                      HeroIcons.checkBadge,
                                      style: HeroIconStyle.solid,
                                      size: 20.sp,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  // height: 20.h,
                                  // width: 60.w,
                                  // decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                    child: HeroIcon(
                                      HeroIcons.exclamationCircle,
                                      style: HeroIconStyle.solid,
                                      size: 20.sp,
                                      color: Colors.orange,
                                    ),
                                  ),
                                )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                clientIndex.phone != null && clientIndex.phone != ""
                    ? Row(
                        children: [
                          HeroIcon(
                            HeroIcons.phone,
                            style: HeroIconStyle.solid,
                            size: 12.sp,
                            color: Theme.of(context).colorScheme.textFieldColor,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          CustomText(
                            text: clientIndex.phone != null
                                ? clientIndex.phone!
                                : "",
                            size: 12.sp,
                            color: Theme.of(context).colorScheme.colorChange,
                            fontWeight: FontWeight.w400,
                            letterspace: 2,
                          ),
                        ],
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
