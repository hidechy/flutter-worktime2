import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../models/work.dart';

class WorkController extends GetxController {
  List data = [].obs;

  RxBool loading = false.obs;

  loadData({required String date}) async {
    loading(true);

    var url = "http://toyohide.work/BrainLog/api/workingmonthdata";

    Map<String, String> headers = {'content-type': 'application/json'};

    String body = json.encode({"date": date});

    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    final work = WorkFromJson(response.body);
    data = work.data;

    loading(false);
  }
}
