import 'package:flutter/material.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/colors.dart';
import '../../widgets/custom_date.dart';

class DateList extends StatefulWidget {
  final TextEditingController? startController;
  final TextEditingController? endController;
   DateTime? selectedDateEnds;
   DateTime? selectedDateStarts;
   String? fromDate;
   String? toDate;
  final Function(String, String)? onSelected;



   DateList({super.key,this.startController,this.endController,this.fromDate,this.toDate,this.selectedDateEnds,this.selectedDateStarts,this.onSelected});

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return SizedBox(
      // width: 200.w,
      height: 200.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DatePickerWidget(
              dateController: widget.startController!,
              title: AppLocalizations.of(context)!.starts,
              onTap: () {
                showCustomDateRangePicker(
                  context,
                  dismissible: true,
                  minimumDate: DateTime(1900, 1, 1), // Very early date
                  maximumDate: DateTime(2100, 12, 31),
                  endDate: widget.selectedDateEnds,
                  startDate: widget.selectedDateStarts,
                  backgroundColor: Theme.of(context).colorScheme.containerDark,
                  primaryColor: AppColors.primary,
                  onApplyClick: (start, end) {
                    setState(() {
                      // if (start.isBefore(DateTime.now())) {
                      //   start = DateTime
                      //       .now(); // Reset the start date to today if earlier
                      // }

                      // If the end date is not selected or is null, set it to the start date
                      if (end.isBefore(start) || widget.selectedDateEnds == null) {
                        end =
                            start; // Set the end date to the start date if not selected
                      }
                      widget.selectedDateEnds = end;
                      widget.selectedDateStarts = start;
                      widget.startController!.text = DateFormat('MMMM dd, yyyy')
                          .format(widget.selectedDateStarts!);
                      widget.endController!.text =
                          DateFormat('MMMM dd, yyyy').format(widget.selectedDateEnds!);
                      widget.fromDate = DateFormat('yyyy-MM-dd').format(start);
                      widget.toDate = DateFormat('yyyy-MM-dd').format(end);
                      print("kflgjrgoj ${widget.toDate}");
                      widget.onSelected!(widget.fromDate!,widget.toDate!);
                    });
                  },
                  onCancelClick: () {
                    setState(() {
                      // Handle cancellation if necessary
                    });
                  },
                );
              },
              isLightTheme: isLightTheme,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DatePickerWidget(
              dateController: widget.endController!,
              title: AppLocalizations.of(context)!.ends,
              isLightTheme: isLightTheme,
            ),
          ),
        ],
      ),
    );
  }
}
