import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';


import '../../data/model/tags/tag_model.dart';
import '../../data/repositories/tags/tag_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'tags_event.dart';
import 'tags_state.dart';

class TagsBloc extends Bloc<TagsEvent, TagsState> {


  TagsBloc() : super(TagsInitial()) {
    on<TagsList>(_getTagsList);
    on<SelectedTags>(_selectTags);
    on<TagsLoadMore>(_loadMoreTags);
    on<ToggleTagsSelection>(_toggleTagsSelection);


  }
  Future<void> _getTagsList(TagsList event, Emitter<TagsState> emit) async {
    try {
      List<TagsModel> tags =[];
      Map<String,dynamic> result = await TagRepo().getTags(token: true,limit: 100,offset: 0);
      tags = List<TagsModel>.from(result['data']
          .map((projectData) => TagsModel.fromJson(projectData)));
      if (result['error'] == false) {
        emit(TagsSuccess(tag: tags));
      }
      if (result['error'] == true) {
        emit((TagsError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TagsError("Error: $e")));
    }
  }

  Future<void> _loadMoreTags(
      TagsLoadMore event, Emitter<TagsState> emit) async {
    if (state is TagsSuccess) {
      final currentState = state as TagsSuccess;
      try {
        List<TagsModel> moreTags =[];
        Map<String,dynamic> result
      =  await TagRepo().getTags(token: true,limit: 20,offset: 0);
        moreTags = List<TagsModel>.from(result['data']
            .map((projectData) => TagsModel.fromJson(projectData)));
        if (result['error'] == false) {
          emit(TagsSuccess(
            tag: [...currentState.tag, ...moreTags],
            selectedIndices: currentState.selectedIndices,
            selectedTagsnames: currentState.selectedTagsnames,
            isLoadingMore: false,
          ));
        }
        if (result['error'] == true) {
          emit((TagsError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }

      } on ApiException catch (e) {
        if (kDebugMode) {
          print(e);
        }
        emit(TagsError("Error: $e"));
      }
    }
  }

  void _selectTags(SelectedTags event, Emitter<TagsState> emit) {
    if (state is TagsSuccess) {
      final currentState = state as TagsSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedTagsnames =
      List<String>.from(currentState.selectedTagsnames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedTagsnames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedTagsnames.add(event.selectedTitle);
      }

      emit(TagsSuccess(
        tag: currentState.tag,
        selectedIndices: selectedIndices,
        selectedTagsnames: selectedTagsnames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

  void _toggleTagsSelection(ToggleTagsSelection event, Emitter<TagsState> emit) {
    if (state is TagsSuccess) {
      final currentState = state as TagsSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedTagsIds = List<int>.from(currentState.selectedIndices);
      final updatedSelectedTagsnames = List<String>.from(currentState.selectedTagsnames);

      // Check if the Tags is already selected based on TagsId
      final isSelected = updatedSelectedTagsIds.contains(event.tagsId);

      if (isSelected) {
        // Find the index of the TagsId in the selectedIndices list
        final removeIndex = updatedSelectedTagsIds.indexOf(event.tagsId);

        // Remove TagsId and corresponding Tagsname
        updatedSelectedTagsIds.removeAt(removeIndex);
        updatedSelectedTagsnames.removeAt(removeIndex);
      } else {
        // Add TagsId and corresponding Tagsname
        updatedSelectedTagsIds.add(event.tagsId);
        updatedSelectedTagsnames.add(event.tagsName);
      }

      // Emit the updated state
      emit(TagsSuccess(
        tag: currentState.tag,
        selectedIndices: updatedSelectedTagsIds,
        selectedTagsnames: updatedSelectedTagsnames,
        isLoadingMore: currentState.isLoadingMore,
      ));

    }
  }

}
