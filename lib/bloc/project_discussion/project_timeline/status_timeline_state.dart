part of 'status_timeline_bloc.dart';

@immutable
sealed class StatusTimelineState {}

final class StatusTimelineInitial extends StatusTimelineState {}

class ProjectStatusTimelineLoading extends StatusTimelineState {}

class ProjectStatusTimelineSuccess extends StatusTimelineState {}
class ProjectStatusTimelinePaginated extends StatusTimelineState {
  final List<StatusTimelineModel> ProjectTimeline;
  final bool hasReachedMax;


  ProjectStatusTimelinePaginated({
    required this.ProjectTimeline,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [ProjectTimeline, hasReachedMax];
}
class ProjectStatusTimelineError extends StatusTimelineState {
  final String errorMessage;
  ProjectStatusTimelineError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class ProjectStatusTimelineDeleteSuccess extends StatusTimelineState {
  ProjectStatusTimelineDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
