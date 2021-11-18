// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

import '../utility/utility.dart';

import 'dart:convert';
import 'package:http/http.dart';

class EstimateScreen extends StatefulWidget {
  final List workday;

  EstimateScreen({Key? key, required this.workday}) : super(key: key);

  @override
  _EstimateScreenState createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> {
  final Utility _utility = Utility();

  String _displayYear = '';
  String _displayMonth = '';
  String _displayDay = '';

  String monthEndDay = '';

  final List<Map<dynamic, dynamic>> _monthData = [];

  double _monthWorkingTotal = 0.0;

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    _utility.makeYMDYData(widget.workday[0], 0);

    _displayYear = _utility.year;
    _displayMonth = _utility.month;
    _displayDay = _utility.day;

    ////////////////////////////////////////
    Map data = {};

    String url = "http://toyohide.work/BrainLog/api/worktimemonthdata";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json
        .encode({"date": '${_utility.year}-${_utility.month}-${_utility.day}'});
    Response response =
        await post(Uri.parse(url), headers: headers, body: body);

    data = jsonDecode(response.body);
    ////////////////////////////////////////
    _utility.makeMonthEnd(
        int.parse(_displayYear), int.parse(_displayMonth) + 1, 0);

    _utility.makeYMDYData(_utility.monthEndDateTime, 0);
    monthEndDay = _utility.day;

    for (var i = 1; i <= int.parse(monthEndDay); i++) {
      Map _map = {};

      var _dt = DateTime(int.parse(_displayYear), int.parse(_displayMonth), i);
      _map['fake'] = ((DateTime.now()).difference(_dt).inMinutes < 0) ? 1 : 0;

      var _date = _dt.toString();

      var exDate = (_date).split(' ');
      _map['date'] = exDate[0];

      _map['diff'] = (widget.workday.contains(exDate[0])) ? "8.0" : "0.0";

      if (data['data'].length > 0) {
        if (data['data'][exDate[0]] != null) {
          //-------------------------------//
          var exStart = data['data'][exDate[0]]['work_start'].split(":");
          var exEnd = data['data'][exDate[0]]['work_end'].split(":");

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
            end: data['data'][exDate[0]]['work_end'],
            year: _displayYear,
            month: _displayMonth,
            day: _displayDay,
          );

          var onedayDiff = ((diffMinutes - _minusMinutes) / 60);
          _map['diff'] = "$onedayDiff";
          //-------------------------------//

        }
      }

      _monthData.add(_map);
    }

    for (var i = 0; i < _monthData.length; i++) {
      _monthWorkingTotal += double.parse(_monthData[i]['diff']);
    }

    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    var _workDayNum = widget.workday.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('$_displayYear-$_displayMonth'),
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
            onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 20),
              _dispSummaryBox(_workDayNum),
              const SizedBox(height: 10),
              Expanded(
                child: _monthList(),
              ),
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

    return Container(
      color: _getBackGroundColor(data: _monthData[position]),
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${_monthData[position]['date']}（${_utility.youbiStr}）',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '${_monthData[position]['diff']}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  ///
  Container _dispSummaryBox(int _workDayNum) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Table(
        children: [
          TableRow(children: [
            Container(
              child: const Text('予定日数'),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Colors.green[900]!.withOpacity(0.5),
              ),
            ),
            Container(
              child: Text(
                '$_workDayNum',
                style: const TextStyle(fontSize: 20),
              ),
              alignment: Alignment.topCenter,
            ),
            Container(
              child: const Text('予定時間'),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Colors.green[900]!.withOpacity(0.5),
              ),
            ),
            Column(
              children: <Widget>[
                Text(
                  '$_monthWorkingTotal',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  ///
  Color _getBackGroundColor({data}) {
    Color _bgColor = const Color(0x002e2e2e).withOpacity(0.3);

    if (!widget.workday.contains(data['date'])) {
      _bgColor = Colors.grey.withOpacity(0.3);
    }

    if (data['fake'] == 0) {
      _bgColor = Colors.yellowAccent.withOpacity(0.3);
    }

    return _bgColor;
  }
}
