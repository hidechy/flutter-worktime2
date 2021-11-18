// To parse this JSON data, do
//
//     final summary = SummaryFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

Summary SummaryFromJson(String str) => Summary.fromJson(json.decode(str));

String SummaryToJson(Summary data) => json.encode(data.toJson());

class Summary {
  Summary({
    required this.data,
  });

  List<String> data;

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        data: List<String>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}
