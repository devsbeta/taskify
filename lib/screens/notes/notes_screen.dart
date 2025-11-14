
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/notes/notes_bloc.dart';
import 'package:taskify/bloc/notes/notes_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/notes/notes_model.dart';
import 'package:taskify/l10n/app_localizations.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/notes/notes_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../data/repositories/notes/notes_repo.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/circularprogress_indicator.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/html_widget.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createNotesKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startsController = TextEditingController();

  FocusNode? titleFocus, descFocus, startsFocus, endFocus = FocusNode();
  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool? isLoading = true;
  late SpeechToTextHelper speechHelper;
  bool isLoadingMore = false;
  String searchWord = "";
  bool dialogShown = false;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

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

    listenForPermissions();
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<NotesBloc>().add(SearchNotes(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    NotesRepo().noteList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onCreateNotes() {
    if (titleController.text.isNotEmpty) {
      final newNote = NotesModel(
        title: titleController.text.toString(),
        description: descController.text.toString(),
        createdAt: startsController.text.toString(),
      );
      context.read<NotesBloc>().add(AddNotes(newNote));
      final todosBloc = BlocProvider.of<NotesBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is NotesCreateSuccess) {
          todosBloc.add(const NotesList());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is NotesCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onEditNotes(id, title, desc) async {
    if (titleController.text.isNotEmpty) {
      final updatedNote = NotesModel(
        id: id,
        title: titleController.text,
        description: descController.text,
        updatedAt: startsController.text,
      );

      context.read<NotesBloc>().add(UpdateNotes(updatedNote));
      final todosBloc = BlocProvider.of<NotesBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is NotesEditSuccess) {
          if (mounted) {
            context.read<NotesBloc>().add(const NotesList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is NotesEditError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }
  // Navigator.pop(context);

  void _onDeleteNotes(notes) {
    context.read<NotesBloc>().add(DeleteNotes(notes));
    final setting = context.read<NotesBloc>();
    setting.stream.listen((state) {
      if (state is NotesDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is NotesDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    context.read<NotesBloc>().add(const NotesList());
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<NotesBloc>(context).add(NotesList());
    setState(() {
      isLoading = false;
    });
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
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _appbar(isLightTheme),
                    SizedBox(height: 20.h),
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
                                  context
                                      .read<NotesBloc>()
                                      .add(SearchNotes(''));
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
                      onChanged: (value) {
                        searchWord = value;
                        context.read<NotesBloc>().add(SearchNotes(value));
                      },
                    ),
                    SizedBox(height: 20.h),
                    body(isLightTheme)
                  ],
                ),
              ),
            ));
  }

  Widget body(isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: BlocConsumer<NotesBloc, NotesState>(
          listener: (context, state) {
            if (state is NotesPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            if (state is NotesLoading) {
              // Show loading indicator when there's no notes
              return const NotesShimmer();
            } else if (state is NotesPaginated) {
              // Show notes list with pagination
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    context.read<NotesBloc>().add(LoadMoreNotes(searchWord));
                  }
                  return false;
                },
                child: state.notes.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.only(bottom: 30.h),
                        shrinkWrap: true,
                        itemCount: state.hasReachedMax
                            ? state.notes.length
                            : state.notes.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.notes.length) {
                            final notes = state.notes[index];
                            return _notesListContainer(
                              notes,
                              isLightTheme,
                              state.notes,
                              index,
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return CircularProgressIndicatorCustom(
                              hasReachedMax: state.hasReachedMax,
                            );
                          }
                        },
                      )
                    : NoData(
                        isImage: true,
                      ),
              );
            } else if (state is NotesError) {
              // Show error message
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is NotesSuccess) {
              // Show initial list of notes
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount:
                    state.notes.length + 1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.notes.length) {
                    final notes = state.notes[index];
                    return _notesListContainer(
                      notes,
                      isLightTheme,
                      state.notes,
                      index,
                    );
                  } else {
                    // Show a loading indicator when more notes are being loaded
                    return CircularProgressIndicatorCustom(
                      hasReachedMax: true,
                    );
                  }
                },
              );
            }
            // Handle other states
            return const Text("");
          },
        ),
      ),
    );
  }

  Widget _appbar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        iscreatePermission: true,
        title: AppLocalizations.of(context)!.notes,
        isAdd: true,
        onPress: () {
          _createEditNotes(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Future<void> _createEditNotes(
      {isLightTheme, isCreate, notes, notesModel, int? id, title, desc}) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          if (!isCreate) {
            //   titleController.text = '';
            //   descController.text = '';
            // } else {
            titleController.text = title ?? "";
            descController.text = desc ?? "";
          }

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              height: 400.h,
              child: Center(
                child: Form(
                  key: _createNotesKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          iscreatePermission: true,
                          title: isCreate == false
                              ? AppLocalizations.of(context)!.editnotes
                              : AppLocalizations.of(context)!.createnotes,
                          iSBackArrow: false,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        title: AppLocalizations.of(context)!.title,
                        hinttext:
                            AppLocalizations.of(context)!.pleaseentertitle,
                        controller: titleController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {},
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        height: 112.h,
                        keyboardType: TextInputType.multiline,
                        title: AppLocalizations.of(context)!.description,
                        hinttext: AppLocalizations.of(context)!
                            .pleaseenterdescription,
                        controller: descController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {
                          _fieldFocusChange(
                            context,
                            descFocus!,
                            startsFocus,
                          );
                        },
                        isLightTheme: isLightTheme,
                        isRequired: false,
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(height: 10.h),
                      BlocBuilder<NotesBloc, NotesState>(
                          builder: (context, state) {
                        if (state is NotesEditSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    _onCreateNotes();
                                  }
                                : () {
                                    _onEditNotes(id, title, desc);
                                    setState(() {
                                      context
                                          .read<NotesBloc>()
                                          .add(const NotesList());
                                    });
                                    Navigator.pop(context);
                                  },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                        if (state is NotesCreateSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    _onCreateNotes();
                                  }
                                : () {
                                    _onEditNotes(id, title, desc);
                                    setState(() {
                                      context
                                          .read<NotesBloc>()
                                          .add(const NotesList());
                                    });
                                    Navigator.pop(context);
                                  },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                        return CreateCancelButtom(
                          isCreate: isCreate,
                          onpressCreate: isCreate == true
                              ? () async {
                                  _onCreateNotes();
                                }
                              : () {
                                  _onEditNotes(id, title, desc);
                                  setState(() {
                                    context
                                        .read<NotesBloc>()
                                        .add(const NotesList());
                                  });
                                  Navigator.pop(context);
                                },
                          onpressCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).whenComplete(() {
      titleController.text = '';
      descController.text = '';
    });
  }

  Widget _notesListContainer(
    NotesModel notes,
    bool isLightTheme,
    List<NotesModel> notesModel,
    int index,
  ) {
    String? date;
    date = formatDateFromApi(notes.createdAt!, context);

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: notes.id!.toString(),
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
                    backgroundColor:
                        Theme.of(context).colorScheme.alertBoxBackGroundColor,
                    title: Text(
                      AppLocalizations.of(context)!.confirmDelete,
                    ),
                    content: Text(
                      AppLocalizations.of(context)!.areyousure,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Confirm deletion
                        },
                        child: Text(
                          AppLocalizations.of(context)!.ok,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Cancel deletion
                        },
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                        ),
                      ),
                    ],
                  );
                },
              );
              return result; // Return the result of the dialog
            } else if (direction == DismissDirection.startToEnd) {
              _createEditNotes(
                isLightTheme: isLightTheme,
                isCreate: false,
                notes: notes,
                notesModel: notesModel,
                id: notes.id,
                title: notes.title,
                desc: notes.description,
              );
              // Perform the edit action if needed
              return false; // Prevent dismiss
            }
            return false;
          },
          dismissWidget: Container(
            decoration: BoxDecoration(
                boxShadow: [
                  isLightTheme
                      ? MyThemes.lightThemeShadow
                      : MyThemes.darkThemeShadow,
                ],
                border: Border.all(
                    color:
                        AppColors.colorDark[index % AppColors.colorDark.length],
                    width: 0.5),
                color: isLightTheme
                    ? AppColors.colorLight[index % AppColors.colorLight.length]
                    : AppColors.darkContainer,
                borderRadius: BorderRadius.circular(12)),
            // height: 140.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h, left: 20.h, right: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: notes.title!,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      htmlWidget(notes.description ?? "", context,
                          width: 290.w, height: 36.h)
                    ],
                  ),
                ),
                const Divider(
                  color: AppColors.textsubColor,
                  thickness: 0.5,
                ),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          HeroIcon(
                            HeroIcons.calendar,
                            style: HeroIconStyle.solid,
                            color: AppColors.blueColor,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          CustomText(
                            text: date,
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 12,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart) {
              setState(() {
                notesModel.removeAt(index);
                _onDeleteNotes(notes.id);
              });
            }
          },
        ));
  }
}
