import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../api_helper/api.dart';
import '../../data/model/leave_request/dashboard_leavereq.dart';
import '../../data/repositories/leave_request/leave_request_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'leave_req_dashboard_event.dart';
import 'leave_req_dashboard_state.dart';

class LeaveReqDashboardBloc
    extends Bloc<LeaveReqDashboardEvent, LeaveReqDashboardState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  LeaveReqDashboardBloc() : super(LeaveRequestDashboardInitial()) {
    on<WeekLeaveReqListDashboard>(_weekLeavereq);
    on<WeekLeaveReqListDashboardLoadMore>(_onLoadMoreLeaveReq);
  }

  Future<void> _weekLeavereq(WeekLeaveReqListDashboard event,
      Emitter<LeaveReqDashboardState> emit) async {
    try {
      List<DashBoardLeaveReq> leave = [];

      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(LeaveRequestDashboardLoading());
      Map<String, dynamic> result = await LeaveRequestRepo()
          .memberOnLeaveRequestList(
              limit: _limit,
              offset: _offset,
              token: true,
              upcomingDays: event.upComingDays,
              userId: event.userID,
              search: '');
     if(result['data'] != null){
       leave = List<DashBoardLeaveReq>.from(result['data']
           .map((projectData) => DashBoardLeaveReq.fromJson(projectData)));
     }

      _offset += _limit;
      _hasReachedMax = leave.length < _limit;

      if (result['error'] == false) {

        emit(LeaveRequestDashboardSuccess(
          leave: leave,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((LeaveRequestDasdhboardError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((LeaveRequestDasdhboardError("Error: $e")));
    }
  }

  Future<void> _onLoadMoreLeaveReq(WeekLeaveReqListDashboardLoadMore event,
      Emitter<LeaveReqDashboardState> emit) async {
    if (state is LeaveRequestDashboardSuccess && !_hasReachedMax) {
      try {
        List<DashBoardLeaveReq> additionalNotes = [];
        final currentState = state as LeaveRequestDashboardSuccess;
        final updatedNotes = List<DashBoardLeaveReq>.from(currentState.leave);

        Map<String, dynamic> result = await LeaveRequestRepo()
            .memberOnLeaveRequestList(
                limit: _limit,
                offset: _offset,
                token: true,
                upcomingDays: event.upComingDays,
                userId: event.userID,
                search: '');
        if (result['error'] == false) {
          additionalNotes = List<DashBoardLeaveReq>.from(result['data']
              .map((projectData) => DashBoardLeaveReq.fromJson(projectData)));
          _offset = additionalNotes.length;
          if (updatedNotes.length + additionalNotes.length >= result['total']) {
            _hasReachedMax = true;
          } else {
            _hasReachedMax = false;
          }

          updatedNotes.addAll(additionalNotes);
          if (result['error'] == false) {
            emit(LeaveRequestDashboardSuccess(
                leave: updatedNotes, hasReachedMax: _hasReachedMax));
          }
          if (result['error'] == true) {
            emit((LeaveRequestDasdhboardError(result['message'])));
            flutterToastCustom(msg: result['message']);
          }
        }
      } on ApiException catch (e) {
        // Handle any errors that occur during the API call
        emit(LeaveRequestDasdhboardError("Error: $e"));
      }
    }
  }
}
