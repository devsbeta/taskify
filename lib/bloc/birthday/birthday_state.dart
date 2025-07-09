import 'package:equatable/equatable.dart';
import '../../data/model/Birthday/birthday_model.dart';

abstract class BirthdayState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BirthdayInitial extends BirthdayState {}

class BirthdayLoading extends BirthdayState {}
class TodaysBirthdayLoading extends BirthdayState {}

class BirthdaySuccess extends BirthdayState {
  BirthdaySuccess(this.birthday,);

  final List<BirthdayModel> birthday;

  @override
  List<Object> get props => [birthday];
}
class AllBirthdaySuccess extends BirthdayState {
  AllBirthdaySuccess(this.allBirthday,);

  final List<BirthdayModel> allBirthday;

  @override
  List<Object> get props => [allBirthday];
}

class BirthdayError extends BirthdayState {
  final String errorMessage;

  BirthdayError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class BirthdayPaginated extends BirthdayState {
  final List<BirthdayModel> birthday;
  final bool hasReachedMax;

  BirthdayPaginated({
    required this.birthday,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [birthday, hasReachedMax];
}
class TodayBirthdaySuccess extends BirthdayState {
  final List<BirthdayModel> birthday;
  final bool hasReachedMax;

  TodayBirthdaySuccess({
    required this.birthday,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [birthday, hasReachedMax];
}