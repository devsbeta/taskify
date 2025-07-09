import 'package:equatable/equatable.dart';

abstract class BirthdayEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllBirthdayList extends BirthdayEvent {
  final int upcomingDays;
  final List<int>? userId;
  AllBirthdayList(this.upcomingDays,this.userId);

  @override
  List<Object> get props => [upcomingDays,userId!];

}
class WeekBirthdayList extends BirthdayEvent {
  final int upcomingDays;
  final List<int>? userId;
  final List<int>? clientId;
  WeekBirthdayList(this.upcomingDays,this.userId,this.clientId);

  @override
  List<Object> get props => [upcomingDays,userId!];
}
class LoadMoreBirthday extends BirthdayEvent {
  final int upcomingDays;
  final List<int>? userId;
  LoadMoreBirthday(this.upcomingDays,this.userId);

  @override
  List<Object?> get props => [upcomingDays, userId!];
}