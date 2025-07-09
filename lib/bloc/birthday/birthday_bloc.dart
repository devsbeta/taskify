import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/model/Birthday/birthday_model.dart';
import '../../data/repositories/Birthday/birthday_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'birthday_event.dart';
import 'birthday_state.dart';

class BirthdayBloc extends Bloc<BirthdayEvent, BirthdayState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  BirthdayBloc() : super(BirthdayInitial()) {
    on<WeekBirthdayList>(_onWeekBirthday);
    on<LoadMoreBirthday>(_onLoadMoreBirthday);
  }

  Future<void> _onWeekBirthday(WeekBirthdayList event, Emitter<BirthdayState> emit) async {
    try {
      List<BirthdayModel> birthday =[];

      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      // emit(TodaysBirthdayLoading());
      Map<String,dynamic> result = await BirthdayRepo().getBirthday(limit: _limit, offset: _offset,token: true,upComingDays: event.upcomingDays,userId:event.userId,clientId:event.clientId);

      birthday = List<BirthdayModel>.from(result['data']
          .map((projectData) => BirthdayModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = birthday.length < _limit;
      if (result['error'] == false) {
        emit(TodayBirthdaySuccess( birthday:birthday, hasReachedMax: _hasReachedMax,));
      }
      if (result['error'] == true) {
        emit((BirthdayError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((BirthdayError("Error: $e")));
    }
  }

  Future<void> _onLoadMoreBirthday(
      LoadMoreBirthday event, Emitter<BirthdayState> emit) async {

    if (state is TodayBirthdaySuccess && !_hasReachedMax) {
      try {
        List<BirthdayModel> birthday =[];

        final currentState = state as TodayBirthdaySuccess;
        final updatedBirthday = List<BirthdayModel>.from(currentState.birthday);
        Map<String,dynamic> result = await BirthdayRepo().getBirthday(limit: _limit, offset: _offset, token: true,upComingDays: event.upcomingDays,userId:event.userId);
        birthday = List<BirthdayModel>.from(result['data'].map((projectData) => BirthdayModel.fromJson(projectData)));

        _offset = updatedBirthday.length + birthday.length;

        if (updatedBirthday.length + birthday.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }
        updatedBirthday.addAll(birthday);
        if (result['error'] == false) {
          emit(TodayBirthdaySuccess( birthday:updatedBirthday, hasReachedMax: _hasReachedMax,));
        }
        if (result['error'] == true) {
          emit((BirthdayError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }

      } on ApiException catch (e) {
        flutterToastCustom(msg: "$e");
        emit(BirthdayError("Error: $e"));
      }
    }
  }

}
