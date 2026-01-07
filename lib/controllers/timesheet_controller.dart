import 'package:intl/intl.dart';
import 'package:pi_task_watch/exports.dart';
import 'package:pi_task_watch/models/idle_time_data.dart';
import 'package:pi_task_watch/models/timesheet_model.dart';

class TimesheetController extends GetxController {
  RxList<TimesheetModel> timesheetList = <TimesheetModel>[].obs;

  Future<List<TimesheetModel>> getAllTimesheet({required DateTime date}) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final apiResponse = await ApiManager.getRequest(
      endPoint: "timesheets",
      queryParameters: {"date": formattedDate},
    );

    final result = apiResponse.body['timesheets'];

    final items =
        result == null
            ? <TimesheetModel>[]
            : (result as List).map((e) => TimesheetModel.fromJson(e));

    timesheetList.value = items.toList();

    return items.toList();
  }

  //

  Future<int?> updateSyncTimesheet({
    required StartWorkModel startWorkData,
  }) async {
    //
    final apiResponse = await ApiManager.postRequest(
      endPoint: "timesheets",
      data: startWorkData.toCustomJson(),
    );
    final result = int.tryParse("${apiResponse.body['timesheet_id']}");
    return result;
    //
  }

  //
  Future<bool> updateSyncIdle({required IdleTimeData idleData}) async {
    //
    final apiResponse = await ApiManager.postRequest(
      endPoint: "taskwatch_idle",
      data: idleData.toJson(),
    );
    return apiResponse.isSuccess;
    //
  }

  //
}
