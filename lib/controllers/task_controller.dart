import '../exports.dart';

class TaskController extends GetxController {
  final RxList<TaskModel> _taskList = <TaskModel>[].obs;
  List<TaskModel> get taskList => _taskList;
  final RxBool _isLoading = false.obs;

  Future<List<TaskModel>> getTaskList({required int? projectId}) async {
    try {
      _isLoading.value = true;
      final apiResponse = await ApiManager.getRequest(
        endPoint: 'tasks',
        queryParameters: {
          if (projectId != null) 'project_id': projectId.toString(),
        },
      );
      final result =
          (apiResponse.body['data'] as List)
              .map((e) => TaskModel.fromJson(e))
              .toList();
      _taskList.value = result;
      return result;
    } catch (e) {
      _taskList.value = [];
      return [];
    } finally {
      _isLoading.value = false;
    }
  }
}
