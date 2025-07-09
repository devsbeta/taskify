import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';

import '../../../bloc/income_expense/income_expense_bloc.dart';
import '../../../bloc/income_expense/income_expense_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../data/model/income_expense/income_expense_model.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../widgets/search_field.dart';


class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  TextEditingController searchController = TextEditingController();  String? formattedTimeEnd;
  DateTime? selectedDateStarts;
  DateTime? selectedDateEnds;
  String? fromDate;
  String? toDate;
  String searchWord = "";
  late List<ChartData> chartData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true, shared: true);

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        print("jfsdhbj dlgb $state");
        if (state is ChartLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ChartError) {
          return Center(child: Text(state.message));
        } else if (state is ChartLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Income vs Expense",
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 18,
                  fontWeight: FontWeight.w800,
                ),
                SizedBox(height: 15.h),
                CustomSearchField(
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
                          searchController.text =
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
                  isNoti: true,
                  hintText: "Date between",
                  isLightTheme: isLightTheme,
                  controller: searchController,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchController.text.isNotEmpty)
                        Container(
                          width: 20.w,
                          // color: AppColors.red,
                          child: IconButton(
                              highlightColor: AppColors.greyForgetColor,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.clear,
                                size: 20.sp,
                                color: Theme.of(context).colorScheme.textFieldColor,
                              ),
                              onPressed: () {
                                searchController.clear();
                                // Clear the search field
                              }),
                        ),
                    ],
                  ),
                  onChanged: (value) {
                    searchWord = value;
                  },
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 300.h,
                  child: SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(enable: true),
                    legend: Legend(isVisible: true, position: LegendPosition.top),
                    primaryXAxis: DateTimeAxis(),
                    series: <CartesianSeries>[
                      SplineSeries<Invoice, DateTime>(
                        splineType: SplineType.natural,
                        name: 'Income',
                        color: Colors.green,
                        dataSource: state.chartData.invoices,
                        xValueMapper: (Invoice invoice, _) =>
                            DateFormat("dd-MM-yyyy").parse(invoice.fromDate),
                        yValueMapper: (Invoice invoice, _) =>
                            double.tryParse(invoice.amount.replaceAll(RegExp(r'[^\d.]'), '')),
                        dataLabelMapper: (Invoice invoice, _) => invoice.amount, // Tooltip text
                        markerSettings: const MarkerSettings(isVisible: true), // Show dots
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      ),
                      AreaSeries<Expense, DateTime>(
                        name: 'Expenses',
                        color: Colors.red.withOpacity(0.3),
                        borderColor: Colors.red,
                        borderWidth: 2,
                        dataSource: state.chartData.expenses,
                        xValueMapper: (Expense expense, _) =>
                            DateFormat("dd-MM-yyyy").parse(expense.expenseDate),
                        yValueMapper: (Expense expense, _) =>
                            double.tryParse(expense.amount.replaceAll(RegExp(r'[^\d.]'), '')),
                        dataLabelMapper: (Expense expense, _) => expense.amount, // Tooltip text
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  )
                ),




              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class ChartData {
  final DateTime date;
  final double income;
  final double expense;

  ChartData(this.date, this.income, this.expense);
}
// List<ChartData> getChartData() {
//   return [
//     ChartData(DateTime(2024, 8, 1), 500, 2000),
//     ChartData(DateTime(2024, 8, 5), 700, 1000),
//     ChartData(DateTime(2024, 8, 8), 800, 2400),
//     ChartData(DateTime(2024, 7, 3), 900, 1200),
//     ChartData(DateTime(2024, 3, 26), 600, 600),
//     ChartData(DateTime(2024, 5, 15), 400, 400),
//   ];
// }
//
// class ChartData {
//   final DateTime date;
//   final double income;
//   final double expense;
//   ChartData(this.date, this.income, this.expense);
// }
