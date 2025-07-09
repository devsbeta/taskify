import "package:equatable/equatable.dart";

import "../../data/model/notes/notes_model.dart";


abstract class NotesEvent extends Equatable{
 const NotesEvent();

 @override
 List<Object?> get props => [];
}
 class CreateNotes extends NotesEvent{
 final String title;
  final String desc;
  final String createdAt;
  final bool token;
 const CreateNotes({required this.desc,required this.token,required this.title,required this.createdAt});

 @override
 List<Object> get props => [title,desc,token];
}

class NotesList extends NotesEvent {

 const NotesList();

 @override
 List<Object?> get props => [];
}
class AddNotes extends NotesEvent {
 final NotesModel notes;

 const AddNotes(this.notes);

 @override
 List<Object?> get props => [notes];
}

class UpdateNotes extends NotesEvent {
 final NotesModel notes;

 const UpdateNotes(this.notes);

 @override
 List<Object?> get props => [notes];
}

class DeleteNotes extends NotesEvent {
 final int notes;

 const DeleteNotes(this.notes );

 @override
 List<Object?> get props => [notes];
}
class SearchNotes extends NotesEvent {
 final String searchQuery;

 const SearchNotes(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreNotes extends NotesEvent {
 final String searchQuery;

 const LoadMoreNotes(this.searchQuery);

 @override
 List<Object?> get props => [];
}
