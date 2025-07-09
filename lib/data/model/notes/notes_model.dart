import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final bool? error;
  final String? message;
  final int? id;
  final NotesModel? data;

  const Note({this.error, this.message, this.id, this.data});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
        error : json['error'],
        message : json['message'],
        id : json['id'],
        data : json['data'] != null ? NotesModel.fromJson(json['data']) : null
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['id'] = id;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  @override
  List<Object?> get props => [error, message, id, data];
}

class NotesModel extends Equatable {
  final int? id;
  final int? workspaceId;
  final String? creatorId;
  final String? title;
  final String? description;
  final String? noteType;
  final String? color;
  final String? createdAt;
  final String? updatedAt;

  const NotesModel(
      {this.id,
        this.workspaceId,
        this.creatorId,
        this.title,
        this.description,
        this.noteType,
        this.color,
        this.createdAt,
        this.updatedAt});

  NotesModel copyWith(
      {int? id,
        int? workspaceId,
        String? creatorId,
        String? title,
        String? description,
        String? color,
        String? createdAt,
        String? updatedAt}) {
    return NotesModel(
        id: id ?? this.id,
        workspaceId: workspaceId ?? this.workspaceId,
        creatorId: creatorId ?? this.creatorId,
        title: title ?? this.title,
        noteType: noteType ?? this.noteType,
        description: description ?? this.description,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  factory NotesModel.fromJson(Map<String, dynamic> json) {

    return NotesModel(
        id : json['id'],
        workspaceId : json['workspace_id'],
        creatorId : json['creator_id'],
        title : json['title'],
        noteType : json['note_type'],
        description : json['description'],
        color : json['color'],
        createdAt : json['created_at'],
        updatedAt : json['updated_at']
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['workspace_id'] = workspaceId;
    data['creator_id'] = creatorId;
    data['title'] = title;
    data['note_type'] = noteType;
    data['description'] = description;
    data['color'] = color;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    creatorId,
    title,
    description,
    color,
    createdAt,
    updatedAt
  ];
}
