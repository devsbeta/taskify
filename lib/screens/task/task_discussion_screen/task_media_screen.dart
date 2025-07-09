import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/task_discussion/task_media/task_media_bloc.dart';
import '../../../bloc/task_discussion/task_media/task_media_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/colors.dart';
import '../../../config/constants.dart';
import '../../../config/strings.dart';
import '../../../data/model/project/media.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/shake_widget.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/no_data.dart';
import '../../widgets/no_permission_screen.dart';
import '../../widgets/search_field.dart';
import '../../widgets/speech_to_text.dart';

class TaskMediaScreen extends StatefulWidget {
  final int? id;
  const TaskMediaScreen({super.key,this.id});

  @override
  State<TaskMediaScreen> createState() => _TaskMediaScreenState();
}

class _TaskMediaScreenState extends State<TaskMediaScreen> {
  TextEditingController mediaSearchController = TextEditingController();
  bool? isLoading = true;
  String mediaSearchQuery = '';
  bool? isFirst;
  bool isLoadingMore = false;
  bool? isFirstTimeUSer;
  final GlobalKey _one = GlobalKey();

  late SpeechToTextHelper speechHelper;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          mediaSearchController.text = result;
       });
        Navigator.pop(context);
      },
    );
    _getFirstTimeUser();
    speechHelper.initSpeech();
    BlocProvider.of<TaskMediaBloc>(context).add(TaskMediaList(id: widget.id));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

}
  void _onDeleteTaskMedia({required int id}) {

    context.read<TaskMediaBloc>().add(DeleteTaskMedia(id: id));

  }
  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    // filterCount = 0;

    BlocProvider.of<TaskMediaBloc>(context).add(TaskMediaList(id: widget.id));

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }
  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
  }
  void onShowCaseCompleted() {
    _setIsFirst(false);
  }
  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: context.read<PermissionsBloc>().isManageTask== true
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
                                .read<TaskMediaBloc>()
                                .add(TaskSearchMedia("", widget.id));
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
                                context, mediaSearchController, SearchPopUp());
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
                    .read<TaskMediaBloc>()
                    .add(TaskSearchMedia(value, widget.id));

              },
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: BlocConsumer<TaskMediaBloc, TaskMediaState>(
                listener: (context, state) {
                  if (state is TaskMediaPaginated) {
                    isLoadingMore = false;
                    setState(() {});
                  } else if (state is TaskDownloadSuccess) {
                    BlocProvider.of<TaskMediaBloc>(context)
                        .add(TaskMediaList(id: widget.id));
                    flutterToastCustom(
                        msg: "Download completed: ${state.fileName}",
                        color: AppColors.primary);
                  } else if (state is TaskDownloadFailure) {
                    flutterToastCustom(
                        msg: "Download failed: ${state.error}",
                        color: AppColors.primary);
                  } else if (state is TaskDownloadInProgress) {
                    showToastWithProgress(context, state.progress);
                    if (state.progress == 0.0) {
                      BlocProvider.of<TaskMediaBloc>(context)
                          .add(TaskMediaList(id: widget.id));
                    }
                  } else if (state is TaskMediaDeleteSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!
                            .deletedsuccessfully,
                        color: AppColors.red);
                    BlocProvider.of<TaskMediaBloc>(context)
                        .add(TaskMediaList(id: widget.id));
                  }
                  ;
                },
                builder: (context, state) {
                  if (state is TaskMediaLoading) {
                    return const NotesShimmer();
                  } else if (state is TaskMediaPaginated) {
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
                          .isManageTask ==
                          true
                          ? state.TaskMediaList.isNotEmpty
                          ? ListView.builder(
                          padding: EdgeInsets.only(
                              left: 18.w,
                              right: 18.w,
                              bottom: 70.h),
                          // physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.hasReachedMax
                              ? state.TaskMediaList.length
                              : state.TaskMediaList.length + 1,
                          itemBuilder: (context, index) {
                            if (index <
                                state.TaskMediaList.length) {
                              MediaModel media =
                              state.TaskMediaList[index];
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

                              return (index == 0 || isFirstTimeUSer == true) ?
                              ShakeWidget(
                                child: Showcase(
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
                                            state.TaskMediaList,
                                            index,
                                            media,
                                            startDate,
                                            endDate))),
                              )
                                  : index == 0 ||
                                  isFirstTimeUSer == false
                                  ? mediaCard(
                                      state.TaskMediaList,
                                      index,
                                      media,
                                      startDate,
                                      endDate)
                                  : mediaCard(
                                  state.TaskMediaList,
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
                  } else if (state is TaskMediaError) {
                    // Show error message
                    return const NotesShimmer();
                  }else if(state is TaskMediaUploadSuccess){
                    BlocProvider.of<TaskMediaBloc>(context).add(TaskMediaList(id: widget.id));

                  }else if (state is TaskMediaError){
                    BlocProvider.of<TaskMediaBloc>(context).add(TaskMediaList(id: widget.id));

                  }
                  // Handle other states
                  return Container();
                },
              ),
            )
          ],
        )
            : const NoPermission());
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
  Widget mediaCard(
      projectMedia,
      index,
      media,
      startDate,
      endDate,
      ) {
    return DismissibleCard(
      direction: context.read<PermissionsBloc>().isdeleteTask == true &&
          context.read<PermissionsBloc>().iseditTask == true
          ? DismissDirection.horizontal // Allow both directions
          : context.read<PermissionsBloc>().isdeleteTask == true
          ? DismissDirection.endToStart // Allow delete
          : context.read<PermissionsBloc>().iseditTask == true
          ? DismissDirection.startToEnd // Allow edit
          : DismissDirection.none,
      title: index.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (context.read<PermissionsBloc>().iseditTask == true) {
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
            context.read<PermissionsBloc>().isdeleteTask == true) {
          // Wait for the animation to complete before removing the item
          Future.delayed(Duration(milliseconds: 300), () {
            setState(() {
              projectMedia.removeAt(index);
            });
            _onDeleteTaskMedia(id: media.id);
          });
        }
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: "#${media.id.toString()}",
                              size: 14.sp,
                              color: Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            InkWell(
                              onTap: () {
                                print("DZgfxzg ${media.file}");
                                context
                                    .read<TaskMediaBloc>()
                                    .add(TaskStartDownload(
                                    fileUrl: media.file,
                                    fileName: media.fileName));

                                // downloadFile(media.file,media.fileName);
                              },
                              child:GlowContainer(
                                shape: BoxShape.circle,
                                glowColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.6),
                                child: CircleAvatar(
                                  radius: 15.sp,
                                  backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                                  child: HeroIcon(
                                    HeroIcons.arrowDown,
                                    style: HeroIconStyle.outline,
                                    size: 15.sp,
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h,),
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
}
