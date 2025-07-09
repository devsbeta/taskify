
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';

import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/birthday/birthday_bloc.dart';
import '../../../bloc/birthday/birthday_event.dart';
import '../../../bloc/birthday/birthday_state.dart';
import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/clients/client_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/constants.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/list_of_user.dart';
import '../widgets/number_picker.dart';

class UpcomingBirthday extends StatefulWidget {
  final Function(List<String>, List<int>) onSelected;
  const UpcomingBirthday({super.key, required this.onSelected});

  @override
  State<UpcomingBirthday> createState() => _UpcomingBirthdayState();
}

class _UpcomingBirthdayState extends State<UpcomingBirthday> {
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  String searchWord = "";
  String searchWordClient = "";
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];

  List<int> clientSelectedId = [];
  List<String> clientSelectedname = [];
  final ValueNotifier<int> _currentValue =
      ValueNotifier<int>(7); // Using ValueNotifier

  @override
  void initState() {
    super.initState();
    dayController.text = _currentValue.value.toString(); // Sync initial text
    dayController.addListener(() {
      int? newValue = int.tryParse(dayController.text);
      if (newValue != null && newValue >= 1 && newValue <= 366) {
        _currentValue.value = newValue; // Notify listeners
      }
    });
    BlocProvider.of<BirthdayBloc>(context).add(WeekBirthdayList(7, [], []));
    BlocProvider.of<UserBloc>(context).add(UserList());
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            titleTask(
              context,
              AppLocalizations.of(context)!.upcomingBirthday,
            ),
          ],
        ),
        _birthdayFilter(dayController),
        _birthdayBloc(isLightTheme)
      ],
    );
  }

  Widget _birthdayFilter(TextEditingController dayController) {
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 20.h),
      child: SizedBox(
        height: 50.h,
        width: double.infinity,  // Ensures it has a width
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(  // ✅ Constrains Row inside SingleChildScrollView
            child: Row(
              children: [
                _selectMembers(),
                SizedBox(width: 10.w),
                _selectClient(),
                SizedBox(width: 10.w),
                _selectDays(dayController),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _selectMembers() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () async {
          showDialog(
            context: context,
            builder: (ctx) => BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 40.0,
                  );
                }
                if (state is UserSuccess) {
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge) {
                      if (scrollController.position.pixels != 0) {
                        BlocProvider.of<UserBloc>(context)
                            .add(UserLoadMore(searchWord));
                      }
                    }
                  });

                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.r), // Set the desired radius here
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.alertBoxBackGroundColor,
                      contentPadding: EdgeInsets.zero,
                      title: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
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
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.w),
                                child: SizedBox(
                                  // color: Colors.red,
                                  height: 35.h,
                                  width: double.infinity,
                                  child: TextField(
                                    cursorColor: AppColors.greyForgetColor,
                                    cursorWidth: 1,
                                    controller: _userSearchController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: (35.h - 20.sp) / 2,
                                        horizontal: 10.w,
                                      ),
                                      hintText:
                                          AppLocalizations.of(context)!.search,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors
                                              .greyForgetColor, // Set your desired color here
                                          width:
                                              1.0, // Set the border width if needed
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Optional: adjust the border radius
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: AppColors
                                              .purple, // Border color when TextField is focused
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchWord = value;
                                      });

                                      context
                                          .read<UserBloc>()
                                          .add(SearchUsers(value));
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                      content: Container(
                        constraints: BoxConstraints(maxHeight: 900.h),
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: state.user.length,
                            itemBuilder: (BuildContext context, int index) {
                              // if (index <  state.user.length) {

                              final isSelected = userSelectedId
                                  .contains(state.user[index].id!);

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.h),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        userSelectedId
                                            .remove(state.user[index].id!);
                                        userSelectedname.remove(
                                            state.user[index].firstName!);
                                      } else {
                                        userSelectedId
                                            .add(state.user[index].id!);
                                        userSelectedname
                                            .add(state.user[index].firstName!);
                                      }

                                      BlocProvider.of<UserBloc>(context).add(
                                          SelectedUser(index,
                                              state.user[index].firstName!));
                                      BlocProvider.of<UserBloc>(context).add(
                                        ToggleUserSelection(
                                          index,
                                          state.user[index].firstName!,
                                        ),
                                      );
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
                                        // borderRadius: BorderRadius
                                        //     .circular(15),
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                      ),
                                      child: Center(
                                        child: CustomText(
                                          text: state.user[index].firstName!,
                                          fontWeight: FontWeight.w400,
                                          size: 18,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              // }
                            }),
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: CreateCancelButtom(
                            title: AppLocalizations.of(context)!.ok,
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
                if (state is UserPaginated) {
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge) {
                      if (scrollController.position.pixels != 0) {
                        BlocProvider.of<UserBloc>(context)
                            .add(UserLoadMore(searchWord));
                      }
                    }
                  });

                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.r), // Set the desired radius here
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.alertBoxBackGroundColor,
                      // backgroundColor: Theme.of(context)
                      //     .colorScheme
                      //     .AlertBoxBackGroundColor,
                      contentPadding: EdgeInsets.zero,
                      title: Center(
                        child: Column(
                          children: [
                            CustomText(
                              text: AppLocalizations.of(context)!.selectusers,
                              fontWeight: FontWeight.w800,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .whitepurpleChange,
                            ),
                            const Divider(),
                            SizedBox(
                              // color: Colors.red,
                              height: 35.h,
                              width: double.infinity,
                              child: TextField(
                                cursorColor: AppColors.greyForgetColor,
                                cursorWidth: 1,
                                controller: _userSearchController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: (35.h - 20.sp) / 2,
                                    horizontal: 10.w,
                                  ),
                                  hintText:
                                      AppLocalizations.of(context)!.search,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors
                                          .greyForgetColor, // Set your desired color here
                                      width:
                                          1.0, // Set the border width if needed
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: adjust the border radius
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors
                                          .purple, // Border color when TextField is focused
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchWord = value;
                                  });
                                  context
                                      .read<UserBloc>()
                                      .add(SearchUsers(value));
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            )
                          ],
                        ),
                      ),
                      content: Container(
                        constraints: BoxConstraints(maxHeight: 900.h),
                        width: MediaQuery.of(context).size.width,
                        child: BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                          if (state is UserPaginated) {
                            ScrollController scrollController =
                                ScrollController();
                            scrollController.addListener(() {
                              // !state.hasReachedMax
                              if (scrollController.position.atEdge) {
                                if (scrollController.position.pixels != 0) {
                                  BlocProvider.of<UserBloc>(context)
                                      .add(UserLoadMore(searchWord));
                                }
                              }
                            });
                            return ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: state.hasReachedMax
                                    ? state.user.length
                                    : state.user.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index < state.user.length) {
                                    final isSelected = userSelectedId
                                        .contains(state.user[index].id!);

                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.h, vertical: 5.h),
                                      child: InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            setState(() {
                                              final isSelected =
                                                  userSelectedId.contains(
                                                      state.user[index].id!);

                                              if (isSelected) {
                                                // Remove the selected ID and corresponding username
                                                final removeIndex =
                                                    userSelectedId.indexOf(
                                                        state.user[index].id!);
                                                userSelectedId.removeAt(
                                                    removeIndex); // Sync with widget.usersid
                                                userSelectedname.removeAt(
                                                    removeIndex); // Remove corresponding username
                                              } else {
                                                // Add the selected ID and corresponding username
                                                userSelectedId
                                                    .add(state.user[index].id!);
                                                // Sync with widget.usersid
                                                userSelectedname.add(state
                                                    .user[index]
                                                    .firstName!); // Add corresponding username
                                              }

                                              // Trigger any necessary UI or Bloc updates
                                              BlocProvider.of<BirthdayBloc>(
                                                      context)
                                                  .add(WeekBirthdayList(
                                                      _currentValue.value,
                                                      userSelectedId,
                                                      clientSelectedId));
                                              widget.onSelected(
                                                  userSelectedname,
                                                  userSelectedId);
                                              BlocProvider.of<UserBloc>(context)
                                                  .add(SelectedUser(
                                                      index,
                                                      state.user[index]
                                                          .firstName!));
                                              BlocProvider.of<UserBloc>(context)
                                                  .add(ToggleUserSelection(
                                                      index,
                                                      state.user[index]
                                                          .firstName!));
                                            });
                                          },
                                          child: ListOfUser(
                                            isUser: true,
                                            isSelected: isSelected,
                                            user: state.user[index],
                                          )),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      child: Center(
                                        child: state.hasReachedMax
                                            ? const Text('')
                                            : const SpinKitFadingCircle(
                                                color: AppColors.primary,
                                                size: 40.0,
                                              ),
                                      ),
                                    );
                                  }
                                });
                          }
                          return Container();
                        }),
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: CreateCancelButtom(
                            title: AppLocalizations.of(context)!.ok,
                            onpressCancel: () {
                              _userSearchController.clear();
                              userSelectedId=[];
                              userSelectedname=[];
                              widget.onSelected([],[]);
                              Navigator.pop(context);
                            },
                            onpressCreate: () {
                              _userSearchController.clear();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    );
                  });
                }
                return Container();
              },
            ),
          );
        },
        child: Container(
          alignment: Alignment.center,
          height: 40.h,
          // width: 120.w, //
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor, width: 0.5),
              color: Theme.of(context).colorScheme.containerDark,
              borderRadius:
                  BorderRadius.circular(12)), // Set the height of the dropdown
          child: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: userSelectedname.isNotEmpty
                            ? userSelectedname.join(", ")
                            : AppLocalizations.of(context)!.selectmembers,
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 14.sp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
  Widget   _selectClient() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () async {
          showDialog(
            context: context,
            builder: (ctx) => BlocBuilder<ClientBloc, ClientState>(
              builder: (context, state) {
                print("erjfberfkj $state");
                if (state is ClientLoading) {
                  return const SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 40.0,
                  );
                }
                if (state is ClientSuccess) {
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge) {
                      if (scrollController.position.pixels != 0) {
                        BlocProvider.of<ClientBloc>(context)
                            .add(ClientLoadMore(searchWordClient));
                      }
                    }
                  });

                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.r), // Set the desired radius here
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.alertBoxBackGroundColor,
                      contentPadding: EdgeInsets.zero,
                      title: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
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
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.w),
                                child: SizedBox(
                                  // color: Colors.red,
                                  height: 35.h,
                                  width: double.infinity,
                                  child: TextField(
                                    cursorColor: AppColors.greyForgetColor,
                                    cursorWidth: 1,
                                    controller: _clientSearchController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: (35.h - 20.sp) / 2,
                                        horizontal: 10.w,
                                      ),
                                      hintText:
                                          AppLocalizations.of(context)!.search,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors
                                              .greyForgetColor, // Set your desired color here
                                          width:
                                              1.0, // Set the border width if needed
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Optional: adjust the border radius
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: AppColors
                                              .purple, // Border color when TextField is focused
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchWord = value;
                                      });

                                      context
                                          .read<ClientBloc>()
                                          .add(SearchClients(value));
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                      content: Container(
                        constraints: BoxConstraints(maxHeight: 900.h),
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: state.client.length,
                            itemBuilder: (BuildContext context, int index) {
                              // if (index <  state.user.length) {

                              final isSelected = clientSelectedId
                                  .contains(state.client[index].id!);
print("erjfberfkj ${ state.client[index].firstName!}");
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.h),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        clientSelectedId
                                            .remove(state.client[index].id!);
                                        clientSelectedname.remove(
                                            state.client[index].firstName!);
                                      } else {
                                        clientSelectedId
                                            .add(state.client[index].id!);
                                        clientSelectedname
                                            .add(state.client[index].firstName!);
                                      }

                                      BlocProvider.of<ClientBloc>(context).add(
                                          SelectedClient(index,
                                              state.client[index].firstName!));
                                      BlocProvider.of<ClientBloc>(context).add(
                                        ToggleClientSelection(
                                          index,
                                          state.client[index].firstName!,
                                        ),
                                      );
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
                                        // borderRadius: BorderRadius
                                        //     .circular(15),
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                      ),
                                      child: Center(
                                        child: CustomText(
                                          text: state.client[index].firstName!,
                                          fontWeight: FontWeight.w400,
                                          size: 18,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              // }
                            }),
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: CreateCancelButtom(
                            title: AppLocalizations.of(context)!.ok,
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
                if (state is ClientPaginated) {
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge) {
                      if (scrollController.position.pixels != 0) {
                        BlocProvider.of<ClientBloc>(context)
                            .add(ClientLoadMore(searchWord));
                      }
                    }
                  });

                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.r), // Set the desired radius here
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.alertBoxBackGroundColor,
                      // backgroundColor: Theme.of(context)
                      //     .colorScheme
                      //     .AlertBoxBackGroundColor,
                      contentPadding: EdgeInsets.zero,
                      title: Center(
                        child: Column(
                          children: [
                            CustomText(
                              text: AppLocalizations.of(context)!.selectclient,
                              fontWeight: FontWeight.w800,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .whitepurpleChange,
                            ),
                            const Divider(),
                            SizedBox(
                              // color: Colors.red,
                              height: 35.h,
                              width: double.infinity,
                              child: TextField(
                                cursorColor: AppColors.greyForgetColor,
                                cursorWidth: 1,
                                controller: _clientSearchController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: (35.h - 20.sp) / 2,
                                    horizontal: 10.w,
                                  ),
                                  hintText:
                                      AppLocalizations.of(context)!.search,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors
                                          .greyForgetColor, // Set your desired color here
                                      width:
                                          1.0, // Set the border width if needed
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: adjust the border radius
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors
                                          .purple, // Border color when TextField is focused
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchWord = value;
                                  });
                                  context
                                      .read<ClientBloc>()
                                      .add(SearchClients(value));
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            )
                          ],
                        ),
                      ),
                      content: Container(
                        constraints: BoxConstraints(maxHeight: 900.h),
                        width: MediaQuery.of(context).size.width,
                        child:ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: state.hasReachedMax
                                    ? state.client.length
                                    : state.client.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index < state.client.length) {
                                    final isSelected = clientSelectedId
                                        .contains(state.client[index].id!);

                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.h, vertical: 5.h),
                                      child: InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            setState(() {
                                              final isSelected =
                                                  clientSelectedId.contains(
                                                      state.client[index].id!);

                                              if (isSelected) {
                                                // Remove the selected ID and corresponding username
                                                final removeIndex =
                                                    clientSelectedId.indexOf(
                                                        state.client[index].id!);
                                                clientSelectedId.removeAt(
                                                    removeIndex); // Sync with widget.usersid
                                                clientSelectedname.removeAt(
                                                    removeIndex); // Remove corresponding username
                                              } else {
                                                // Add the selected ID and corresponding username
                                                clientSelectedId
                                                    .add(state.client[index].id!);
                                                // Sync with widget.usersid
                                                clientSelectedname.add(state
                                                    .client[index]
                                                    .firstName!); // Add corresponding username
                                              }

                                              // Trigger any necessary UI or Bloc updates
                                              BlocProvider.of<BirthdayBloc>(
                                                      context)
                                                  .add(WeekBirthdayList(
                                                      _currentValue.value,
                                                      userSelectedId,
                                                      clientSelectedId));
                                              widget.onSelected(
                                                  clientSelectedname,
                                                  clientSelectedId);
                                              BlocProvider.of<ClientBloc>(context)
                                                  .add(SelectedClient(
                                                      index,
                                                      state.client
                                                      [index]
                                                          .firstName!));
                                              BlocProvider.of<ClientBloc>(context)
                                                  .add(ToggleClientSelection(
                                                      index,
                                                      state.client[index]
                                                          .firstName!));
                                            });
                                          },
                                          child: ListOfUser(
                                            isUser: false,
                                            isSelected: isSelected,
                                            client: state.client[index],
                                          )),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      child: Center(
                                        child: state.hasReachedMax
                                            ? const Text('')
                                            : const SpinKitFadingCircle(
                                                color: AppColors.primary,
                                                size: 40.0,
                                              ),
                                      ),
                                    );
                                  }
                                })

                      ),
                      actions: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: CreateCancelButtom(
                            title: AppLocalizations.of(context)!.ok,
                            onpressCancel: () {
                              _clientSearchController.clear();
                              clientSelectedId=[];
                              clientSelectedname=[];
                              widget.onSelected([],[]);
                              Navigator.pop(context);
                            },
                            onpressCreate: () {
                              _clientSearchController.clear();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    );
                  });
                }
                return Container();
              },
            ),
          );
        },
        child: Container(
          alignment: Alignment.center,
          height: 40.h,
          // width: 120.w, //
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor, width: 0.5),
              color: Theme.of(context).colorScheme.containerDark,
              borderRadius:
                  BorderRadius.circular(12)), // Set the height of the dropdown
          child: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: clientSelectedname.isNotEmpty
                            ?clientSelectedname.join(", ")
                            : AppLocalizations.of(context)!.selectclient,
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 14.sp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  void _showNumberPickerDialog(dayController) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    showDialog(
      context: context,
      builder: (context) => CustomNumberPickerDialog(
        dayController: dayController,
        currentValue: _currentValue,
        isLightTheme: currentTheme is LightThemeState,
        onSubmit: (value) {
          BlocProvider.of<BirthdayBloc>(context)
              .add(WeekBirthdayList(value, userSelectedId, clientSelectedId));
        },
      ),
    );
  }

  Widget _selectDays(dayController) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () async {},
        child: ValueListenableBuilder<int>(
          valueListenable: _currentValue,
          builder: (context, value, child) {
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: InkWell(
                    onTap: () {
                      _showNumberPickerDialog(dayController);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: CustomText(
                            text: value == 7
                                ? AppLocalizations.of(context)!.sevendays
                                : "$value ${AppLocalizations.of(context)!.days}",
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 14.sp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value == 7
                            ? SizedBox.shrink()
                            : InkWell(
                                onTap: () {
                                  _currentValue.value = 7;
                                  dayController.text = "7";
                                  BlocProvider.of<BirthdayBloc>(context).add(
                                      WeekBirthdayList(
                                          7, userSelectedId, clientSelectedId));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greyColor,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(5.h),
                                    child: HeroIcon(
                                      HeroIcons.xMark,
                                      style: HeroIconStyle.outline,
                                      color: AppColors.pureWhiteColor,
                                      size: 15.sp,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _birthdayList(hasReachedMax, birthdayState, isLightTheme) {
    return SizedBox(
      height: 225.h,
      width: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.only(right: 18.w, top: 5.h),
          // physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount:
              hasReachedMax ? birthdayState.length : birthdayState.length + 1,
          itemBuilder: (context, index) {
            if (index < birthdayState.length) {
              var birthday = birthdayState[index];
              String? dob = formatDateFromApi(birthday.dob!, context);
              return InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  router.push('/userdetail', extra: {
                    "id": birthday.id,
                  });

                },
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 18.w),
                  child: Container(
                    width: 250.w,
                    // height: 300.h,
                    decoration: BoxDecoration(
                        boxShadow: [
                          isLightTheme
                              ? MyThemes.lightThemeShadow
                              : MyThemes.darkThemeShadow,
                        ],
                        color: Theme.of(context).colorScheme.containerDark,
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 40.r,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: NetworkImage(birthday
                                    .photo!), // Replace with actual image
                              ),

                               Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [

                                        RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${birthday.birthdayCount!}",
                                          style: TextStyle(
                                            fontSize:
                                                40.sp, // Bigger size for "26"
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: Offset(0,
                                                -10), // Moves "th" slightly up
                                            child: CustomText(
                                              text:
                                                  "${getOrdinalSuffix(birthday.birthdayCount!)}",

                                              size: 18
                                                  .sp, // Smaller size for "th"
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomText(
                                    text:
                                        "${AppLocalizations.of(context)!.birthdattoday}",
                                    size: 12.sp,
                                    color: AppColors.projDetailsSubText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: birthday.member!,
                                size: 22.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                              // SizedBox(height: 5.h),
                              birthday.daysLeft! == 0
                                  ? CustomText(
                                      text:
                                          " ${AppLocalizations.of(context)!.today}",
                                      size: 16.sp,
                                      color: AppColors.projDetailsSubText,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : SizedBox(),
                            ],
                          ),
                       SizedBox(
                                  height: 10.h,
                                ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              birthday.daysLeft!.toString() == "0"
                                  ? SizedBox()
                                  : Text(
                                      AppLocalizations.of(context)!.daysLeft,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10.sp,
                                      ),
                                    ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.cake,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.blueColor,
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      CustomText(
                                        text: dob,
                                        color: AppColors.greyColor,
                                        size: 14,
                                        fontWeight: FontWeight.w500,
                                      )
                                    ],
                                  ),
                                  birthday.daysLeft!.toString() == "0"
                                      ? SizedBox()
                                      : Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            "${birthday.daysLeft!.toString()}",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightWhite,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Show a loading indicator when more notes are being loaded
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Center(
                  child: hasReachedMax
                      ? const Text('')
                      : const SpinKitFadingCircle(
                          color: AppColors.primary,
                          size: 40.0,
                        ),
                ),
              );
            }
          }),
    );
  }

  Widget _birthdayBloc(isLightTheme) {
    return BlocBuilder<BirthdayBloc, BirthdayState>(
      builder: (context, state) {
        if (state is TodaysBirthdayLoading) {
          return const NotesShimmer();
        } else if (state is TodayBirthdaySuccess) {
          return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!state.hasReachedMax &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  context.read<BirthdayBloc>().add(
                      LoadMoreBirthday(_currentValue.value, userSelectedId));
                }
                return false;
              },
              child: state.birthday.isNotEmpty
                  ? _birthdayList(
                      state.hasReachedMax, state.birthday, isLightTheme)
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 12.h),
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              boxShadow: [
                                isLightTheme
                                    ? MyThemes.lightThemeShadow
                                    : MyThemes.darkThemeShadow,
                              ],
                              color:
                                  Theme.of(context).colorScheme.containerDark,
                              borderRadius: BorderRadius.circular(12)),
                          child: NoData(
                            isImage: false,
                          )),
                    ));
        } else if (state is BirthdayError) {
          // Show error message
        }
        // Handle other states
        return const SizedBox.shrink();
      },
    );
  }
}
