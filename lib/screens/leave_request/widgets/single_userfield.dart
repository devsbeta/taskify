import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../bloc/single_user/single_user_bloc.dart';
import '../../../bloc/single_user/single_user_event.dart';
import '../../../bloc/single_user/single_user_state.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_cancel_create_button.dart';

class SingleUserField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  // final List<StatusModel> status;
  final int? index;
  final bool? isEditLeaveReq;
  final List<int>? userId;
  final Function(String, int) onSelected;
  const SingleUserField(
      {super.key,
        required this.isCreate,
        this.name,
        this.userId,
        this.isEditLeaveReq,
        // required this.status,
        required this.index,
        required this.onSelected});

  @override
  State<SingleUserField> createState() => _SingleUserFieldState();
}

class _SingleUserFieldState extends State<SingleUserField> {
  String? usersname;
  int? usersId;
  List<int> userSelectedId = [];
  @override
  void initState() {
    if (widget.isCreate == false && widget.index != null) {
      usersname = widget.name;
      usersId = widget.index;
      userSelectedId.addAll(widget.userId!);
      // Dispatch event to select initial user
      BlocProvider.of<SingleUserBloc>(context).add(
        SelectSingleUser(widget.index!, widget.name!),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<SingleUserBloc>(context)
        .add(SingleUserList(offset: 0, limit: 100));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text:AppLocalizations.of(context)!.user,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              const CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h,),
        BlocBuilder<SingleUserBloc, SingleUserState>(
          builder: (context, state) {
            if (state is SingleUserInitial) {
            } else if (state is SingleUserLoading) {
              return const Text("");
            } else if (state is SingleUserSuccess) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        // Fetch statuses
                       widget.isCreate == false ?SizedBox(): showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocBuilder<SingleUserBloc, SingleUserState>(
                                builder: (context, state) {
                                  if (state is SingleUserSuccess) {
                                    ScrollController scrollController =
                                    ScrollController();
                                    scrollController.addListener(() {
                                      if (scrollController.position.atEdge) {
                                        if (scrollController.position.pixels !=
                                            0) {
                                          // We're at the bottom
                                          BlocProvider.of<SingleUserBloc>(context)
                                              .add(SingleUserLoadMore());
                                        }
                                      }
                                    });

                                    return StatefulBuilder(builder: (BuildContext
                                    context,
                                        void Function(void Function()) setState) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),  // Set the desired radius here
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        title: Center(
                                          child: Column(
                                            children: [
                                              CustomText(
                                                text: AppLocalizations.of(context)!.selectuser,
                                                fontWeight: FontWeight.w800,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .whitepurpleChange,
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        ),
                                        content: Container(
                                          constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                          width:MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: state.user.length + 1,
                                            itemBuilder:
                                                (BuildContext context, int index) {
                                              if (index == state.user.length) {
                                                return state.isLoadingMore
                                                    ? Padding(
                                                  padding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 8.h),
                                                  child: const Center(
                                                      child:
                                                      CircularProgressIndicator()),
                                                )
                                                    : const SizedBox.shrink();
                                              }

                                              final isSelected =
                                              userSelectedId.contains(
                                                  state.user[index].id!);
                                              // final isSelected = widget.userId?.contains(state.user[index].id);

                                                  return InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  setState(() {

                                                    if (widget.isCreate == true) {
                                                      // Clear previous selections if it's single-select
                                                      userSelectedId.clear();

                                                      // Get the selected user's name and ID
                                                      usersname = state.user[index].firstName!;
                                                      usersId = state.user[index].id!;

                                                      // Add the currently selected user's ID
                                                      userSelectedId.add(usersId!);


                                                      // Trigger the callback to pass the selected name and ID
                                                      widget.onSelected(usersname!, usersId!);
                                                    }
                                                    else {
                                                      userSelectedId.clear();
                                                      usersname = state.user[index].firstName;
                                                      usersname = state.user[index].firstName!;
                                                      usersId = state.user[index].id!;
                                                      userSelectedId.add(usersId!);

                                                      widget.onSelected(usersname!, usersId!);
                                                    }
                                                  });
                                                  BlocProvider.of<SingleUserBloc>(
                                                      context)
                                                      .add(SelectSingleUser(
                                                      index,
                                                      state.user[index]
                                                          .firstName!));

                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20.w),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? AppColors.purpleShade
                                                            : Colors.transparent,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                        border: Border.all(
                                                            color: isSelected
                                                                ? AppColors.primary
                                                                : Colors
                                                                .transparent)),
                                                    width: double.infinity,
                                                    height: 35.h,
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 18.w),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex:4,
                                                              child: SizedBox(
                                                                // width: 170.w,
                                                                // color: Colors.red,
                                                                child: CustomText(
                                                                  text: state
                                                                      .user[index]
                                                                      .firstName!,
                                                                  fontWeight:
                                                                  FontWeight.w500,
                                                                  size: 18.sp,
                                                                  color: isSelected
                                                                      ? AppColors.primary
                                                                      : Theme.of(
                                                                      context)
                                                                      .colorScheme
                                                                      .textClrChange,
                                                                ),
                                                              ),
                                                            ),
                                                            isSelected
                                                                ? Expanded(
                                                              flex:1,
                                                                  child: const HeroIcon(
                                                                  HeroIcons
                                                                      .checkCircle,
                                                                  style:
                                                                  HeroIconStyle
                                                                      .solid,
                                                                  color: AppColors
                                                                      .purple),
                                                                )
                                                                : const SizedBox.shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(top: 20.h),
                                            child: CreateCancelButtom(
                                              title: "OK",
                                              onpressCancel: () {
                                                Navigator.pop(context);
                                              },
                                              onpressCreate: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                                  }
                                  return const Center(child: Text('Loading...'));
                                },
                              ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true ?Colors.transparent: Theme.of(context).colorScheme.textfieldDisabled,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.greyColor),
                         ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                                text: widget.isCreate
                                    ? (usersname?.isEmpty ?? true
                                    ?AppLocalizations.of(context)!.selectuser
                                    : usersname!)
                                    : (usersname?.isEmpty ?? true
                                    ? widget.name!
                                    : usersname!),
                                // text:  Projectsname ,
                              fontWeight: FontWeight.w400,
                              size: 14.sp,
                              color: Theme.of(context).colorScheme.textClrChange,),
                            widget.isCreate == false ?SizedBox(): Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is SingleUserError) {
              return Text("ERROR ${state.errorMessage}");
            }
            return Container();
          },
        )
      ],
    );
  }
}