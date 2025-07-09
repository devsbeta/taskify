class AllProjectModel {
  bool? error;
  String? message;
  int? total;
  List<ProjectModel>? data;

  AllProjectModel({this.error, this.message, this.total, this.data});

  AllProjectModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    total = json['total'];
    if (json['data'] != null) {
      data = <ProjectModel>[];
      json['data'].forEach((v) {
        data!.add(ProjectModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProjectModel {
  int? id;
  String? title;
  String? status;
  int? statusId;
  String? priority;
  int? taskCount;
  int? priorityId;
  List<ProjectUsers>? users;
  List<int>? userId;
  List<ProjectClients>? clients;
  List<int>? clientId;
  List<Tag>? tags;
  List<int>? tagIds;
  String? startDate;
  String? endDate;
  String? budget;
  String? taskAccessibility;
  String? description;
  String? note;
  int? favorite;
  int? pinned;
  String? createdAt;
  int? clientCanDiscuss;
  String? updatedAt;

  ProjectModel(
      {this.id,
        this.title,
        this.status,
        this.statusId,
        this.priority,
        this.priorityId,
        this.taskCount,
        this.users,
        this.userId,
        this.clients,
        this.clientId,
        this.tags,
        this.tagIds,
        this.startDate,
        this.endDate,
        this.budget,
        this.clientCanDiscuss,
        this.taskAccessibility,
        this.description,
        this.note,
        this.favorite,
        this.pinned,
        this.createdAt,
        this.updatedAt});

  ProjectModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    title = json['title'] ?? "";
    status = json['status'] ?? "";
    statusId = json['status_id'] ?? 0;
    priority = json['priority'] ?? "";
    taskCount = json['task_count'] ?? 0;
    priorityId = json['priority_id'] ?? 0;

    users = (json['users'] as List?)?.map((v) => ProjectUsers.fromJson(v)).toList() ?? [];
    userId = (json['user_id'] as List?)?.map((e) => e as int).toList() ?? [];

    clients = (json['clients'] as List?)?.map((v) => ProjectClients.fromJson(v)).toList() ?? [];
    clientId = (json['client_id'] as List?)?.map((e) => e as int).toList() ?? [];

    tags = (json['tags'] as List?)?.map((v) => Tag.fromJson(v)).toList() ?? [];
    tagIds = (json['tag_ids'] as List?)?.map((e) => e as int).toList() ?? [];

    startDate = json['start_date'] ?? "";
    endDate = json['end_date'] ?? "";
    budget = json['budget'] ?? "";
    taskAccessibility = json['task_accessibility'] ?? "";
    clientCanDiscuss = json['client_can_discuss'] ?? 0;
    description = json['description'] ?? "";
    note = json['note'] ?? "";
    favorite = json['favorite'] ?? 0;
    pinned = json['pinned'] ?? 0;
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['status'] = status;
    data['status_id'] = statusId;
    data['priority'] = priority;
    data['task_count'] = taskCount;
    data['priority_id'] = priorityId;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    data['user_id'] = userId;
    if (clients != null) {
      data['clients'] = clients!.map((v) => v.toJson()).toList();
    }
    data['client_id'] = clientId;
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    data['tag_ids'] = tagIds;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['budget'] = budget;
    data['task_accessibility'] = taskAccessibility;
    data['client_can_discuss'] = this.clientCanDiscuss;
    data['description'] = description;
    data['note'] = note;
    data['favorite'] = favorite;
    data['pinned'] = pinned;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ProjectUsers {
  int? id;
  String? firstName;
  String? lastName;
  String? photo;
  String? email;

  ProjectUsers({this.id, this.firstName, this.lastName, this.photo});

  ProjectUsers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['photo'] = photo;
    return data;
  }
}
class ProjectClients {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? photo;

  ProjectClients({this.id, this.firstName, this.lastName, this.photo});

  ProjectClients.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    photo = json['photo'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['photo'] = photo;
    data['email'] = email;
    return data;
  }
}
class Tag{
  int? id;
  String? title;

  Tag({this.id, this.title});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}
