import "package:equatable/equatable.dart";
import "../../data/model/leave_request/dashboard_leavereq.dart";




abstract class LeaveReqDashboardState extends Equatable{
  const LeaveReqDashboardState();

  @override
  List<Object?> get props => [];
}

class LeaveRequestDashboardInitial extends LeaveReqDashboardState {}

class LeaveRequestDashboardLoading extends LeaveReqDashboardState {}
class LeaveRequestDashboardSuccess extends LeaveReqDashboardState {
  final List<DashBoardLeaveReq> leave;
  final bool hasReachedMax;

  const LeaveRequestDashboardSuccess({
    required this.leave,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [leave, hasReachedMax];
}
class LeaveRequestDasdhboardError extends LeaveReqDashboardState {
  final String errorMessage;

  const LeaveRequestDasdhboardError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

