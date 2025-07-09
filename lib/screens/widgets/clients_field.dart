import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../data/model/clients/client_model.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'custom_cancel_create_button.dart';

class ClientField extends StatefulWidget {
  final bool isCreate;
  final bool isRequired;
  final List<String> usersname;
  final List<int> clientsid;
  final List<ClientModel> project;
  final Function(List<String>, List<int>) onSelected;

  const ClientField({
    super.key,
    this.isRequired = false,
    required this.isCreate,
    required this.usersname,
    required this.project,
    required this.clientsid,
    required this.onSelected,
  });

  @override
  State<ClientField> createState() => _ClientFieldState();
}

class _ClientFieldState extends State<ClientField> {
  String? projectsname;
  int? projectsId;
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  String searchWord = "";

  final TextEditingController _clientSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize selected names and IDs based on isCreaB
    BlocProvider.of<ClientBloc>(context).add(ClientList());
    // if (!widget.isCreate) {
    //   userSelectedname = List.from(widget.usersname);
    // }
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.clientsid.length; i++) {
      final id = widget.clientsid[i];
      // final name = widget.usersname[i]; // Assuming widget.usersname contains the names in the same order as IDs

      // If userSelectedId doesn't contain this ID, add both the ID and the corresponding name
      if (!userSelectedId.contains(id)) {
        userSelectedId.add(id);
        if (widget.usersname.isNotEmpty) {
          userSelectedname.add(widget.usersname[i]);
        }
        // Add the corresponding name to userSelectedname
      }
    }

    // for (int i = 0; i < widget.clientsid.length; i++) {
    //   final id = widget.clientsid[i];
    //   final name = widget.usersname[i]; // Assuming widget.usersname contains the names in the same order as IDs
    //
    //   // If userSelectedId doesn't contain this ID, add both the ID and the corresponding name
    //   if (!userSelectedId.contains(id)) {
    //     userSelectedId.add(id);
    //     userSelectedname.add(name);  // Add the corresponding name to userSelectedname
    //   }
    // }

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.clients,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? const CustomText(
                      text: " *",
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: AppColors.red,
                      size: 15,
                      fontWeight: FontWeight.w400,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        // SizedBox(height: 5.h),
        BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {

            if (state is ClientInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                          color: Theme.of(context).colorScheme.containerDark,
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (userSelectedname.isNotEmpty
                                        ? userSelectedname.join(", ")
                                        : AppLocalizations.of(context)!
                                            .selectclient)
                                    : (widget.usersname.isNotEmpty
                                        ? widget.usersname.join(", ")
                                        : AppLocalizations.of(context)!
                                            .selectclient),
                                fontWeight: FontWeight.w400,
                                size: 12,
                                color: AppColors.greyForgetColor,
                                maxLines: 1,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            else if (state is ClientPaginated) {

              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {

                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocBuilder<ClientBloc, ClientState>(
                            builder: (context, state) {

                              if (state is ClientPaginated) {

                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {

                                      BlocProvider.of<ClientBloc>(context)
                                          .add(ClientLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .selectclient,
                                              fontWeight: FontWeight.w800,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .whitepurpleChange,
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 0.w),
                                              child: SizedBox(
                                                // color: Colors.red,
                                                height: 35.h,
                                                width: double.infinity,
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.greyForgetColor,
                                                  cursorWidth: 1,
                                                  controller:
                                                      _clientSearchController,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      vertical:
                                                          (35.h - 20.sp) / 2,
                                                      horizontal: 10.w,
                                                    ),
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .search,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors
                                                            .greyForgetColor, // Set your desired color here
                                                        width:
                                                            1.0, // Set the border width if needed
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0), // Optional: adjust the border radius
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
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
                                                        .add(SearchClients(
                                                            value));
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
                                      constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.client.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // if (index <  state.user.length) {

                                            final isSelected =
                                                userSelectedId.contains(
                                                    state.client[index].id!);

                                            return Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 20.h),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    if (isSelected) {
                                                      userSelectedId.remove(
                                                          state.client[index]
                                                              .id!);
                                                      userSelectedname.remove(
                                                          state.client[index]
                                                              .firstName!);
                                                    } else {
                                                      userSelectedId.add(state
                                                          .client[index].id!);
                                                      userSelectedname.add(state
                                                          .client[index]
                                                          .firstName!);

                                                    }
                                                    widget.onSelected(
                                                        userSelectedname,
                                                        userSelectedId);
                                                    BlocProvider.of<ClientBloc>(
                                                            context)
                                                        .add(SelectedClient(
                                                            index,
                                                            state.client[index]
                                                                .firstName!));
                                                    BlocProvider.of<ClientBloc>(
                                                            context)
                                                        .add(
                                                      ToggleClientSelection(
                                                        index,
                                                        state.client[index]
                                                            .firstName!,
                                                      ),
                                                    );
                                                  });
                                                },
                                                child: Padding(
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                      vertical: 2.h,
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? AppColors
                                                              .purpleShade
                                                              : Colors
                                                              .transparent,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              10),
                                                          border: Border.all(
                                                              color: isSelected
                                                                  ? AppColors
                                                                  .purple
                                                                  : Colors
                                                                  .transparent)),
                                                      width:
                                                      double.infinity,
                                                      // height: 40.h,
                                                      child: Center(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              10.w),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                SizedBox(
                                                                  width:
                                                                  200.w,
                                                                  child:
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 7,
                                                                        child: SizedBox(
                                                                          width: 200.w,
                                                                          child: Row(
                                                                            children: [
                                                                              CircleAvatar(
                                                                                radius: 20,
                                                                                backgroundImage: NetworkImage(state.client
                                                                                [index].profile!),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                                                                                  child: Column(
                                                                                    // Changed from Row to Column to stack vertically
                                                                                    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                                                                                    children: [
                                                                                      Row(
                                                                                        // First row with names
                                                                                        children: [
                                                                                          Flexible(
                                                                                            child: CustomText(
                                                                                              text: state.client[index].firstName!,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              size: 18.sp,
                                                                                              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(width: 5.w),
                                                                                          Flexible(
                                                                                            child: CustomText(
                                                                                              text: state.client[index].lastName!,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              size: 18.sp,
                                                                                              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      // SizedBox(height: 2.h),  // Add some spacing between rows
                                                                                      Row(
                                                                                        children: [
                                                                                          Flexible(
                                                                                            child: CustomText(
                                                                                              text: state.client[index].email!,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              size: 18.sp,
                                                                                              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              isSelected
                                                                  ? Expanded(
                                                                flex:
                                                                1,
                                                                child: const HeroIcon(HeroIcons.checkCircle,
                                                                    style: HeroIconStyle.solid,
                                                                    color: AppColors.purple),
                                                              )
                                                                  : const SizedBox
                                                                  .shrink(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                            );
                                            // }
                                          }),
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

                              return Container();
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                // color: Colors.red,
                                child: CustomText(
                                  text: widget.isCreate
                                      ? (userSelectedname.isNotEmpty
                                          ? userSelectedname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectclient)
                                      : (widget.usersname.isNotEmpty
                                          ? widget.usersname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectclient),
                                  fontWeight: FontWeight.w500,
                                  size: 14.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            else if (state is ClientError) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {

                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocBuilder<ClientBloc, ClientState>(
                                builder: (context, state) {

                                  if (state is ClientPaginated) {
                                    ScrollController scrollController =
                                    ScrollController();
                                    scrollController.addListener(() {
                                      if (scrollController.position.atEdge) {
                                        if (scrollController.position.pixels != 0) {

                                          BlocProvider.of<ClientBloc>(context)
                                              .add(ClientLoadMore(searchWord));
                                        }
                                      }
                                    });

                                    return StatefulBuilder(builder: (BuildContext
                                    context,
                                        void Function(void Function()) setState) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.r), // Set the desired radius here
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .alertBoxBackGroundColor,
                                        contentPadding: EdgeInsets.zero,
                                        title: Center(
                                          child: SizedBox(
                                            width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                            child: Column(
                                              children: [
                                                CustomText(
                                                  text:
                                                  AppLocalizations.of(context)!
                                                      .selectclient,
                                                  fontWeight: FontWeight.w800,
                                                  size: 20,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .whitepurpleChange,
                                                ),
                                                const Divider(),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.w),
                                                  child: SizedBox(
                                                    // color: Colors.red,
                                                    height: 35.h,
                                                    width: double.infinity,
                                                    child: TextField(
                                                      cursorColor:
                                                      AppColors.greyForgetColor,
                                                      cursorWidth: 1,
                                                      controller:
                                                      _clientSearchController,
                                                      decoration: InputDecoration(
                                                        contentPadding:
                                                        EdgeInsets.symmetric(
                                                          vertical:
                                                          (35.h - 20.sp) / 2,
                                                          horizontal: 10.w,
                                                        ),
                                                        hintText:
                                                        AppLocalizations.of(
                                                            context)!
                                                            .search,
                                                        enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: AppColors
                                                                .greyForgetColor, // Set your desired color here
                                                            width:
                                                            1.0, // Set the border width if needed
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              10.0), // Optional: adjust the border radius
                                                        ),
                                                        focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
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
                                                            .add(SearchClients(
                                                            value));
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
                                          constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                          width: MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                              controller: scrollController,
                                              shrinkWrap: true,
                                              itemCount: state.client.length,
                                              itemBuilder: (BuildContext context,
                                                  int index) {
                                                // if (index <  state.user.length) {

                                                final isSelected =
                                                userSelectedId.contains(
                                                    state.client[index].id!);

                                                return Padding(
                                                  padding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20.h),
                                                  child: InkWell(
                                                    splashColor: Colors.transparent,
                                                    onTap: () {
                                                      setState(() {
                                                        if (isSelected) {
                                                          userSelectedId.remove(
                                                              state.client[index]
                                                                  .id!);
                                                          userSelectedname.remove(
                                                              state.client[index]
                                                                  .firstName!);
                                                        } else {
                                                          userSelectedId.add(state
                                                              .client[index].id!);
                                                          userSelectedname.add(state
                                                              .client[index]
                                                              .firstName!);

                                                        }
                                                        widget.onSelected(
                                                            userSelectedname,
                                                            userSelectedId);
                                                        BlocProvider.of<ClientBloc>(
                                                            context)
                                                            .add(SelectedClient(
                                                            index,
                                                            state.client[index]
                                                                .firstName!));
                                                        BlocProvider.of<ClientBloc>(
                                                            context)
                                                            .add(
                                                          ToggleClientSelection(
                                                            index,
                                                            state.client[index]
                                                                .firstName!,
                                                          ),
                                                        );
                                                      });
                                                    },
                                                    child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          vertical: 2.h,
                                                        ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: isSelected
                                                                  ? AppColors
                                                                  .purpleShade
                                                                  : Colors
                                                                  .transparent,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  10),
                                                              border: Border.all(
                                                                  color: isSelected
                                                                      ? AppColors
                                                                      .purple
                                                                      : Colors
                                                                      .transparent)),
                                                          width:
                                                          double.infinity,
                                                          // height: 40.h,
                                                          child: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  10.w),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child:
                                                                    SizedBox(
                                                                      width:
                                                                      200.w,
                                                                      child:
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex: 7,
                                                                            child: SizedBox(
                                                                              width: 200.w,
                                                                              child: Row(
                                                                                children: [
                                                                                  CircleAvatar(
                                                                                    radius: 20,
                                                                                    backgroundImage: NetworkImage(state.client
                                                                                    [index].profile!),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                                                                                      child: Column(
                                                                                        // Changed from Row to Column to stack vertically
                                                                                        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                                                                                        children: [
                                                                                          Row(
                                                                                            // First row with names
                                                                                            children: [
                                                                                              Flexible(
                                                                                                child: CustomText(
                                                                                                  text: state.client[index].firstName!,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  maxLines: 1,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  size: 18.sp,
                                                                                                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 5.w),
                                                                                              Flexible(
                                                                                                child: CustomText(
                                                                                                  text: state.client[index].lastName!,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  maxLines: 1,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  size: 18.sp,
                                                                                                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          // SizedBox(height: 2.h),  // Add some spacing between rows
                                                                                          Row(
                                                                                            children: [
                                                                                              Flexible(
                                                                                                child: CustomText(
                                                                                                  text: state.client[index].email!,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  maxLines: 1,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  size: 18.sp,
                                                                                                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  isSelected
                                                                      ? Expanded(
                                                                    flex:
                                                                    1,
                                                                    child: const HeroIcon(HeroIcons.checkCircle,
                                                                        style: HeroIconStyle.solid,
                                                                        color: AppColors.purple),
                                                                  )
                                                                      : const SizedBox
                                                                      .shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                );
                                                // }
                                              }),
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

                                  return Container();
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                // color: Colors.red,
                                child: CustomText(
                                  text: widget.isCreate
                                      ? (userSelectedname.isNotEmpty
                                      ? userSelectedname.join(", ")
                                      : AppLocalizations.of(context)!
                                      .selectclient)
                                      : (widget.usersname.isNotEmpty
                                      ? widget.usersname.join(", ")
                                      : AppLocalizations.of(context)!
                                      .selectclient),
                                  fontWeight: FontWeight.w500,
                                  size: 14.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return AbsorbPointer(
              absorbing: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {

                      showDialog(
                        context: context,
                        builder: (ctx) =>
                            BlocBuilder<ClientBloc, ClientState>(
                              builder: (context, state) {

                                if (state is ClientPaginated) {
                                  ScrollController scrollController =
                                  ScrollController();
                                  scrollController.addListener(() {
                                    if (scrollController.position.atEdge) {
                                      if (scrollController.position.pixels != 0) {

                                        BlocProvider.of<ClientBloc>(context)
                                            .add(ClientLoadMore(searchWord));
                                      }
                                    }
                                  });

                                  return StatefulBuilder(builder: (BuildContext
                                  context,
                                      void Function(void Function()) setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: SizedBox(
                                          width:
                                          MediaQuery.of(context).size.width *
                                              0.9,
                                          child: Column(
                                            children: [
                                              CustomText(
                                                text:
                                                AppLocalizations.of(context)!
                                                    .selectclient,
                                                fontWeight: FontWeight.w800,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .whitepurpleChange,
                                              ),
                                              const Divider(),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0.w),
                                                child: SizedBox(
                                                  // color: Colors.red,
                                                  height: 35.h,
                                                  width: double.infinity,
                                                  child: TextField(
                                                    cursorColor:
                                                    AppColors.greyForgetColor,
                                                    cursorWidth: 1,
                                                    controller:
                                                    _clientSearchController,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                      EdgeInsets.symmetric(
                                                        vertical:
                                                        (35.h - 20.sp) / 2,
                                                        horizontal: 10.w,
                                                      ),
                                                      hintText:
                                                      AppLocalizations.of(
                                                          context)!
                                                          .search,
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: AppColors
                                                              .greyForgetColor, // Set your desired color here
                                                          width:
                                                          1.0, // Set the border width if needed
                                                        ),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10.0), // Optional: adjust the border radius
                                                      ),
                                                      focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
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
                                                          .add(SearchClients(
                                                          value));
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
                                        constraints:
                                        BoxConstraints(maxHeight: 900.h),
                                        width: MediaQuery.of(context).size.width,
                                        child: ListView.builder(
                                            controller: scrollController,
                                            shrinkWrap: true,
                                            itemCount: state.client.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              // if (index <  state.user.length) {

                                              final isSelected =
                                              userSelectedId.contains(
                                                  state.client[index].id!);

                                              return Padding(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20.h),
                                                child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (isSelected) {
                                                        userSelectedId.remove(
                                                            state.client[index]
                                                                .id!);
                                                        userSelectedname.remove(
                                                            state.client[index]
                                                                .firstName!);
                                                      } else {
                                                        userSelectedId.add(state
                                                            .client[index].id!);
                                                        userSelectedname.add(state
                                                            .client[index]
                                                            .firstName!);

                                                      }
                                                      widget.onSelected(
                                                          userSelectedname,
                                                          userSelectedId);
                                                      BlocProvider.of<ClientBloc>(
                                                          context)
                                                          .add(SelectedClient(
                                                          index,
                                                          state.client[index]
                                                              .firstName!));
                                                      BlocProvider.of<ClientBloc>(
                                                          context)
                                                          .add(
                                                        ToggleClientSelection(
                                                          index,
                                                          state.client[index]
                                                              .firstName!,
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                        vertical: 2.h,
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: isSelected
                                                                ? AppColors
                                                                .purpleShade
                                                                : Colors
                                                                .transparent,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                10),
                                                            border: Border.all(
                                                                color: isSelected
                                                                    ? AppColors
                                                                    .purple
                                                                    : Colors
                                                                    .transparent)),
                                                        width:
                                                        double.infinity,
                                                        // height: 40.h,
                                                        child: Center(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                10.w),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  flex: 4,
                                                                  child:
                                                                  SizedBox(
                                                                    width:
                                                                    200.w,
                                                                    child:
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex: 7,
                                                                          child: SizedBox(
                                                                            width: 200.w,
                                                                            child: Row(
                                                                              children: [
                                                                                CircleAvatar(
                                                                                  radius: 20,
                                                                                  backgroundImage: NetworkImage(state.client
                                                                                  [index].profile!),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                                                                                    child: Column(
                                                                                      // Changed from Row to Column to stack vertically
                                                                                      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                                                                                      children: [
                                                                                        Row(
                                                                                          // First row with names
                                                                                          children: [
                                                                                            Flexible(
                                                                                              child: CustomText(
                                                                                                text: state.client[index].firstName!,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                maxLines: 1,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                size: 18.sp,
                                                                                                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: 5.w),
                                                                                            Flexible(
                                                                                              child: CustomText(
                                                                                                text: state.client[index].lastName!,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                maxLines: 1,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                size: 18.sp,
                                                                                                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        // SizedBox(height: 2.h),  // Add some spacing between rows
                                                                                        Row(
                                                                                          children: [
                                                                                            Flexible(
                                                                                              child: CustomText(
                                                                                                text: state.client[index].email!,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                maxLines: 1,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                size: 18.sp,
                                                                                                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                isSelected
                                                                    ? Expanded(
                                                                  flex:
                                                                  1,
                                                                  child: const HeroIcon(HeroIcons.checkCircle,
                                                                      style: HeroIconStyle.solid,
                                                                      color: AppColors.purple),
                                                                )
                                                                    : const SizedBox
                                                                    .shrink(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                              );
                                              // }
                                            }),
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

                                return Container();
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              // color: Colors.red,
                              child: CustomText(
                                text: widget.isCreate
                                    ? (userSelectedname.isNotEmpty
                                    ? userSelectedname.join(", ")
                                    : AppLocalizations.of(context)!
                                    .selectclient)
                                    : (widget.usersname.isNotEmpty
                                    ? widget.usersname.join(", ")
                                    : AppLocalizations.of(context)!
                                    .selectclient),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
