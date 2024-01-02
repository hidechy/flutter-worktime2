// ignore_for_file: unused_field, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:http/http.dart';

import 'dart:convert';

import '../utility/utility.dart';

import 'estimate_screen.dart';
import 'list_screen.dart';
import 'result_screen.dart';
import 'worktime_input_screen.dart';

class MonthListScreen extends StatefulWidget {
  final String date;

  const MonthListScreen({Key? key, required this.date}) : super(key: key);

  @override
  _MonthListScreenState createState() => _MonthListScreenState();
}

class _MonthListScreenState extends State<MonthListScreen> {
  final Utility _utility = Utility();

  String _displayYear = '';
  String _displayMonth = '';
  String _displayDay = '';

  String monthEndDay = '';

  final List<Map<dynamic, dynamic>> _monthData = [];

  DateTime _prevMonth = DateTime.now();
  DateTime _nextMonth = DateTime.now();

  double _monthWorkingTotal = 0.0;

  String company = '';
  String genba = '';

  int _holidayNum = 0;

  final List _thisMonthWorkday = [];

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    _utility.makeYMDYData(widget.date, 0);

    _displayYear = _utility.year;
    _displayMonth = _utility.month;
    _displayDay = _utility.day;

    _prevMonth = DateTime(int.parse(_utility.year), int.parse(_utility.month) - 1, 1);

    _nextMonth = DateTime(int.parse(_utility.year), int.parse(_utility.month) + 1, 1);

    _utility.makeMonthEnd(int.parse(_displayYear), int.parse(_displayMonth) + 1, 0);

    _utility.makeYMDYData(_utility.monthEndDateTime, 0);
    monthEndDay = _utility.day;

    //#############################
    var _holiday;
    String url3 = "http://toyohide.work/BrainLog/api/getholiday";
    Map<String, String> headers3 = {'content-type': 'application/json'};
    String body3 = json.encode({"date": ''});
    Response response3 = await post(Uri.parse(url3), headers: headers3, body: body3);

    _holiday = jsonDecode(response3.body);
    //#############################

    //-------------------------------------------
    String url2 = "http://toyohide.work/BrainLog/api/workinggenbaname";
    Map<String, String> headers2 = {'content-type': 'application/json'};
    String body2 = json.encode({"date": ''});
    Response response2 = await post(Uri.parse(url2), headers: headers2, body: body2);

    var data2 = jsonDecode(response2.body);

    for (var i = 0; i < data2['data'].length; i++) {
      if (data2['data'][i]['yearmonth'] == "$_displayYear-$_displayMonth") {
        company = data2['data'][i]['company'];
        genba = data2['data'][i]['genba'];
      }
    }
    //-------------------------------------------

    ////////////////////////////////////////
    Map data = {};

    String url = "http://toyohide.work/BrainLog/api/worktimemonthdata";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({"date": '${_utility.year}-${_utility.month}-${_utility.day}'});
    Response response = await post(Uri.parse(url), headers: headers, body: body);

    data = jsonDecode(response.body);
    ////////////////////////////////////////
    for (var i = 1; i <= int.parse(monthEndDay); i++) {
      var date = _displayYear + "-" + _displayMonth.padLeft(2, '0') + "-" + i.toString().padLeft(2, '0');

      Map _map = {};
      _map['date'] = date;
      _map['holiday'] = _getHoliday(date: date, holiday: _holiday);

      _map['work_start'] = "";
      _map['work_end'] = "";
      _map['diff'] = "";

      _map['minus'] = "";

      if (data['data'].length > 0) {
        if (data['data'][date] != null) {
          _map['work_start'] = data['data'][date]['work_start'];
          _map['work_end'] = data['data'][date]['work_end'];

          //-------------------------------//
          var exStart = data['data'][date]['work_start'].split(":");
          var exEnd = data['data'][date]['work_end'].split(":");

          var _startTime = DateTime(
            int.parse(_displayYear),
            int.parse(_displayMonth),
            int.parse(_displayDay),
            int.parse(exStart[0]),
            int.parse(exStart[1]),
          );

          var _endTime = DateTime(
            int.parse(_displayYear),
            int.parse(_displayMonth),
            int.parse(_displayDay),
            int.parse(exEnd[0]),
            int.parse(exEnd[1]),
          );

          int diffMinutes = _endTime.difference(_startTime).inMinutes;

          var _minusMinutes = _utility.getMinusMinutes(
            end: data['data'][date]['work_end'],
            year: _displayYear,
            month: _displayMonth,
            day: _displayDay,
          );
          _map['minus'] = "${_minusMinutes}min";

          var onedayDiff = ((diffMinutes - _minusMinutes) / 60);
          _map['diff'] = "${onedayDiff}hrs";

          _monthWorkingTotal += onedayDiff;
          //-------------------------------//
        }
      }

      _monthData.add(_map);
    }

    //----------------------//
    for (var i = 0; i < _monthData.length; i++) {
      if (_getHolidayFlag(position: i) == 1) {
        _holidayNum++;
      }
    }
    //----------------------//

