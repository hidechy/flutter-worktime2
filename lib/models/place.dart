// To parse this JSON data, do
//
//     final place = PlaceFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

Place PlaceFromJson(String str) => Place.fromJson(json.decode(str));

String PlaceToJson(Place data) => json.encode(data.toJson());

class Place {
  Place({
    required this.data,
  });

  List<Datum> data;

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.yearmonth,
    required this.company,
    required this.genba,
  });

  String yearmonth;
  String company;
  String genba;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        yearmonth: json["yearmonth"],
        company: json["company"],
        genba: json["genba"],
      );

  Map<String, dynamic> toJson() => {
        "yearmonth": yearmonth,
        "company": company,
        "genba": genba,
      };
}
