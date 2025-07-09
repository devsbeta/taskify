import 'package:taskify/config/end_points.dart';
import '../../../api_helper/api_base_helper.dart';


class TagRepo{
  Future<Map<String, dynamic>> getTags(
      {
        int? offset,
        int? limit,
        String? search,
        required bool token,
      }) async {


    try {
      Map<String, dynamic> body = {"limit": limit, "offset": offset};
      if (search != null) {
        body["search"] = search;
      }
      if (limit != null) {
        body["limit"] = limit;
      }
      if (offset != null) {
        body["offset"] = offset;
      }
      print("USER REPO ");
      final response = await ApiBaseHelper.getApi(
        url: getTagUrl,
        useAuthToken: true, params: body,
      );
      return response;
    } catch (error) {
      print("=======Error ${error.toString()}");
      throw Exception('Error occurred');
    }
  }
}