import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/holiday.dart';

class HolidayController extends GetxController {
  List data = [].obs;

  RxBool loading = false.obs;

  loadData() async {
    loading(true);

    var url = "http://toyohide.work/BrainLog/api/getholiday";

    Map<String, String> headers = {'content-type': 'application/json'};

    var response = await http.post(Uri.parse(url), headers: headers);

    final holiday = holidayFromJson(response.body);
    data = holiday.data;

    loading(false);
  }
}
