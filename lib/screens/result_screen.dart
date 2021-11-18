import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../utility/utility.dart';

import 'dart:convert';
import 'package:http/http.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Utility _utility = Utility();

  final List<Map<dynamic, dynamic>> _resultData = [];

  final ItemScrollController _itemScrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  int maxNo = 0;

  final List<Map<dynamic, dynamic>> _yearList = [];

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    ////////////////////////////////////////
    Map data = {};

    String url = "http://toyohide.work/BrainLog/api/worktimesummary";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({"date": ''});
    Response response =
        await post(Uri.parse(url), headers: headers, body: body);

    data = jsonDecode(response.body);

    var _inputedYear = "";
    for (var i = 0; i < data['data'].length; i++) {
      var exData = (data['data'][i]).split(';');

      List _list = [];
      var dailyData = (exData[6]).split('/');
      for (var j = 0; j < dailyData.length; j++) {
        _list.add(dailyData[j]);
      }

      Map _map = {};
      _map['ym'] = exData[0];
      _map['summary'] = exData[1];
      _map['company'] = exData[2];
      _map['genba'] = exData[3];
      _map['salary'] = exData[4];
      _map['hour'] = exData[5];
      _map['daily'] = _list;

      _resultData.add(_map);

      //
      var exYm = (exData[0]).split('-');
      if (_inputedYear != exYm[0]) {
        Map _map2 = {};
        _map2['year'] = exYm[0];
        _map2['index'] = i;
        _yearList.add(_map2);
      }
      _inputedYear = exYm[0];
    }
    ////////////////////////////////////////
    maxNo = _resultData.length;

    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('勤務時間'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_downward),
          color: Colors.greenAccent,
          onPressed: () => _scroll(pos: maxNo),
        ),
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
              Wrap(
                children: _makeYearBtn(),
              ),
              Expanded(
                child: _resultList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  void _scroll({pos}) {
    _itemScrollController.scrollTo(
      index: pos,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutCubic,
    );
  }

  ///
  Widget _resultList() {
    return ScrollablePositionedList.builder(
      itemBuilder: (context, index) {
        return _listItem(position: index);
      },
      itemCount: _resultData.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
    );
  }

  /// リストアイテム表示
  Widget _listItem({required int position}) {
    var _workDayCount = _getWorkDayCount(position: position);

    return Card(
      color: Colors.black.withOpacity(0.3),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 10),
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${_resultData[position]['ym']}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.greenAccent.withOpacity(0.7)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Table(
                          children: [
                            TableRow(children: [
                              Container(
                                child: Text('$_workDayCount'),
                                alignment: Alignment.topRight,
                              ),
                              Container(
                                child:
                                    Text('${_resultData[position]['summary']}'),
                                alignment: Alignment.topRight,
                              ),
                              (_resultData[position]['salary'] == "")
                                  ? Container()
                                  : Container(
                                      child: Text(_utility.makeCurrencyDisplay(
                                          _resultData[position]['salary'])),
                                      alignment: Alignment.topRight,
                                    ),
                              (_resultData[position]['hour'] == "")
                                  ? Container()
                                  : Container(
                                      child: Text(_utility.makeCurrencyDisplay(
                                          _resultData[position]['hour'])),
                                      alignment: Alignment.topRight,
                                    ),
                            ]),
                          ],
                        ),
                        Text('${_resultData[position]['company']}'),
                        Text('${_resultData[position]['genba']}'),
                      ],
                    ),
                  ),
                ],
              ),
              _dailyList(position: position),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget _dailyList({position}) {
    List<Widget> _list = [];

    for (var i = 0; i < _resultData[position]['daily'].length; i++) {
      var exData = (_resultData[position]['daily'][i]).split('|');
      _list.add(
        Container(
          decoration: BoxDecoration(color: _getBgColor(wday: exData[5])),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 60,
                child: Text('${exData[0]}'),
              ),
              Container(
                decoration: (exData[6] == '1')
                    ? BoxDecoration(color: Colors.yellowAccent.withOpacity(0.3))
                    : null,
                width: 60,
                child: Text('${exData[1]}'),
              ),
              SizedBox(
                width: 60,
                child: Text('${exData[2]}'),
              ),
              SizedBox(
                width: 50,
                child: Text('${exData[3]}'),
              ),
              Container(
                decoration: (exData[4] == '0')
                    ? BoxDecoration(color: Colors.yellowAccent.withOpacity(0.3))
                    : null,
                width: 70,
                child: Text('${exData[4]}'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _list,
      ),
    );
  }

  ///
  Color _getBgColor({wday}) {
    Color _color = Colors.black.withOpacity(0.3);

    switch (wday) {
      case '0':
        _color = Colors.redAccent[700]!.withOpacity(0.3);
        break;

      case '6':
        _color = Colors.blueAccent[700]!.withOpacity(0.3);
        break;

      default:
        _color = Colors.black.withOpacity(0.3);
        break;
    }

    return _color;
  }

  ///
  int _getWorkDayCount({required int position}) {
    var _workDayCount = 0;
    for (var i = 0; i < _resultData[position]['daily'].length; i++) {
      var exData = (_resultData[position]['daily'][i]).split('|');
      if (exData[1] != "") {
        _workDayCount++;
      }
    }

    return _workDayCount;
  }

  ///
  List<Widget> _makeYearBtn() {
    List<Widget> _btnList = [];
    for (var i = 1; i < _yearList.length; i++) {
      _btnList.add(
        GestureDetector(
          onTap: () => _scroll(pos: _yearList[i]['index']),
          child: Container(
            color: Colors.green[900]!.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('${_yearList[i]['year']}'),
          ),
        ),
      );
    }
    return _btnList;
  }
}
