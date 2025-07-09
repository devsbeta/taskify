import '../data/localStorage/hive.dart';

Future<Map<String, String>?> get headers async {
  final String? token = await HiveStorage.getToken();
  final int? workspaceId = await HiveStorage.getWorkspaceId();
  print("Token: $token");
  print("Workspace ID: $workspaceId");
  if (token != null && token.trim().isNotEmpty) {
    return {
      'Authorization': 'Bearer $token',
      'workspace-id': workspaceId.toString()
    };
  }
  return null;
}
