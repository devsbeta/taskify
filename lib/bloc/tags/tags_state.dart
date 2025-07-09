import 'package:equatable/equatable.dart';

import '../../data/model/tags/tag_model.dart';



abstract class TagsState extends Equatable{
  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}
class TagsLoading extends TagsState {}
class TagsSuccess extends TagsState {
  final List<TagsModel> tag;
  final List<int> selectedIndices;
  final List<String> selectedTagsnames;
  final bool isLoadingMore;

  TagsSuccess({
    required this.tag,
    this.selectedIndices = const [],
    this.selectedTagsnames = const [],
    this.isLoadingMore = false,
  });
}


class TagsError extends TagsState {
  final String errorMessage;
  TagsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
