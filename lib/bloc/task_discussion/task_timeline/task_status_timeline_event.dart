part of 'task_status_timeline_bloc.dart';

@immutable
sealed class TaskStatusTimelineEvent {}
class TaskStatusTimelineList extends TaskStatusTimelineEvent {
  final int? id;


  TaskStatusTimelineList({this.id,});

  @override
  List<Object?> get props => [id];
}
class DeleteTaskMedia extends TaskStatusTimelineEvent {
  final int? id;


  DeleteTaskMedia({this.id,});

  @override
  List<Object?> get props => [id];
}
