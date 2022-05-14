import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/work_time_list_state.dart';

import 'dart:convert';

import 'package:http/http.dart';

//////////////////////////////////////////////////////////////////////

final workTimeListProvider = StateNotifierProvider.autoDispose<
    WorkTimeListStateNotifier, List<WorkTimeListState>>((ref) {
  return WorkTimeListStateNotifier([])..getWorkTimeListData();
});

class WorkTimeListStateNotifier extends StateNotifier<List<WorkTimeListState>> {
  WorkTimeListStateNotifier(List<WorkTimeListState> state) : super(state);

  ///
  void getWorkTimeListData() async {
    String url = "http://toyohide.work/BrainLog/api/worktimesummary";
    Map<String, String> headers = {'content-type': 'application/json'};
    Response response = await post(Uri.parse(url), headers: headers);

    var data = jsonDecode(response.body);
    List<WorkTimeListState> _list = [];
    for (var i = 0; i < data['data'].length; i++) {
      var exData = (data['data'][i]).split(';');
      _list.add(
        WorkTimeListState(
          ym: exData[0],
          summary: exData[1],
          company: exData[2],
          genba: exData[3],
          salary: exData[4],
          hour: exData[5],
          daily: exData[6],
        ),
      );
    }

    state = _list;
  }
}

//////////////////////////////////////////////////////////////////////
