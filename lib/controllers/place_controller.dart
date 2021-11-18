import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/place.dart';

class PlaceController extends GetxController {
  List data = [].obs;

  RxBool loading = false.obs;

  loadData() async {
    loading(true);

    var url = "http://toyohide.work/BrainLog/api/workinggenbaname";

    Map<String, String> headers = {'content-type': 'application/json'};

    var response = await http.post(Uri.parse(url), headers: headers);

    final place = PlaceFromJson(response.body);
    data = place.data;

    loading(false);
  }
}
