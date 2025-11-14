import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:intl/intl.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/meetings/meeting_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/l10n/app_localizations.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../config/constants.dart';
import '../../data/GlobalVariable/globalvariable.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/toast_widget.dart';
import '../task/Widget/users_field.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';

import '../widgets/clients_field.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../widgets/custom_textfields/custom_textfield.dart';

class CreateMeetingScreen extends StatefulWidget {
  final bool? isCreate;

  final int? id;
  const CreateMeetingScreen({super.key, this.isCreate, this.id});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController dojController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController addrerssController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  String initialCountry = defaultCountry;
  PhoneNumber number = PhoneNumber(isoCode: defaultCountry);
  String selectedUser = '';
  bool? isLoading;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  List<int>? selectedClientId;
  List<String>? selectedClient;
  List<String>? usersName;
  List<int>? selectedusersNameId;
  String? fromDate;
  String? toDate;
  String? strtTime;
  String? endTime;
  String? formattedTimeStart;
  String? formattedTimeEnd;
  DateTime? selectedDateStarts;
  DateTime? selectedDateEnds;
  TimeOfDay? _timestart;
  String? startDateFromState;
  String? endDateFromState;
  TimeOfDay? _timeend;
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    // Convert TimeOfDay to DateTime
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

    // Format to 12-hour time (hh:mm AM/PM)
    return DateFormat('hh:mm a').format(dateTime);
  }

  void _selectstartTime() async {
    // Show the time picker dialog
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timestart ??
          TimeOfDay.now(), // Use current time if _timestart is null
    );

    // If the user picks a valid time
    if (newTime != null) {
      setState(() {
        _timestart = newTime; // Update _timestart with the selected time
        // Format time as HH:MM
        formattedTimeStart =
            '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _selectendTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeend ?? TimeOfDay.now(),
    );

    if (newTime != null) {
      setState(() {
        _timeend = newTime;

        // Format as HH:MM
        formattedTimeEnd =
            '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void handleUsersSelected(List<String> category, List<int> catId) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;
    });
  }

  void handleClientSelected(List<String> category, List<int> catId) {
    setState(() {
      selectedClient = category;
      selectedClientId = catId;
    });
  }

  String selectedCategory = '';

  List<Color> statusColor = [
    Colors.orange,
    Colors.lightBlueAccent,
    Colors.deepPurpleAccent,
    Colors.red
  ];
  FocusNode? phoneFocus,
      emailFocus,
      addressFocus,
      cityFocus,
      stateFocus,
      countryFocus,
      zipFocus = FocusNode();

  List<int>? listOfuserId = [];
  List<int>? listOfclientId = [];
  void onCreateMeeting(BuildContext context) {
    if (titleController.text.isNotEmpty &&
        fromDate != null &&
        fromDate!.isNotEmpty &&
        toDate != null &&
        toDate!.isNotEmpty &&
        formattedTimeStart != null &&
        formattedTimeEnd != null) {
      setState(() {
        isLoading = true;
      });
      final meetingBloc = BlocProvider.of<MeetingBloc>(context);
      meetingBloc.add(AddMeetings(
        MeetingModel(
          title: titleController.text,
          startDate: fromDate!,
          endDate: toDate!,
          startTime: formattedTimeStart!,
          endTime: formattedTimeEnd!,
          userIds: selectedusersNameId ?? [],
          clientIds: selectedClientId ?? [],
        ),
      ));
      setState(() {
        isLoading = false;
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void onUpdateMeeting({
    required BuildContext context,
    required int id,
    required MeetingModel meeting
  }) {
    print("jkdnvm  ${titleController.text}");
    print("jkdnvm  ${fromDate}");
    print("jkdnvm  ${meeting.startDate}");
    print("jkdnvm  ${titleController.text}");
    if (titleController.text.isEmpty ||
        (formattedTimeStart == null && meeting.startTime == null) ||
        (formattedTimeEnd == null && meeting.endTime == null)) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final meetingBloc = BlocProvider.of<MeetingBloc>(context);

    // Create updated meeting model with proper fallbacks
    final updatedMeeting = MeetingModel(
      id: id,
      title: titleController.text,
      startDate: fromDate ?? meeting.startDate,
      endDate: toDate ?? meeting.endDate,
      startTime: formattedTimeStart ?? meeting.startTime,
      endTime: formattedTimeEnd ?? meeting.endTime,
      userIds: selectedusersNameId ?? listOfuserId ?? meeting.userIds ?? [],
      clientIds: selectedClientId ?? listOfclientId ?? meeting.clientIds ?? [],
    );

    meetingBloc.add(MeetingUpdateds(updatedMeeting));
  }

  String formatDate(String date) {
    // Parse the input date string
    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);

    // Format it to the desired output
    return DateFormat('dd, MMM yyyy').format(parsedDate);
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

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  appbar(isLightTheme),
                  SizedBox(height: 30.h),
                  body(isLightTheme)
                ],
              ),
            ),
          );
  }

  Widget appbar(isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ]),
                  // color: Colors.red,
                  // width: 300.w,
                  child: BackArrow(
                    title: widget.isCreate == true
                        ? AppLocalizations.of(context)!.createmeeting
                        : AppLocalizations.of(context)!.editmeeting,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget body(isLightTheme) {
    return SingleChildScrollView(child:
        BlocConsumer<MeetingBloc, MeetingState>(
            listener: (context, state) {
              print("Listener Bloc $state");
              if (state is MeetingCreateError) {
                setState(() {
                  isLoading = false;
                });
                flutterToastCustom(msg: state.errorMessage);
              }
              if (state is MeetingError) {
                setState(() {
                  isLoading = false;
                });
                flutterToastCustom(msg: state.errorMessage);
              }
              if (state is MeetingEditError) {
                setState(() {
                  isLoading = false;
                });
                flutterToastCustom(msg: state.errorMessage);
                BlocProvider.of<MeetingBloc>(context).add(const MeetingLists());
              }
              if (state is MeetingEditSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.updatedsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<MeetingBloc>(context).add(const MeetingLists());
                Future.delayed(Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              }
              if (state is MeetingCreateSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(navigatorKey.currentContext!)!
                        .createdsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<MeetingBloc>(context).add(const MeetingLists());
                Future.delayed(Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              }
              if (state is MeetingCreateSuccessLoading) {
                setState(() {
                  isLoading = true;
                });
              }

            },
            builder: (context, state) {
              print("jkndfvm  $state");
              if (state is MeetingPaginated) {
        for (MeetingModel meeting in state.meeting) {


            var startDateApi = parseDateStringFromApi(meeting.startDate!);
            var startDate = dateFormatConfirmed(startDateApi, context);
            selectedDateStarts = startDateApi;
            print("selectedDateStarts $selectedDateStarts");
            var endDateApi = parseDateStringFromApi(meeting.endDate!);
            var endDate = dateFormatConfirmed(endDateApi, context);
            selectedDateEnds = endDateApi;
            startDateFromState = meeting.startDate;
            endDateFromState = meeting.endDate;
            print("zdgfb aS $selectedDateEnds");
            List<String>? listOfuser = [];
            // if (widget.meetingModel != null) {
            for (var ids in meeting.users!) {
              listOfuser.add(ids.firstName!);
              listOfuserId!.add(ids.id!);
              // }
            }
            List<String>? listOfclients = [];

            for (var ids in meeting.clients!) {
              listOfclients.add(ids.firstName!);
              listOfclientId!.add(ids.id!);
            }
            _timestart = convertToTimeOfDay(meeting.startTime!);
            _timeend = convertToTimeOfDay(meeting.endTime!);
            titleController = TextEditingController(text: meeting.title!);
            startsController = TextEditingController(text: startDate);
            endController = TextEditingController(text: endDate);

            print("fhnvd c ${endController.text}");
            formattedTimeStart = meeting.startTime;
            formattedTimeEnd = meeting.endTime;
            usersName = listOfuser;
            selectedClient = listOfclients;
            startsController = TextEditingController(
                text: "$startDate  -  $endDate"
            );
            print("ifklm $formattedTimeEnd");
            print("_timestart $_timestart");
            print("ifklm $formattedTimeStart");
            print("lgzkdrfm dgtd $startDate");
            print("lgzkdrfm $endDate");

          return MeetingCard(isLightTheme,);
        }
      }

      return MeetingCard(isLightTheme,);
    }));
  }
Widget MeetingCard(isLightTheme,){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          title: AppLocalizations.of(context)!.title,
          hinttext: AppLocalizations.of(context)!.pleaseentertitle,
          controller: titleController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: DatePickerWidget(
            dateController: startsController,
            // Use only one controller
            title: AppLocalizations.of(context)!.date,
            titlestartend: AppLocalizations.of(context)!.selectstartenddate,
            onTap: () {
              showCustomDateRangePicker(
                context,
                dismissible: true,
                minimumDate: DateTime(1900),
                maximumDate: DateTime(9999),
                endDate: selectedDateEnds,
                startDate: selectedDateStarts,
                backgroundColor: Theme.of(context).colorScheme.containerDark,
                primaryColor: AppColors.primary,
                onApplyClick: (start, end) {
                  setState(() {
                    selectedDateEnds = end;
                    selectedDateStarts = start;

                    // Show both start and end dates in the same controller
                    startsController.text =
                    "${dateFormatConfirmed(selectedDateStarts!, context)}  -  ${dateFormatConfirmed(selectedDateEnds!, context)}";

                    // Assign values for API submission
                    fromDate = dateFormatConfirmedToApi(start);
                    toDate = dateFormatConfirmedToApi(end);
                  });
                },
                onCancelClick: () {
                  setState(() {
                    // Handle cancellation if needed
                  });
                },
              );
            },
            isLightTheme: isLightTheme,
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              startTime(isLightTheme),
              SizedBox(
                width: 10.w,
              ),
              endTimeOfMeeting(isLightTheme)
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        UsersField(
            isMeeting: true,
            isRequired: false,
            isCreate: widget.isCreate!,
            usersname: usersName ?? [],
            usersid: listOfuserId!,
            project: const [],
            // index: widget.index,
            onSelected: handleUsersSelected),
        SizedBox(
          height: 15.h,
        ),
        ClientField(
            isCreate: widget.isCreate!,
            usersname: selectedClient ?? [],
            clientsid: listOfclientId!,
            project: const [],
            onSelected: handleClientSelected),
        SizedBox(
          height: 15.h,
        ),
        CreateCancelButtom(
          isLoading: isLoading,
          isCreate: widget.isCreate,
          onpressCreate: widget.isCreate == true
              ? () async {
            onCreateMeeting(context);
          }
              : () {
            print("lgzkdrfm $formattedTimeStart");
            print("lgzkdrfm $fromDate");
            print("lgzkdrfm $toDate");

            // Get current meeting model from state or create fallback
            final currentMeeting = MeetingModel(
              id: widget.id,
              title: titleController.text,
              startDate: fromDate??startDateFromState,
              endDate: toDate??endDateFromState,
              startTime: formattedTimeStart,
              endTime: formattedTimeEnd,
              userIds: listOfuserId,
              clientIds: listOfclientId,
            );

            onUpdateMeeting(
                context: context,
                id: widget.id!,
                meeting: currentMeeting
            );
          },
          onpressCancel: () {
            Navigator.pop(context);
          },
        )
      ],
    );
}
  Widget startsField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.starts,
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
        SizedBox(
          height: 5.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          height: 40.h,
          width: double.infinity,
          // margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
            readOnly: true,
            onTap: () {
              // Call the date picker here when tapped
              showCustomDateRangePicker(
                context,
                dismissible: true,
                minimumDate: DateTime.now().subtract(const Duration(days: 30)),
                maximumDate: DateTime.now().add(const Duration(days: 30)),
                endDate: selectedDateEnds,
                startDate: selectedDateStarts,
                backgroundColor: Theme.of(context).colorScheme.containerDark,
                primaryColor: AppColors.primary,
                onApplyClick: (start, end) {
                  setState(() {
                    if (start.isBefore(DateTime.now())) {
                      start = DateTime
                          .now(); // Reset the start date to today if earlier
                    }

                    // If the end date is not selected or is null, set it to the start date
                    if (end.isBefore(start) || selectedDateEnds == null) {
                      end =
                          start; // Set the end date to the start date if not selected
                    }
                    selectedDateEnds = end;
                    selectedDateStarts = start;

                    startsController.text =
                        dateFormatConfirmed(selectedDateStarts!, context);
                    endController.text =
                        dateFormatConfirmed(selectedDateEnds!, context);
                    fromDate = dateFormatConfirmed(start, context);
                    toDate = dateFormatConfirmed(end, context);
                  });
                },
                onCancelClick: () {
                  setState(() {
                    // Handle cancellation if necessary
                  });
                },
              );
            },
            controller: startsController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.selectdate,
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.greyForgetColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: (50.h - 20.sp) / 2,
                horizontal: 10.w,
              ),
              // contentPadding: EdgeInsets.only(
              //     bottom: 15.h, left: 10.w,right: 10.w
              // ),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget endsField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.ends,
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
        SizedBox(
          height: 5.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          // decoration: DesignConfiguration.shadow(),
          child: TextFormField(
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
            readOnly: true,
            controller: endController,
            keyboardType: TextInputType.text,
            // validator: (val) => StringValidation.validateField(
            //   val!,
            //   getTranslated(context, 'required'),
            // ),
            cursorColor: AppColors.greyForgetColor,
            cursorWidth: 1.w,
            enableInteractiveSelection: false,
            onSaved: (String? value) {
              // context.read<AuthenticationProvider>().setSingUp(value);
            },
            onFieldSubmitted: (v) {
              // _fieldFocusChange(
              //   context,
              //   firstnameFocus!,
              //   lastnameFocus,
              // );
            },
            decoration: InputDecoration(
                // labelText: "firstname",
                hintText: AppLocalizations.of(context)!.selectdate,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: AppColors.greyForgetColor),
                labelStyle: const TextStyle(
                  // fontFamily: fontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.greyForgetColor,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: (50.h - 20.sp) / 2,
                  horizontal: 10.w,
                ), // Centext vertically
                border: InputBorder.none),
          ),
        )
      ],
    );
  }

  Widget startTime(isLightTheme) {
    return Expanded(
        child: Container(
            // margin: EdgeInsets.only(left: 20.w, right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            height: 40.h,
            // margin: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectstartTime();
                  });
                },
                child: Row(
                  children: [
                    const HeroIcon(
                        size: 20,
                        HeroIcons.clock,
                        style: HeroIconStyle.outline,
                        color: AppColors.greyForgetColor),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: widget.isCreate == true
                          ? (_timestart != null
                              ? _timestart!.format(context)
                              : "Select Time") // Check for null before calling `format`
                          : formattedTimeStart??"",
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    )
                  ],
                ),
              ),
            )));
  }

  Widget endTimeOfMeeting(isLightTheme) {
    return Expanded(
        child: Container(
            // margin: EdgeInsets.only(right: 20.w, left: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            height: 40.h,
            // margin: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectendTime();
                  });
                },
                child: Row(
                  children: [
                    const HeroIcon(
                        size: 20,
                        HeroIcons.clock,
                        style: HeroIconStyle.outline,
                        color: AppColors.greyForgetColor),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: widget.isCreate == true
                          ? (_timeend != null
                              ? _timeend!.format(context)
                              : "Select Time")
                          : formattedTimeEnd??"",
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                  ],
                ),
              ),
            )));
  }
}
