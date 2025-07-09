import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/work_anniveresary/work_anniversary_event.dart';
import 'package:taskify/bloc/work_anniveresary/work_anniversary_state.dart';
import '../../data/model/work_anniversary/work_anni_model.dart';
import '../../data/repositories/work_anniniversary/work_anniniversary_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class WorkAnniversaryBloc extends Bloc<WorkAnniversaryEvent, WorkAnniversaryState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  WorkAnniversaryBloc() : super(WorkAnniversaryInitial()) {
    on<AllWorkAnniversaryList>(_allWorkAnniversary);
    on<WeekWorkAnniversaryList>(_weekWorkAnniversary);
    on<LoadMoreWorkAnniversary>(_onLoadMoreWorkAnniversary);
  }


  Future<void> _allWorkAnniversary(AllWorkAnniversaryList event, Emitter<WorkAnniversaryState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(WorkAnniversaryLoading());
      List<WorkAnniversaryModel> workAnniversary =[];
      await WorkAnniversaryRepo().getWorkAnniversary(limit: _limit, offset: _offset,token: true);
      _offset += _limit;
      _hasReachedMax = workAnniversary.length < _limit;
      emit(WorkAnniversaryPaginated(workAnniversary: workAnniversary, hasReachedMax: _hasReachedMax));
      // emit(WorkAnniversaryLoading());
      // List<WorkAnniversarys> workAnniversary = await WorkAnniversaryRepo().getWorkAnniversary(token: true);

      // emit(AllWorkAnniversarySuccess(workAnniversary));
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((WorkAnniversaryError("Error: $e")));
    }
  }

  Future<void> _weekWorkAnniversary(WeekWorkAnniversaryList event, Emitter<WorkAnniversaryState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TodaysWorkAnniversaryLoading());
      List<WorkAnniversaryModel> workAnniversary =[];

    Map<String,dynamic> result
   = await WorkAnniversaryRepo().getWorkAnniversary(limit: _limit, offset: _offset,token: true,upComingDays: event.upcomingDays,userId:event.userId,clientId:event.clientId);
     if(result['data']!= null){
       workAnniversary = List<WorkAnniversaryModel>.from(result['data']
           .map((projectData) => WorkAnniversaryModel.fromJson(projectData)));
     }else{
       workAnniversary = [];
     }

      _offset += _limit;
      _hasReachedMax = workAnniversary.length < _limit;

      if (result['error'] == false) {
        emit(WorkAnniversaryPaginated(workAnniversary: workAnniversary, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((WorkAnniversaryError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
      // emit(WorkAnniversaryLoading());
      // List<WorkAnniversarys> workAnniversary = await WorkAnniversaryRepo().getWorkAnniversary(token: true);

      // emit(AllWorkAnniversarySuccess(workAnniversary));
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((WorkAnniversaryError("Error: $e")));
    }
  }




  Future<void> _onLoadMoreWorkAnniversary(
      LoadMoreWorkAnniversary event, Emitter<WorkAnniversaryState> emit) async {

    if (state is WorkAnniversaryPaginated && !_hasReachedMax) {
      try {
        List<WorkAnniversaryModel> additionalNotes = [];
        final currentState = state as WorkAnniversaryPaginated;
        final updatedNotes = List<WorkAnniversaryModel>.from(currentState.workAnniversary);
         Map<String,dynamic> result = await WorkAnniversaryRepo().getWorkAnniversary(limit: _limit, offset: _offset, token: true,upComingDays: event.upcomingDays,userId:event.userId);
        if (result['error'] == false) {
          additionalNotes = List<WorkAnniversaryModel>.from(result['data']
              .map((projectData) => WorkAnniversaryModel.fromJson(projectData)));
          _offset = updatedNotes.length + additionalNotes.length;

          if (updatedNotes.length + additionalNotes.length >= result['total']) {
            _hasReachedMax = true;
          } else {
            _hasReachedMax = false;
          }
          updatedNotes.addAll(additionalNotes);
          if (result['error'] == false) {
          emit(WorkAnniversaryPaginated(workAnniversary: updatedNotes, hasReachedMax: _hasReachedMax));
        }
        if (result['error'] == true) {
          emit((WorkAnniversaryError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }
        }} on ApiException catch (e) {
        // Handle any errors that occur during the API call
        emit(WorkAnniversaryError("Error: $e"));
      }
    }
  }

}
