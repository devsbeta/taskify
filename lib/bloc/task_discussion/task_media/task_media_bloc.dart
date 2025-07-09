import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskify/bloc/task_discussion/task_media/task_media_state.dart';


import '../../../api_helper/api.dart';

import '../../../data/model/project/media.dart';
import '../../../data/repositories/Task/Task_repo.dart';
import '../../../utils/widgets/toast_widget.dart';

part 'task_media_event.dart';

class TaskMediaBloc extends Bloc<TaskMediaEvent, TaskMediaState> {

  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  TaskMediaBloc() : super(TaskMediaInitial()) {
    on<TaskMediaList>(_getMediaLists);
    on<TaskStartDownload>(_onStartDownload);
    on<DeleteTaskMedia>(_deleteTaskMedia);
    on<TaskSearchMedia>(_onSearchMedia);
    on<UploadTaskMedia>(_onUploadMedia);

  }

  Future<void> _onUploadMedia(UploadTaskMedia event, Emitter<TaskMediaState> emit) async {
    try {
      print("fgf ${event.media}");
      Map<String, dynamic> result = await TaskRepo().uploadTaskMedia(
        id: event.id,
        media: event.media,
      );

      if (result['data']['error'] == false) {

        emit(TaskMediaUploadSuccess());
      }
      if (result['data']['error'] == true) {
        emit((TaskMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(TaskMediaError(e.toString()));
    }


  }
  Future<void> _onSearchMedia(
      TaskSearchMedia event, Emitter<TaskMediaState> emit) async {
    try {
      List<MediaModel> media=[];
print("esklfrdf'lMDFmlDF ${event.searchQuery}");
      Map<String,dynamic> result  = await TaskRepo().getTaskMedia(limit: _limit, offset: 0, search: event.searchQuery,id: event.id);
      media = List<MediaModel>.from(result['data']
          .map((TaskData) => MediaModel.fromJson(TaskData)));

      bool hasReachedMax = media.length >= result['total'];
      if (result['error'] == false) {
        emit(TaskMediaPaginated(
          TaskMediaList: media,
          hasReachedMax: hasReachedMax,
        )); }
      if (result['error'] == true) {
        emit((TaskMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      flutterToastCustom(msg:"$e");

      emit(TaskMediaError("Error: $e"));

    }
  }
  void _deleteTaskMedia(DeleteTaskMedia event, Emitter<TaskMediaState> emit) async {

    final Task = event.id;

    try {
      Map<String, dynamic> result = await TaskRepo().getDeleteTaskMedia(
        id: Task.toString(),
        token: true,
      );
      if (result['data']['error'] == false) {

        emit(TaskMediaDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((TaskMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(TaskMediaError(e.toString()));
    }
    // }
  }
  Future<void> _getMediaLists(
      TaskMediaList event, Emitter<TaskMediaState> emit) async {
    try {
      print("Fetching task media...");
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;

      if (state is! TaskDownloadSuccess) {
        emit(TaskMediaLoading());
      }

      Map<String, dynamic> result = await TaskRepo().getTaskMedia(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: '',
      );
      print("FeSGFK ${result['data']}");

      // Check if 'data' exists and is a List
      if (result['data'] == null || result['data'] is! List) {
        emit(TaskMediaError("Invalid response: Missing 'data' field"));
        return;
      }

      List<MediaModel> media = List<MediaModel>.from(
          result['data'].map((taskData) => MediaModel.fromJson(taskData)));

      if (event.id == null) {
        _offset += _limit;
      } else {
        _offset = 0;
      }

      _hasReachedMax = media.length >= result['total'];

      if (result['error'] == false) {
        emit(TaskMediaPaginated(
          TaskMediaList: media,
          hasReachedMax: _hasReachedMax,
        ));
      } else {
        emit(TaskMediaError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print("API Exception: $e");
      }
      emit(TaskMediaError("Error: $e"));
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected error: $e");
      }
      emit(TaskMediaError("Unexpected error occurred"));
    }
  }

  Future<void> _onStartDownload(TaskStartDownload event, Emitter<TaskMediaState> emit) async {
    emit(TaskDownloadInProgress(0.0,event.fileName));

    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        emit(TaskDownloadFailure("Storage permission denied"));
        return;
      }
    }

    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/${event.fileName}";
      Dio dio = Dio();
      await dio.download(
        event.fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            emit(TaskDownloadInProgress(received / total,event.fileName));
          }
        },
      );

      emit(TaskDownloadSuccess(filePath,event.fileName));
    } catch (e) {
      emit(TaskDownloadFailure(e.toString()));
    }
  }
}

