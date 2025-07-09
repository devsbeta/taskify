part of 'status_timeline_bloc.dart';

@immutable
sealed class StatusTimelineEvent {}
class StatusTimelineList extends StatusTimelineEvent {
  final int? id;


  StatusTimelineList({this.id,});

  @override
  List<Object?> get props => [id];
}
class DeleteProjectMedia extends StatusTimelineEvent {
  final int? id;


  DeleteProjectMedia({this.id,});

  @override
  List<Object?> get props => [id];
}
