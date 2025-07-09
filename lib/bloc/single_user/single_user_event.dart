

import 'package:equatable/equatable.dart';

abstract class SingleUserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SingleUserList extends SingleUserEvent {
  final int offset;
  final int limit;

  SingleUserList({required this.offset,required this.limit});
  @override
  List<Object> get props => [offset,limit];
}
class SingleUserLoadMore extends SingleUserEvent {}
class SelectSingleUser extends SingleUserEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectSingleUser(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

