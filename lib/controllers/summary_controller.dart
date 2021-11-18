import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/summary.dart';

class SummaryController extends GetxController {
  List data = [].obs;

  RxBool loading = false.obs;

  loadData() async {
    loading(true);

    var url = "http://toyohide.work/BrainLog/api/worktimesummary";

    Map<String, String> headers = {'content-type': 'application/json'};

    var response = await http.post(Uri.parse(url), headers: headers);

    final summary = SummaryFromJson(response.body);
    data = summary.data;

    loading(false);
  }
}
