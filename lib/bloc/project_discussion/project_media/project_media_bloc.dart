import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taskify/bloc/project_discussion/project_media/project_media_state.dart';
import 'package:path_provider/path_provider.dart';

import '../../../api_helper/api.dart';
import '../../../data/model/project/media.dart';
import '../../../data/repositories/Project/project_repo.dart';
import '../../../utils/widgets/toast_widget.dart';

part 'project_media_event.dart';

class ProjectMediaBloc extends Bloc<ProjectMediaEvent, ProjectMediaState> {

  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  ProjectMediaBloc() : super(ProjectMediaInitial()) {
    on<MediaList>(_getMediaLists);
    on<StartDownload>(_onStartDownload);
    on<DeleteProjectMedia>(_deleteProjectMedia);
    on<SearchMedia>(_onSearchMedia);
    on<UploadMedia>(_onUploadMedia);

  }
  Future<void> _onUploadMedia(UploadMedia event, Emitter<ProjectMediaState> emit) async {
    try {
      print("fgf ${event.media}");
      Map<String, dynamic> result = await ProjectRepo().uploadProjectMedia(
        id: event.id,
        media: event.media,
      );

      if (result['data']['error'] == false) {

        emit(ProjectMediaUploadSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(ProjectMediaError(e.toString()));
    }


  }
  Future<void> _onSearchMedia(SearchMedia event, Emitter<ProjectMediaState> emit) async {
    try {
      List<MediaModel> media=[];
print("esklfrdf'lMDFmlDF ${event.searchQuery}");
      Map<String,dynamic> result  = await ProjectRepo().getProjectMedia(limit: _limit, offset: 0, search: event.searchQuery,id: event.id);
      media = List<MediaModel>.from(result['data']
          .map((projectData) => MediaModel.fromJson(projectData)));

      bool hasReachedMax = media.length >= result['total'];
      if (result['error'] == false) {
        emit(ProjectMediaPaginated(
          ProjectMedia: media,
          hasReachedMax: hasReachedMax,
        )); }
      if (result['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      flutterToastCustom(msg:"$e");

      emit(ProjectMediaError("Error: $e"));

    }
  }
  void _deleteProjectMedia(DeleteProjectMedia event, Emitter<ProjectMediaState> emit) async {

    final project = event.id;

    try {
      Map<String, dynamic> result = await ProjectRepo().getDeleteProjectMedia(
        id: project.toString(),
        token: true,
      );
      if (result['data']['error'] == false) {

        emit(ProjectMediaDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(ProjectMediaError(e.toString()));
    }
    // }
  }
  Future<void> _getMediaLists(
      MediaList event, Emitter<ProjectMediaState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      if(state is DownloadSuccess){}else {
        emit(ProjectMediaLoading());
      }
      List<MediaModel> media = [];
      Map<String, dynamic> result = await ProjectRepo().getProjectMedia(
          id: event.id,
          limit: _limit,
          offset: _offset,
          search: '',


      );
      media = List<MediaModel>.from(
          result['data'].map((projectData) => MediaModel.fromJson(projectData)));


      if (event.id != null) {
        _offset = 0;
      } else {
        _offset += _limit;
      }
      _hasReachedMax = media.length >= result['total'];

      if (result['error'] == false) {
        emit(ProjectMediaPaginated(
          ProjectMedia: media,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectMediaError("Error: $e")));
    }
  }
  Future<void> _onStartDownload(StartDownload event, Emitter<ProjectMediaState> emit) async {
    emit(DownloadInProgress(0.0, event.fileName));

    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        emit(DownloadFailure("Storage permission denied"));
        return;
      }

      // For Android 11+
      if (await Permission.manageExternalStorage.request().isDenied) {
        emit(DownloadFailure("Manage Storage permission denied"));
        return;
      }
    }

    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Download");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath = "${directory.path}/${event.fileName}";
      Dio dio = Dio();
      await dio.download(
        event.fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            emit(DownloadInProgress(received / total, event.fileName));
          }
        },
      );

      emit(DownloadSuccess(filePath, event.fileName));
    } catch (e) {
      emit(DownloadFailure(e.toString()));
    }
  }

}

