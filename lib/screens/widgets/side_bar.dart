import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/activity_log/activity_log_bloc.dart';
import '../../bloc/activity_log/activity_log_event.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../bloc/notes/notes_event.dart';

import '../../bloc/notifications/system_notification/notification_bloc.dart';
import '../../bloc/notifications/system_notification/notification_event.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/todos/todos_bloc.dart';
import '../../bloc/todos/todos_event.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../routes/routes.dart';
import '../dash_board/dashboard.dart';


class SideBar extends StatefulWidget {
  final SlidableBarController? controller;
  final Widget? underWidget;
  final String? hasGuard;
  final BuildContext context;

  const SideBar({super.key, this.underWidget, this.hasGuard,this.controller,required this.context});
  @override
  State<SideBar> createState() => _SideBarState();

}

class _SideBarState extends State<SideBar> {
  bool _isSidebarVisible = false; // Track the visibility state

  @override
  Widget build(BuildContext context) {
    final permissionsBloc = BlocProvider.of<PermissionsBloc>(context);

    return SlidableBar(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      duration: Duration(milliseconds: 50),
      clicker: Container(
        width: 50.w,
        height: 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.backGroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(70),
              bottomLeft: Radius.circular(70)
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 0.w),
          child: IconButton(
            splashColor: Colors.transparent, // Disable the splash color
           highlightColor: Colors.transparent,
            icon: Icon(
              _isSidebarVisible ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: AppColors.greyColor, // Set the icon color
            ),
            onPressed: () {
              setState(() {
                _isSidebarVisible = !_isSidebarVisible; // Toggle visibility state
              });
              if (_isSidebarVisible) {
                widget.controller!.show(); // Show the sidebar
              } else {
                widget.controller!.hide(); // Hide the sidebar
              }
            },
          ),
        ),
      ),
      frontColor: Colors.red,
      size: 60,
      slidableController: widget.controller,
      side: Side.right,
      clickerSize: 50.w,
      barChildren: [
        SizedBox(
            height: MediaQuery.of(context).size.height -
                60
                    .h, // Reduced by 30.h from top and bottomAdd padding to create space from top and bottom
            child: Center(
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          permissionsBloc.isManageProject == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DashBoard(
                                      initialIndex: 1), // Navigate to index 1
                                ),
                              );
                            },
                            child: const HeroIcon(
                              HeroIcons.wallet,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageProject == true
                              ? SizedBox(
                            height: 20.h,
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageTask == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DashBoard(
                                      initialIndex: 2), // Navigate to index 1
                                ),
                              );
                            },
                            child: const HeroIcon(
                              size: 26,
                              HeroIcons.documentCheck,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageTask == true
                              ? SizedBox(
                            height: 20.h,
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageWorkspace == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {

                              router.push('/workspaces',
                                  extra: {"fromNoti": false});
                            },
                            child: const HeroIcon(
                              HeroIcons.squares2x2,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageWorkspace == true
                              ? SizedBox(
                            height: 20.h,
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageSystemNotification == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push("/notification");
                              context
                                  .read<NotificationBloc>()
                                  .add(NotificationList());
                            },
                            child: const HeroIcon(
                              HeroIcons.bellAlert,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageSystemNotification == true
                              ? SizedBox(
                            height: 20.h,
                          )
                              : const SizedBox.shrink(),
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              context.read<TodosBloc>().add(const TodosList());
                              router.push("/todos");
                            },
                            child: const HeroIcon(
                              HeroIcons.barsArrowUp,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          permissionsBloc.isManageClient == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push("/client");
                              BlocProvider.of<ClientBloc>(context)
                                  .add(ClientList());
                              // GoRouter.of(context).push('/client', extra: 'Client');
                            },
                            child: const HeroIcon(
                              HeroIcons.userGroup,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageClient == true
                              ? const SizedBox(
                            height: 20,
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageUser == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push('/user');
                              BlocProvider.of<UserBloc>(context).add(UserList());
                            },
                            child: const HeroIcon(
                              HeroIcons.users,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageUser == true
                              ? const SizedBox(
                            height: 20,
                          )
                              : const SizedBox.shrink(),
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              context.read<NotesBloc>().add(const NotesList());
                              router.push('/notes');
                            },
                            child: const HeroIcon(
                              HeroIcons.newspaper,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          widget.hasGuard == "client"
                              ? const SizedBox.shrink()
                              : InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push('/leaverequest',
                                  extra: {"fromNoti": false});
                              // context.read<LeaveRequestBloc>().add(const LeaveRequestList("",0,[]));
                            },
                            child: const HeroIcon(
                              HeroIcons.arrowRightEndOnRectangle,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          widget.hasGuard == "client"
                              ? const SizedBox(
                            height: 20,
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageMeeting == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {

                              context
                                  .read<MeetingBloc>()
                                  .add(const MeetingLists());

                              router
                                  .push('/meetings', extra: {"fromNoti": false});
                            },
                            child: const HeroIcon(
                              HeroIcons.camera,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageMeeting == true
                              ? const SizedBox(
                            height: 20,
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageActivityLog == true
                              ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push("/activitylog");
                              BlocProvider.of<ActivityLogBloc>(context)
                                  .add(AllActivityLogList());
                            },
                            child: const HeroIcon(
                              HeroIcons.chartBar,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          )
                              : const SizedBox.shrink(),
                          permissionsBloc.isManageActivityLog == true
                              ? const SizedBox(
                            height: 20,
                          )
                              : const SizedBox.shrink(),
                        ]))))
      ],
      child: widget.underWidget!,
    );
  }
}
