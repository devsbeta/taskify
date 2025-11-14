import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';
import 'package:taskify/l10n/app_localizations.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/client_id/clientid_bloc.dart';
import '../../bloc/client_id/clientid_event.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'dart:io';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../data/repositories/Profile/profile_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_switch.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';

import '../widgets/validation.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class CreateEditClientScreen extends StatefulWidget {
  final bool? isCreate;
  final bool? fromDetail;
  final int? index;
  final AllClientModel? clientModel;
  const CreateEditClientScreen(
      {super.key,
      this.isCreate,
      this.index,
      this.clientModel,
      this.fromDetail});

  @override
  State<CreateEditClientScreen> createState() => _CreateEditClientScreenState();
}

class _CreateEditClientScreenState extends State<CreateEditClientScreen> {
  AllClientModel? currentClient;
  String? countryCode;
  String? countryIsoCode;
  int? _selectedStateIndex = 1;
  int? _selectedEmailVeriIndex = 0;
  bool? isLoading;
  int? clientId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController dojController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController conpasswordController = TextEditingController();
  TextEditingController addrerssController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();

  String? formatteddobDate;
  String? formatteddojDate;
  String? selectedLabel;
  String? selectedemailLabel;
  int? stateSelectedIndex;
  int? emailSelectedIndex;
  String? dob;
  String? doj;
  String? selectedRoleName;
  int? selectedRoleId;
  DateTime? parsedDate;
  String? formattedDoj;
  String? formattedDob;
  DateTime? selectedDobDate;
  DateTime? selectedDojDate;
  File? _image;
  String? filepath;
  String initialCountry = defaultCountry;
  PhoneNumber number = PhoneNumber(isoCode: defaultCountry);
  bool? hasPermission;
  DateTime? selectedDateStarts;
  DateTime? selectedDateEnds;
  bool isInternalPurpose = false;
  int? userId;
  bool? hasAllDataAccess;
  String? role;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String selectedCategory = '';

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  List<Color> statusColor = [
    Colors.orange,
    Colors.lightBlueAccent,
    Colors.deepPurpleAccent,
    Colors.red
  ];
  FocusNode? phoneFocus,
      firstnameFocus,
      lastnameFocus,
      emailFocus,
      addressFocus,
      cityFocus,
      companyFocus,
      stateFocus,
      countryFocus,
      passwardFocus,
      conpasswardFocus,
      dobFocus,
      dojFocus,
      zipFocus = FocusNode();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (widget.isCreate == false) {
        await ProfileRepo().updateProfile(
            type: "client",
            profile: File(pickedFile.path),
            id: widget.clientModel!.id!); // Save the selected image
      }
      setState(() {

        filepath = pickedFile.name;
        _image = File(pickedFile.path);
      });
    } else {
    }
  }

  Widget profileImageField(isLightTheme) {
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
                text: AppLocalizations.of(context)!.profilePicture,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            // padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              // color: Colors.red,
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  InkWell(
                    highlightColor: Colors.transparent, // No highlight on tap
                    splashColor: Colors.transparent,
                    onTap: () {

                      _pickImage();
                    },
                    child: _image == null
                        ? CustomText(
                            text: AppLocalizations.of(context)!.choosefile,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          )
                        : CustomText(
                            text: AppLocalizations.of(context)!.choosefile,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Container(
                    color: AppColors.greyForgetColor,
                    // color: colors.red,
                    height: 40.h,
                    width: 0.5.w,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  widget.isCreate == true
                      ? _image == null
                          ? SizedBox(
                              width: 200.w,
                              child: CustomText(
                                text:
                                    AppLocalizations.of(context)!.nofilechosen,
                                fontWeight: FontWeight.w400,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : SizedBox(
                              // color: Colors.red,
                              width: 200.w,
                              child: CustomText(
                                overflow: TextOverflow.ellipsis,
                                text: filepath!,
                                fontWeight: FontWeight.w400,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            )
                      : SizedBox(
                          // color: Colors.red,
                          width: 200.w,
                          child: CustomText(
                              overflow: TextOverflow.ellipsis,
                              text: filepath!,
                              fontWeight: FontWeight.w400,
                              size: 12,
                              maxLines: 1,
                              color: AppColors.greyForgetColor),
                        ),
                ],
              ),
            )),
        SizedBox(
          height: 15.w,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 25,
            backgroundImage: filepath != null
                ? (filepath!.startsWith("http")
                    ? NetworkImage(filepath!) as ImageProvider
                    : FileImage(File(_image!.path)) as ImageProvider)
                : null,
            child: filepath == null && _image == null
                ? Icon(
                    Icons.person,
                    size: 25.sp,
                    color: Colors.grey.shade200,
                  )
                : null, // Optionally provide a placeholder or handle null case
          ),
        )
      ],
    );
  }

  void onCreateClient() {
    if (firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      if (!emailController.text.contains('@')) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleaseenteravalidemail,
        );
      } else if (passwordController.text != conpasswordController.text) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.passworddomntmatch,
        );
      } else {
        int isInternalPurposeUse = 0;
        if (isInternalPurpose == false) {
          isInternalPurposeUse = 0;
        } else if (isInternalPurpose == true) {
          isInternalPurposeUse = 1;
        }

        AllClientModel newClient = AllClientModel(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            company: companyController.text,
            email: emailController.text,
            password: passwordController.text,
            passwordConfirmation: conpasswordController.text,
            address: addrerssController.text,
            role: selectedRoleId.toString(),
            countryCode: phoneController.text.isEmpty
                ? ""
                : (countryCode ??
                    defaultCountryCode), // Set empty if no phone number
            countryIsoCode: countryIsoCode,
            city: cityController.text,
            internalPurpose: isInternalPurposeUse,
            doj: doj,
            dob: dob,
            state: stateController.text,
            country: countryController.text,
            zip: zipcodeController.text,
            phone: phoneController.text,
            profile: null,
            status: _selectedStateIndex ?? 0,
            emailVerificationMailSent: _selectedEmailVeriIndex ?? 0
            // Populate other fields...
            );
        isLoading = true;
        context
            .read<ClientBloc>()
            .add(ClientsCreated(newClient, _image, filepath));
        final setting = context.read<ClientBloc>();
        setting.stream.listen((state) {
          if (state is ClientSuccessCreate) {

            isLoading = false;
            if (mounted) {
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.createdsuccessfully,
                  color: AppColors.primary);
              context.read<ClientBloc>().add(ClientList());

              Navigator.pop(context);
            }
          }
          if (state is ClientCreateError) {
            isLoading = false;
            flutterToastCustom(msg: state.errorMessage);
          }
          if (state is ClientPaginated) {
            isLoading = false;
          }
        });
      }
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void onUpdateClient(AllClientModel currentClient) {

    if (firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      String? phoneCountryCode;
      if (emailController.text.isNotEmpty &&
          !emailController.text.contains('@')) {
        flutterToastCustom(
            msg: AppLocalizations.of(context)!.pleaseenteravalidemail);
      } else {
        if (phoneController.text.isNotEmpty) {
          phoneCountryCode = countryCode ?? defaultCountryCode;
        }
        int isInternalPurposeUse = 0;
        if (isInternalPurpose == false) {
          isInternalPurposeUse = 0;
        } else if (isInternalPurpose == true) {
          isInternalPurposeUse = 1;
        }
        AllClientModel updatedUser = currentClient.copyWith(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            role: selectedRoleId.toString(),
            email: emailController.text,
            phone: phoneController.text,
            countryCode: phoneController.text.isNotEmpty
                ? phoneCountryCode
                : "", // Only set countryCode if phone is not empty
            password: passwordController.text,
            passwordConfirmation: conpasswordController.text,
            address: addrerssController.text,
            dob: dob,
            company: companyController.text,
            internalPurpose: isInternalPurposeUse,
            doj: doj,
            city: cityController.text,
            state: stateController.text,
            country: countryController.text,
            zip: zipcodeController.text,
            profile: null,
            status: _selectedStateIndex ?? 1,
            emailVerificationMailSent: _selectedEmailVeriIndex ?? 0);
        isLoading = true;
        BlocProvider.of<ClientBloc>(context).add(UpdateClients(updatedUser));

        final setting = context.read<ClientBloc>();
        setting.stream.listen((state) {

          if (state is ClientEditSuccess) {
            if (mounted) {

              isLoading = false;

              setting.add(ClientList());

              BlocProvider.of<TaskBloc>(context)
                  .add(AllTaskListOnTask(clientId: []));
              BlocProvider.of<ProjectBloc>(context).add(
                  ProjectDashBoardList(
                      clientId: [widget.clientModel!.id!]));
              BlocProvider.of<PermissionsBloc>(context)
                  .add(GetPermissions());
              BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(
                widget.clientModel!.id!,
              ));
              BlocProvider.of<ProjectBloc>(context)
                  .add(ProjectDashBoardList());
              Navigator.pop(context);
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.updatedsuccessfully,
                  color: AppColors.primary);
            }


          }
          if (state is ClientEditError) {
            isLoading = false;
            flutterToastCustom(msg: state.errorMessage);
             context.read<ClientBloc>().add(ClientList());
          }
        });
      }
      // Check if the phone number is not empty before setting countryCode
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  void handleIsInternalPurpose(
    bool status,
  ) {
    setState(() {
      // userId = id;
      isInternalPurpose = status;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void getRoleAndHasDataAccess() async {
    role = await HiveStorage.getRole();
    hasAllDataAccess = await HiveStorage.getAllDataAccess();
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
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    getRoleAndHasDataAccess();

    if (widget.isCreate == false) {

      if(widget.clientModel!.id != null ){
        clientId = widget.clientModel!.id;
      }
      currentClient = widget.clientModel!;
      var isEditUser = widget.clientModel;

      if (currentClient!.internalPurpose == 1) {
        isInternalPurpose = true;
      } else {
        isInternalPurpose = false;
      }
      if (isEditUser!.dob != null &&
          isEditUser.dob!.isNotEmpty &&
          isEditUser.dob != "") {
        parsedDate = parseDateStringFromApi(isEditUser.dob!);
        formattedDob = dateFormatConfirmed(parsedDate!, context);
        selectedDobDate = parsedDate;
      }
      if (isEditUser.doj != null &&
          isEditUser.doj!.isNotEmpty &&
          isEditUser.doj != "") {
        parsedDate = parseDateStringFromApi(isEditUser.doj!);
        formattedDoj = dateFormatConfirmed(parsedDate!, context);
        selectedDojDate = parsedDate;

      }
      filepath = isEditUser.profile;
      // selectedRoleName=widget.clientModel!.;
      firstNameController = TextEditingController(text: isEditUser.firstName);
      lastNameController = TextEditingController(text: isEditUser.lastName);
      emailController = TextEditingController(text: isEditUser.email);
      phoneController = TextEditingController(text: isEditUser.phone);
      passwordController = TextEditingController();
      conpasswordController = TextEditingController();
      roleController = TextEditingController(text: isEditUser.role);
      addrerssController = TextEditingController(text: isEditUser.address);
      cityController = TextEditingController(text: isEditUser.city);
      stateController = TextEditingController(text: isEditUser.state);
      countryController = TextEditingController(text: isEditUser.country);
      companyController = TextEditingController(text: isEditUser.company);
      zipcodeController = TextEditingController(text: isEditUser.zip);
      selectedLabel = isEditUser.state;
      dobController = TextEditingController(text: formattedDob);
      dojController = TextEditingController(text: formattedDoj);
    } else {
      // titleController = TextEditingController();
      // selectedStatus="";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (!didPop) {
                if (widget.fromDetail == true && widget.isCreate == false) {
                  BlocProvider.of<TaskBloc>(context)
                      .add(AllTaskListOnTask(clientId: []));
                  BlocProvider.of<ProjectBloc>(context).add(
                      ProjectDashBoardList(
                          clientId: [widget.clientModel!.id!]));
                  BlocProvider.of<PermissionsBloc>(context)
                      .add(GetPermissions());
                  BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(
                    widget.clientModel!.id!,
                  ));
                  BlocProvider.of<ProjectBloc>(context)
                      .add(ProjectDashBoardList());
                  router.pop(context);
                } else {
                  router.pop(context);
                }
              }
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.backGroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20.w, right: 20.w, top: 0.h),
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
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.fromDetail == true && widget.isCreate == false) {
                                        BlocProvider.of<TaskBloc>(context).add(
                                            AllTaskListOnTask(clientId: []));
                                        BlocProvider.of<ProjectBloc>(context)
                                            .add(ProjectDashBoardList(
                                                clientId: [
                                              widget.clientModel!.id!
                                            ]));
                                        BlocProvider.of<PermissionsBloc>(
                                                context)
                                            .add(GetPermissions());
                                        BlocProvider.of<ClientidBloc>(context)
                                            .add(ClientIdListId(
                                          widget.clientModel!.id!,
                                        ));
                                        BlocProvider.of<ProjectBloc>(context)
                                            .add(ProjectDashBoardList());
                                        router.pop(context);
                                      } else {
                                        router.pop(context);
                                      }
                                    },
                                    child: BackArrow(
                                      onTap: () {
                                        if (widget.fromDetail == true && widget.isCreate == false) {
                                          BlocProvider.of<TaskBloc>(context).add(
                                              AllTaskListOnTask(clientId: []));
                                          BlocProvider.of<ProjectBloc>(context)
                                              .add(ProjectDashBoardList(
                                              clientId: [
                                                widget.clientModel!.id!
                                              ]));
                                          BlocProvider.of<PermissionsBloc>(
                                              context)
                                              .add(GetPermissions());
                                          BlocProvider.of<ClientidBloc>(context)
                                              .add(ClientIdListId(
                                            widget.clientModel!.id!,
                                          ));
                                          BlocProvider.of<ProjectBloc>(context)
                                              .add(ProjectDashBoardList());
                                          router.pop(context);
                                        } else {
                                          router.pop(context);
                                        }
                                      },
                                      title: widget.isCreate == true
                                          ? AppLocalizations.of(context)!
                                              .createclient
                                          : AppLocalizations.of(context)!
                                              .editclient,
                                    ),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 30.h),
                    SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Row(
                                children: [
                                  IsCustomSwitch(
                                      isCreate: widget.isCreate,
                                      status: isInternalPurpose,
                                      onStatus: handleIsInternalPurpose),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .isInternamPurpose,
                                    fontWeight: FontWeight.w400,
                                    size: 12.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                title: AppLocalizations.of(context)!.firstname,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterfirstrname,
                                controller: firstNameController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    firstnameFocus!,
                                    lastnameFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: true),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                title: AppLocalizations.of(context)!.lastname,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterlastrname,
                                controller: lastNameController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    lastnameFocus!,
                                    emailFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: true),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                title: AppLocalizations.of(context)!.email,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenteremail,
                                controller: emailController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    emailFocus!,
                                    phoneFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: true),
                            SizedBox(
                              height: 15.h,
                            ),
                            _phoneNumberField(isLightTheme),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                title: AppLocalizations.of(context)!.password,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterpassword,
                                isPassword: true,
                                controller: passwordController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    passwardFocus!,
                                    conpasswardFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired:
                                    widget.isCreate == true ? true : false),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                title:
                                    AppLocalizations.of(context)!.conPassword,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterconpassword,
                                controller: conpasswordController,
                                isPassword: true,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    conpasswardFocus!,
                                    addressFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired:
                                    widget.isCreate == true ? true : false),
                            SizedBox(
                              height: 15.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DatePickerWidget(
                                      dateController: dobController,
                                      title: AppLocalizations.of(context)!.dob,
                                      onTap: () async {
                                        final DateTime? dateTime =
                                            await showOmniDateTimePicker(
                                                lastDate: DateTime.now(),
                                                firstDate: DateTime(1910),
                                                context: context,
                                                type:
                                                    OmniDateTimePickerType.date,
                                                initialDate: parsedDate ??
                                                    DateTime.now(),
                                                isShowSeconds: false,
                                                barrierColor: Theme.of(context)
                                                    .colorScheme
                                                    .containerDark);
                                        setState(() {
                                          selectedDateStarts = dateTime!;
                                          if (selectedDateEnds != null) {
                                          dob = dateFormatConfirmedToApi(
                                              selectedDateStarts!);}

                                          dobController.text =
                                              dateFormatConfirmed(
                                                  selectedDateStarts!, context);
                                        }); // Print the picked date
                                      },
                                      isLightTheme: isLightTheme,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: DatePickerWidget(
                                      dateController: dojController,
                                      title: AppLocalizations.of(context)!.doj,
                                      onTap: () async {
                                        final DateTime? dateTime =
                                            await showOmniDateTimePicker(
                                                barrierDismissible: true,
                                                context: context,
                                                type:
                                                    OmniDateTimePickerType.date,
                                                initialDate: parsedDate ??
                                                    DateTime.now(),
                                                isShowSeconds: false,
                                                barrierColor: Theme.of(context)
                                                    .colorScheme
                                                    .containerDark);
                                        setState(() {
                                          selectedDateStarts = dateTime!;
                                          doj = dateFormatConfirmedToApi(
                                              selectedDateStarts!);
                                          dojController.text =
                                              dateFormatConfirmed(
                                                  selectedDateStarts!, context);
                                        }); // Print the picked date
                                      },
                                      isLightTheme: isLightTheme,
                                    ),
                                  )
                                  // 03
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),

                            CustomTextField(
                                // keyboardType:  TextInputType.multiline,
                                title: AppLocalizations.of(context)!.state,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterstate,
                                controller: stateController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    stateFocus!,
                                    countryFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                title: AppLocalizations.of(context)!.city,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseentercity,
                                controller: cityController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    cityFocus!,
                                    companyFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),

                            SizedBox(
                              height: 15.h,
                            ),
                            profileImageField(isLightTheme),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                // keyboardType:  TextInputType.multiline,
                                title: AppLocalizations.of(context)!.company,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseentercompanyname,
                                controller: companyController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    companyFocus!,
                                    stateFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),

                            // ProfileImageField(isLightTheme),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                // keyboardType:  TextInputType.multiline,
                                title: AppLocalizations.of(context)!.country,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseentercountry,
                                controller: countryController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    countryFocus!,
                                    zipFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextField(
                                // keyboardType:  TextInputType.multiline,
                                title: AppLocalizations.of(context)!.zipcode,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterzipcode,
                                controller: zipcodeController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {},
                                isLightTheme: isLightTheme,
                                isRequired: false),

                            SizedBox(
                              height: 15.h,
                            ),
                            hasAllDataAccess == true && role == "admin"
                                ? _userActivatedOrNot(isLightTheme)
                                : SizedBox.shrink(),

                            hasAllDataAccess == true && role == "admin"
                                ? SizedBox(
                                    height: 15.h,
                                  )
                                : SizedBox(),
                            hasAllDataAccess == true && role == "admin"
                                ? _requireEmailVerification(isLightTheme)
                                : SizedBox.shrink(),
                            hasAllDataAccess == true && role == "admin"
                                ? SizedBox(
                                    height: 20.h,
                                  )
                                : SizedBox(),
                            BlocBuilder<ClientBloc, ClientState>(
                              builder: (context, state) {

                                if (state is ClientLoadingCreate ||
                                    state is ClientLoadingEdit) {
                                  return CreateCancelButtom(
                                    isLoading: isLoading,
                                    isCreate: widget.isCreate,
                                    onpressCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onpressCreate: widget.isCreate == true
                                        ? () async {
                                            onCreateClient();
                                          }
                                        : () {
                                            onUpdateClient(currentClient!);
                                          },
                                  );
                                }
                                return CreateCancelButtom(
                                  isCreate: widget.isCreate,
                                  isLoading: isLoading,
                                  onpressCancel: () {
                                    Navigator.pop(context);
                                  },
                                  onpressCreate: widget.isCreate == true
                                      ? () async {
                                          onCreateClient();
                                        }
                                      : () {
                                          onUpdateClient(currentClient!);
                                        },
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  Widget _phoneNumberField(isLightTheme) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: CustomText(
            text: AppLocalizations.of(context)!.phonenumber,
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
          height: 40.h,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          // decoration: DesignConfiguration.shadow(),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  // color: Colors.red,
                  width: 70.w,
                  child: CountryCodePicker(
                    dialogBackgroundColor:
                        Theme.of(context).colorScheme.containerDark,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    padding: EdgeInsets.zero,
                    showFlag: true,
                    onChanged: (country) {
                      setState(() {
                        countryCode = country.dialCode;
                        countryIsoCode = country.name;
                      });
                    },
                    initialSelection: defaultCountry,
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                  ),
                ),
              ),
              Container(
                color: AppColors.greyForgetColor,
                // color: colors.red,
                // height: 40.h,
                width: 0.5.w,
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                flex: 6,
                child: Container(
                  padding: EdgeInsets.zero,
                  // color: Colors.yellow,
                  child: TextFormField(
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    validator: (val) => StringValidation.validateField(
                      val!,
                      AppLocalizations.of(context)!.required,
                    ),
                    decoration: InputDecoration(
                        // labelText: "firstname",
                        hintText: AppLocalizations.of(context)!
                            .pleaseenterphonenumber,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: (40.h - 17.sp) / 2,
                          horizontal: 10.w,
                        )
                        // Center the text vertically
                        ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _userActivatedOrNot(isLightTheme) {
    if (hasPermission == false) {
      _selectedStateIndex = 0;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Status text
              Container(
                alignment: Alignment.topLeft,
                child: CustomText(
                  text: AppLocalizations.of(context)!.status,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 10.w), // Add spacing between the two texts
              // IfDeactivate text
              Expanded(
                child: CustomText(
                  text: AppLocalizations.of(context)!.ifDeactivate,
                  color: AppColors.greyColor,
                  size: 8.sp,
                  maxLines: 2,
                  fontWeight: FontWeight.w400,
                  overflow:
                      TextOverflow.ellipsis, // Handle long text gracefully
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            // padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                // color: Colors.red,
                border: Border.all(color: AppColors.greyColor),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  isLightTheme
                      ? MyThemes.lightThemeShadow
                      : MyThemes.darkThemeShadow,
                ]),
            // decoration: DesignConfiguration.shadow(),
            child: ToggleSwitch(
              cornerRadius: 11,
              activeBgColor: const [AppColors.primary],
              inactiveBgColor: Theme.of(context).colorScheme.containerDark,
              minHeight: 40,
              minWidth: double.infinity,
              initialLabelIndex: _selectedStateIndex,
              totalSwitches: 2,
              labels: const ['Deactive', 'Active'],
              onToggle: (index) {
                if (hasPermission == true) {
                  setState(() {
                    _selectedStateIndex = index ?? 0;
                  });
                } else {}
              },
            ))
      ],
    );
  }

  Widget _requireEmailVerification(isLightTheme) {
    if (hasPermission == false) {
      _selectedEmailVeriIndex == 1;
    }
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
                text: AppLocalizations.of(context)!.requireEmailVerification,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 14,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            // padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                // color: Colors.red,
                border: Border.all(color: AppColors.greyColor),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  isLightTheme
                      ? MyThemes.lightThemeShadow
                      : MyThemes.darkThemeShadow,
                ]),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: const EdgeInsets.all(0.1),
              child: ToggleSwitch(
                // radiusStyle: true,
                cornerRadius: 12,
                activeBgColor: const [AppColors.primary],
                inactiveBgColor: Theme.of(context).colorScheme.containerDark,
                minHeight: 40,
                minWidth: double.infinity / 2,
                initialLabelIndex: _selectedEmailVeriIndex,
                totalSwitches: 2,
                labels: const ['No', 'Yes'],
                onToggle: (index) {
                  if (hasPermission == true) {
                    setState(() {
                      _selectedEmailVeriIndex = index ?? 1;
                    });
                  } else {}

                },
              ),
            ))
      ],
    );
  }
}
