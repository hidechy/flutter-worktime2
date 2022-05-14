// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/work_time_list_view_model.dart';

import '../utility/utility.dart';

class ListScreen extends ConsumerWidget {
  ListScreen({Key? key}) : super(key: key);

  final Utility _utility = Utility();

  late WidgetRef _ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _ref = ref;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _utility.getBackGround(),
          Column(
            children: [
              Expanded(
                child: _workTimeList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  Widget _workTimeList() {
    final workTimeListState = _ref.watch(workTimeListProvider);

    return ListView.separated(
      itemBuilder: (context, position) => _listItem(position: position),
      separatorBuilder: (context, position) => Container(),
      itemCount: workTimeListState.length,
    );
  }

  ///
  Widget _listItem({required int position}) {
    final workTimeListState = _ref.watch(workTimeListProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 3,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(workTimeListState[position].ym),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workTimeListState[position].company),
                    Text(workTimeListState[position].genba),
                    Row(
                      children: [
                        Expanded(
                          child: Text(workTimeListState[position].summary),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Text(
                              (workTimeListState[position].salary == '')
                                  ? ''
                                  : _utility.makeCurrencyDisplay(
                                      workTimeListState[position].salary),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Text(
                              (workTimeListState[position].hour == '')
                                  ? ''
                                  : _utility.makeCurrencyDisplay(
                                      workTimeListState[position].hour),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
