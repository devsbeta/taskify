import "package:equatable/equatable.dart";


abstract class LeaveReqDashboardEvent extends Equatable {
  const LeaveReqDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadMoreLeaveRequestDashboard extends LeaveReqDashboardEvent {
  final String? searchQuery;
  const LoadMoreLeaveRequestDashboard(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
class WeekLeaveReqListDashboard extends LeaveReqDashboardEvent {
  final int upComingDays;
  final List<int> userID;
  const WeekLeaveReqListDashboard(this.userID,this.upComingDays);

  @override
  List<Object> get props => [upComingDays,userID];
}
class WeekLeaveReqListDashboardLoadMore extends LeaveReqDashboardEvent {
  final int upComingDays;
  final List<int> userID;
  const WeekLeaveReqListDashboardLoadMore(this.userID,this.upComingDays);

  @override
  List<Object> get props => [upComingDays,userID];
}