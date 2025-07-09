import 'package:equatable/equatable.dart';

import '../../data/model/work_anniversary/work_anni_model.dart';


abstract class WorkAnniversaryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkAnniversaryInitial extends WorkAnniversaryState {}

class WorkAnniversaryLoading extends WorkAnniversaryState {}
class TodaysWorkAnniversaryLoading extends WorkAnniversaryState {}

class WorkAnniversarySuccess extends WorkAnniversaryState {
  WorkAnniversarySuccess(this.workAnniversary,);

  final List<WorkAnniversaryModel> workAnniversary;

  @override
  List<Object> get props => [workAnniversary];
}
class AllWorkAnniversarySuccess extends WorkAnniversaryState {
  AllWorkAnniversarySuccess(this.allWorkAnniversary,);

  final List<WorkAnniversaryModel> allWorkAnniversary;

  @override
  List<Object> get props => [allWorkAnniversary];
}

class WorkAnniversaryError extends WorkAnniversaryState {
  final String errorMessage;

  WorkAnniversaryError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class WorkAnniversaryPaginated extends WorkAnniversaryState {
  final List<WorkAnniversaryModel> workAnniversary;
  final bool hasReachedMax;

  WorkAnniversaryPaginated({
    required this.workAnniversary,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [workAnniversary, hasReachedMax];
}
class TodayWorkAnniversarySuccess extends WorkAnniversaryState {
  final List<WorkAnniversaryModel> workAnniversary;
  final bool hasReachedMax;

  TodayWorkAnniversarySuccess({
    required this.workAnniversary,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [workAnniversary, hasReachedMax];
}