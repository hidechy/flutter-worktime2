// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:convert';

import '../utility/utility.dart';

class WorktimeInputScreen extends StatefulWidget {
  final String date;
  final String start;
  final String end;

  WorktimeInputScreen(
      {Key? key, required this.date, required this.start, required this.end})
      : super(key: key);

  @override
  _WorktimeInputScreenState createState() => _WorktimeInputScreenState();
}

class _WorktimeInputScreenState extends State<WorktimeInputScreen> {
  final Utility _utility = Utility();

  String _dialogSelectedStartTime = '';
  String _dialogSelectedEndTime = '';

  DateTime _prevDate = DateTime.now();
  DateTime _nextDate = DateTime.now();

  String _prevStart = "";
  String _prevEnd = "";

  String _nextStart = "";
  String _nextEnd = "";

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    if (widget.start != '') {
      _dialogSelectedStartTime =
          '${widget.start.split(":")[0]}:${widget.start.split(":")[1]}';
    }
    if (widget.end != '') {
      _dialogSelectedEndTime =
          '${widget.end.split(":")[0]}:${widget.end.split(":")[1]}';
    }

    _utility.makeYMDYData(widget.date, 0);
    _prevDate = DateTime(int.parse(_utility.year), int.parse(_utility.month),
        int.parse(_utility.day) - 1);
    _nextDate = DateTime(int.parse(_utility.year), int.parse(_utility.month),
        int.parse(_utility.day) + 1);

    ////////////////////////////////////////
    Map data = {};

    String url = "http://toyohide.work/BrainLog/api/worktimemonthdata";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({"date": widget.date});
    Response response =
        await post(Uri.parse(url), headers: headers, body: body);

    data = jsonDecode(response.body);

    if (data['data'].length > 0) {
      //prev
      _utility.makeYMDYData(_prevDate.toString(), 0);
      var _date = '${_utility.year}-${_utility.month}-${_utility.day}';
      if (data['data'][_date] != null) {
        _prevStart = data['data'][_date]['work_start'];
        _prevEnd = data['data'][_date]['work_end'];
      }

      //next
      _utility.makeYMDYData(_nextDate.toString(), 0);
      var _date2 = '${_utility.year}-${_utility.month}-${_utility.day}';
      if (data['data'][_date2] != null) {
        _nextStart = data['data'][_date2]['work_start'];
        _nextEnd = data['data'][_date2]['work_end'];
      }
    }
    ////////////////////////////////////////
    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        title: _getScreenTitle(),
        centerTitle: true,

        //-------------------------//これを消すと「←」が出てくる（消さない）
        leading: const Icon(
          Icons.check_box_outline_blank,
          color: Color(0xFF2e2e2e),
        ),
        //-------------------------//これを消すと「←」が出てくる（消さない）

        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, true),
            color: Colors.greenAccent,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _utility.getBackGround(),
          Column(
            children: <Widget>[
              const SizedBox(
                height: 80,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    tooltip: '前日',
                    onPressed: () => _goWorktimeInputScreen(
                      context: context,
                      date: _prevDate.toString(),
                      start: _prevStart,
                      end: _prevEnd,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    tooltip: '翌日',
                    onPressed: () => _goWorktimeInputScreen(
                      context: context,
                      date: _nextDate.toString(),
                      start: _nextStart,
                      end: _nextEnd,
                    ),
                  ),
                ],
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(20),
                color: Colors.black.withOpacity(0.3),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 80,
                            child: Text('Work Start'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: IconButton(
                              icon: const Icon(Icons.access_time),
                              tooltip: 'jump',
                              onPressed: () =>
                                  _showStartTimePicker(context: context),
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(_dialogSelectedStartTime),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 80,
                            child: Text('Work End'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: IconButton(
                              icon: const Icon(Icons.access_time),
                              tooltip: 'jump',
                              onPressed: () =>
                                  _showEndTimePicker(context: context),
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(_dialogSelectedEndTime),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.greenAccent.withOpacity(0.3),
                          ),
                          child: const Icon(Icons.input),
                          onPressed: () => _uploadWorktimeData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  Widget _getScreenTitle() {
    _utility.makeYMDYData(widget.date, 0);
    var _date = '${_utility.year}-${_utility.month}-${_utility.day}';

    return Container(
      color: _utility.getBgColor(
        _date,
        _dialogSelectedStartTime,
        _dialogSelectedEndTime,
      ),
      child: Text('$_date（${_utility.youbiStr}）'),
    );
  }

  ///
  void _showStartTimePicker({required BuildContext context}) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: (widget.start != '')
          ? TimeOfDay(
              hour: int.parse(widget.start.split(":")[0]),
              minute: int.parse(widget.start.split(":")[1]),
            )
          : TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
    );

    if (selectedTime != null) {
      _dialogSelectedStartTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  ///
  void _showEndTimePicker({required BuildContext context}) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: (widget.end != '')
          ? TimeOfDay(
              hour: int.parse(widget.end.split(":")[0]),
              minute: int.parse(widget.end.split(":")[1]),
            )
          : TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
    );

    if (selectedTime != null) {
      _dialogSelectedEndTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  ///
  void _uploadWorktimeData() async {
    _utility.makeYMDYData(widget.date, 0);

    Map<String, dynamic> _uploadData = {};
    _uploadData['date'] = '${_utility.year}-${_utility.month}-${_utility.day}';
    _uploadData['work_start'] = _dialogSelectedStartTime;
    _uploadData['work_end'] = _dialogSelectedEndTime;

    String url = "http://toyohide.work/BrainLog/api/worktimeinsert";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode(_uploadData);
    await post(Uri.parse(url), headers: headers, body: body);

    Fluttertoast.showToast(
      msg: "登録が完了しました",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  //////////////////////////////////////////////

  ///
  void _goWorktimeInputScreen(
      {required BuildContext context,
      required String date,
      required String start,
      required String end}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorktimeInputScreen(
          date: date,
          start: start,
          end: end,
        ),
      ),
    );
  }
}
