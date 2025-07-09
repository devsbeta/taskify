import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/data/repositories/permissions/permission_repo.dart';
import '../../api_helper/api.dart';
import 'permissions_state.dart';


class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  
   bool? iscreateProject;
   bool? isManageProject;
   bool? iseditProject;
   bool? isdeleteProject;

   bool? iscreatetask;
   bool? isManageTask;
   bool? iseditTask;
   bool? isdeleteTask;

   bool? iscreateClient;
   String? isGuard;
   bool? isLeaveEditor;
   String? roleIS;
   bool? hasAllAccess;
   bool? isManageClient;
   bool? iseditClient;
   bool? isdeleteClient;

   bool? iscreatePriority;
   bool? isManagePriority;
   bool? iseditPriority;
   bool? isdeletePriority;

   bool? iscreateMeeting;
   bool? isManageMeeting;
   bool? iseditMeeting;
   bool? isdeleteMeeting;

   bool? iscreateStatus;
   bool? isManageStatus;
   bool? iseditStatus;
   bool? isdeleteStatus;

   bool? iscreateTags;
   bool? isManageTags;
   bool? iseditTags;
   bool? isdeleteTags;
   int? userId;

   bool? iscreateUser;
   bool? isManageUser;
   bool? iseditUser;
   bool? isdeleteUser;

   bool? iscreateWorkspace;
   bool? isManageWorkspace;
   bool? iseditWorkspace;
   bool? isdeleteWorkspace;

   bool? isManageActivityLog;
   bool? isdeleteActivityLog;
bool? isManageSystenNotification;
bool? isDeleteSystenNotification;
   bool? isManageSystemNotification;
   bool? isdeleteSystemNotification;
  PermissionsBloc() : super(PermissionsInitial()) {

    on<GetPermissions>(_getPermissions);

  }

  Future<void> _getPermissions(GetPermissions event, Emitter<PermissionsState> emit) async {
    try {

      Map<String,dynamic> result = await PermissionRepo().getPermissions(token: true, );

      var permission= result['data']['permissions'];

      isManageProject = permission['manage_projects'];
      isManageActivityLog = permission['manage_activity_log'];
      isdeleteActivityLog = permission['delete_activity_log'];
      iscreateClient = permission['create_clients'];
      isManageClient = permission['manage_clients'];
      iseditClient = permission['edit_clients'];
      isdeleteClient = permission['delete_clients'];
      iscreateMeeting = permission['create_meetings'];
      isManageMeeting = permission['manage_meetings'];
      iseditMeeting = permission['edit_meetings'];
      isdeleteMeeting = permission['delete_meetings'];
      iscreatePriority = permission['create_priorities'];
      isManagePriority = permission['manage_priorities'];
      iseditPriority = permission['edit_priorities'];
      isdeletePriority = permission['delete_priorities'];
      iscreateProject = permission['create_projects'];
      iseditProject = permission['edit_projects'];
      isdeleteProject = permission['delete_projects'];
      iscreateStatus = permission['create_statuses'];
      isManageStatus= permission['manage_statuses'];
      iseditStatus = permission['edit_statuses'];
      isdeleteStatus = permission['delete_statuses'];
      isManageSystemNotification = permission['manage_system_notifications'];
      isdeleteSystemNotification = permission['delete_system_notifications'];
      iscreateTags = permission['create_tags'];
      isManageTags = permission['manage_tags'];
      iscreateTags = permission['create_tags'];
      iseditTags = permission['edit_tags'];
      isdeleteTags = permission['delete_tags'];
      iscreatetask= permission['create_tasks'];
      isManageTask = permission['manage_tasks'];
      iseditTask = permission['edit_tasks'];
      isdeleteTask = permission['delete_tasks'];
      iscreateUser = permission['create_users'];
      isManageUser = permission['manage_users'];
      iseditUser = permission['edit_users'];
      isdeleteUser = permission['delete_users'];
      iscreateWorkspace = permission['create_workspaces'];
      isManageWorkspace = permission['manage_workspaces'];
      iseditWorkspace = permission['edit_workspaces'];
      isdeleteWorkspace = permission['delete_workspaces'];


      emit(PermissionsSuccess());
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PermissionsError("Error: ${e.errorMessage}")));
    }
  }

}
