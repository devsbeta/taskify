

import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/project/media.dart';

abstract class ProjectMediaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectMediaInitial extends ProjectMediaState {}
class ProjectMediaLoading extends ProjectMediaState {}

class ProjectMediaSuccess extends ProjectMediaState {}
class ProjectMediaPaginated extends ProjectMediaState {
  final List<MediaModel> ProjectMedia;
  final bool hasReachedMax;


  ProjectMediaPaginated({
    required this.ProjectMedia,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [ProjectMedia, hasReachedMax];
}
class ProjectMediaError extends ProjectMediaState {
  final String errorMessage;
  ProjectMediaError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DownloadInProgress extends ProjectMediaState {
  final double progress;
  final String fileName;
  DownloadInProgress(this.progress,this.fileName);

  @override
  List<Object?> get props => [progress];
}

class DownloadSuccess extends ProjectMediaState {
  final String filePath;
  final String fileName;
  DownloadSuccess(this.filePath,this.fileName);

  @override
  List<Object?> get props => [filePath];
}

class DownloadFailure extends ProjectMediaState {
  final String error;
  DownloadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
class ProjectMediaDeleteSuccess extends ProjectMediaState {
  ProjectMediaDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
class ProjectMediaUploadSuccess extends ProjectMediaState {
  ProjectMediaUploadSuccess();
  @override
  List<Object> get props =>
      [];
}