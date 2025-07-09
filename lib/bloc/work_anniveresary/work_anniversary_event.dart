import 'package:equatable/equatable.dart';


abstract class WorkAnniversaryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllWorkAnniversaryList extends WorkAnniversaryEvent {
  AllWorkAnniversaryList();

  @override
  List<Object> get props => [];
}
class WeekWorkAnniversaryList extends WorkAnniversaryEvent {
  final int upcomingDays;
  final List<int>? userId;
  final List<int>? clientId;
  WeekWorkAnniversaryList(this.userId,this.clientId,this.upcomingDays);

  @override
  List<Object> get props => [upcomingDays,userId!];
}
class LoadMoreWorkAnniversary extends WorkAnniversaryEvent {
  final int upcomingDays;
  final List<int>? userId;
  LoadMoreWorkAnniversary(this.upcomingDays,this.userId);

  @override
  List<Object?> get props => [upcomingDays,userId];
}