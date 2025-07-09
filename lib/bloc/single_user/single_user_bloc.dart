import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/single_user/single_user_event.dart';
import 'package:taskify/bloc/single_user/single_user_state.dart';


import '../../data/model/user_model.dart';
import '../../data/repositories/user/user_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class SingleUserBloc extends Bloc<SingleUserEvent, SingleUserState> {
  SingleUserBloc() : super(SingleUserInitial()) {
    on<SingleUserList>(_getSingleUserList);
    on<SelectSingleUser>(_selectSingleUser);
    on<SingleUserLoadMore>(_loadMoreSingleUseres);
  }
  Future<void> _getSingleUserList(
      SingleUserList event, Emitter<SingleUserState> emit) async {
    try {
      // emit(SingleUserLoading());
      List<User> singleUsers =[];
      Map<String,dynamic> result
      = await UserRepo().getUsers(
        token: true,
        offset: event.offset,
        limit: event.limit,
      );
      singleUsers = List<User>.from(result['data']
          .map((projectData) => User.fromJson(projectData)));
      if (result['error'] == false) {
        emit(SingleUserSuccess(singleUsers, -1, '', false));
      }
      if (result['error'] == true) {
        emit((SingleUserError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((SingleUserError("Error: $e")));
    }
  }

  Future<void> _loadMoreSingleUseres(
      SingleUserLoadMore event, Emitter<SingleUserState> emit) async {
    if (state is SingleUserSuccess) {
      final currentState = state as SingleUserSuccess;
      try {
        List<User> moreSingleUseres=[];
        Map<String,dynamic> result
        = await UserRepo().getUsers(
          token: true,
          offset: currentState.user.length,
          limit: 10,
        );
        moreSingleUseres = List<User>.from(result['data']
            .map((projectData) => User.fromJson(projectData)));
        if (result['error'] == false) {
          emit(SingleUserSuccess([...currentState.user, ...moreSingleUseres],
              currentState.selectedIndex, currentState.selectedTitle, false));        }
        if (result['error'] == true) {
          emit((SingleUserError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }

      } on ApiException catch (e) {
        if (kDebugMode) {
          print(e);
        }
        emit(SingleUserError("Error: $e"));
      }
    }
  }

  void _selectSingleUser(SelectSingleUser event, Emitter<SingleUserState> emit) {
    if (state is SingleUserSuccess) {
      final currentState = state as SingleUserSuccess;
      emit(SingleUserSuccess(currentState.user, event.selectedIndex,
          event.selectedTitle, false));
    }
  }


}