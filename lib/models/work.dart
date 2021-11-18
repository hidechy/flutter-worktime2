// To parse this JSON data, do
//
//     final work = WorkFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

Work WorkFromJson(String str) => Work.fromJson(json.decode(str));

String WorkToJson(Work data) => json.encode(data.toJson());

class Work {
  Work({
    required this.data,
  });

  List<Datum> data;

  factory Work.fromJson(Map<String, dynamic> json) => Work(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.date,
    required this.workStart,
    required this.workEnd,
  });

  DateTime date;
  String workStart;
  String workEnd;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        date: DateTime.parse(json["date"]),
        workStart: json["work_start"],
        workEnd: json["work_end"],
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "work_start": workStart,
        "work_end": workEnd,
      };
}
