
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/repositories/income_expense/income_expense_repo.dart';
import '../../api_helper/api.dart';
import '../../data/model/income_expense/income_expense_model.dart';
import 'income_expense_event.dart';
import 'income_expense_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final Dio dio = Dio();

  ChartBloc() : super(ChartInitial()) {
    on<FetchChartData>(_onIncomeExpenseData);

    // on<FetchChartData>((event, emit) async {
    //   emit(ChartLoading());
    //   try {
    //     print("fsbfdFbDF ");
    //     final response = await dio.get("${baseUrl}reports/income-vs-expense-report-data");
    //
    //     if (response.statusCode == 200) {
    //       // Ensure response is a Map
    //       final data = response.data is String ? jsonDecode(response.data) : response.data;
    //
    //       if (data is Map<String, dynamic>) {
    //         final chartData = ChartDataModel.fromJson(data);
    //         emit(ChartLoaded(chartData));
    //       } else {
    //         emit(ChartError("Invalid response format"));
    //       }
    //     } else {
    //       emit(ChartError("Failed to fetch data"));
    //     }
    //   } catch (e) {
    //     emit(ChartError("Error: ${e.toString()}"));
    //   }
    // });
  }
  Future<void> _onIncomeExpenseData(FetchChartData event, Emitter<ChartState> emit) async {
    try {
      Map<String,dynamic> result = await IncomeExpenseRepo().getIncomeExpense(token: true,startDate:event.startDate,endDate:event.endDate);
print("zkljfnxgvn ");
      ChartDataModel chartData = ChartDataModel.fromJson(result);
      print("zkljfnxgvn sa");

        emit(ChartLoaded(chartData));

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ChartError("Error: $e")));
    }
  }
}