    setState(() {});
  }

  ///
  int _getHoliday({required String date, holiday}) {
    var _flag = 0;
    for (var i = 0; i < holiday['data'].length; i++) {
      if (holiday['data'][i] == date) {
        _flag = 1;
        break;
      }
    }

    return _flag;
  }

  ///
  @override
  Widget build(BuildContext context) {
    var _workday = _thisMonthWorkday.toSet().toList();
    var _workDayNum = _workday.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        title: Text('$_displayYear-$_displayMonth'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.skip_previous),
            tooltip: '前月',
            onPressed: () => _goPrevMonth(context: context),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: '翌月',
            onPressed: () => _goNextMonth(context: context),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _utility.getBackGround(),
          Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.yellowAccent.withOpacity(0.3), width: 10),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 3),
                              ),
                            ),
                            child: Text('$_workDayNum'),
                          ),
                          GestureDetector(
                            onTap: () => _goEstimateScreen(workday: _workday),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.green[900]!.withOpacity(0.5)),
                              child: const Text('estimate'),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () => _goResultScreen(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.green[900]!.withOpacity(0.5)),
                              child: const Text('result'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _goListScreen(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.green[900]!.withOpacity(0.5)),
                              child: const Text('list'),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topRight,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 3),
                                ),
                              ),
                              child: Text('$_monthWorkingTotal'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _goMonthListScreen(date: widget.date),
                            color: Colors.greenAccent,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: <Widget>[
                              const SizedBox(width: 80, child: Text('Company : ')),
                              Expanded(child: Text(company)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: <Widget>[
                              const SizedBox(width: 80, child: Text('Genba : ')),
                              Expanded(child: Text(genba)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: _monthList()),
            ],
          ),
        ],
      ),
    );
  }

  /// リスト表示
  Widget _monthList() {
    return ListView.builder(
      itemCount: _monthData.length,
      itemBuilder: (context, int position) => _listItem(position: position),
    );
  }

  /// リストアイテム表示
  Widget _listItem({required int position}) {
    _utility.makeYMDYData(_monthData[position]['date'], 0);

    return Slidable(
      child: Card(
        color: _utility.getBgColor(
          _monthData[position]['date'],
          _monthData[position]['work_start'],
          _monthData[position]['work_end'],
        ),
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: DefaultTextStyle(
            style: const TextStyle(fontSize: 12),
            child: Row(
              children: <Widget>[
                Text('${_monthData[position]['date']}（${_utility.youbiStr}）'),
                Expanded(
                  child: (_getHolidayFlag(position: position) == 1)
                      ? Container(
                          alignment: Alignment.topRight,
                          child: const Text('Holiday'),
                        )
                      : Table(
                          children: [
                            TableRow(children: [
                              Container(
                                alignment: Alignment.topCenter,
                                child: Text('${_monthData[position]['work_start']}'),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                child: Text('${_monthData[position]['work_end']}'),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                child: Text(
                                  '${_monthData[position]['minus']}',
                                  style: TextStyle(color: Colors.yellowAccent.withOpacity(0.5)),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                child: Text('${_monthData[position]['diff']}'),
                              ),
                            ]),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      endActionPane: ActionPane(motion: ScrollMotion(), children: _getInputButton(position)),
    );
  }

  ///
  List<Widget> _getInputButton(int position) {
    List<Widget> list = [];

    var _disp = _getHolidayFlag(position: position);

    if (_disp == 1) {
      list.add(
        SlidableAction(
          onPressed: (value) {},
          foregroundColor: Colors.black.withOpacity(0.1),
          backgroundColor: _utility.getBgColor(
            _monthData[position]['date'],
            _monthData[position]['work_start'],
            _monthData[position]['work_end'],
          ),
          icon: Icons.crop_square,
        ),
      );
    } else {
      list.add(
        SlidableAction(
          onPressed: (value) {
            _goWorktimeInputScreen(
                context: context,
                date: _monthData[position]['date'],
                start: _monthData[position]['work_start'],
                end: _monthData[position]['work_end']);
          },
          backgroundColor: _utility.getBgColor(
            _monthData[position]['date'],
            _monthData[position]['work_start'],
            _monthData[position]['work_end'],
          ),
          foregroundColor: Colors.blueAccent,
          icon: Icons.details,
        ),
      );
    }

    return list;
  }

  ///
  int _getHolidayFlag({position}) {
    _utility.makeYMDYData(_monthData[position]['date'], 0);

    var _disp = 0;
    switch (_utility.youbiNo) {
      case 0:
      case 6:
        _disp = 1;
        break;
      default:
        _disp = 0;
        break;
    }

    if (_disp == 0) {
      if (_monthData[position]['holiday'] == 1) {
        _disp = 1;
      }
    }

    if (_disp == 0) {
      _thisMonthWorkday.add(_monthData[position]['date']);
    }

    return _disp;
  }

  ///////////////////////////////////////

  ///
  void _goPrevMonth({required BuildContext context}) {
    _goMonthListScreen(date: '$_prevMonth');
  }

  ///
  void _goNextMonth({required BuildContext context}) {
    _goMonthListScreen(date: '$_nextMonth');
  }

  ///
  void _goMonthListScreen({required String date}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MonthListScreen(date: date)),
    );
  }

  ///
  void _goWorktimeInputScreen(
      {required BuildContext context, required String date, required String start, required String end}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (context) => WorktimeInputScreen(date: date, start: start, end: end)),
    );

    if (result!) {
      _goMonthListScreen(date: date);
    }
  }

  ///
  void _goEstimateScreen({workday}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EstimateScreen(workday: workday)),
    );
  }

  ///
  void _goResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultScreen()),
    );
  }

  ///
  void _goListScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListScreen()),
    );
  }
}
