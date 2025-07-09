
import 'package:equatable/equatable.dart';

abstract class TagsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TagsList extends TagsEvent {

  TagsList();
  @override
  List<Object> get props => [];
}


class TagsLoadMore extends TagsEvent {
  final String search;
  TagsLoadMore({required this.search});
  @override
  List<Object> get props => [search];

}
class SelectedTags extends TagsEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedTags(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

class ToggleTagsSelection extends TagsEvent {
  final int tagsId;
  final String tagsName;

  ToggleTagsSelection(this.tagsId, this.tagsName);
}
