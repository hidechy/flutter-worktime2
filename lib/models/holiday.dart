// To parse this JSON data, do
//
//     final holiday = holidayFromJson(jsonString);

import 'dart:convert';

Holiday holidayFromJson(String str) => Holiday.fromJson(json.decode(str));

String holidayToJson(Holiday data) => json.encode(data.toJson());

class Holiday {
  Holiday({
    required this.data,
  });

  List<DateTime> data;

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
    data: List<DateTime>.from(json["data"].map((x) => DateTime.parse(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
  };
}
