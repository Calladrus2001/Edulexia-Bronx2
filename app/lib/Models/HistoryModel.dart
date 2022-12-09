// To parse this JSON data, do
//
//     final historyModel = historyModelFromJson(jsonString);

import 'dart:convert';

HistoryModel historyModelFromJson(String str) =>
    HistoryModel.fromJson(json.decode(str));

String historyModelToJson(HistoryModel data) => json.encode(data.toJson());

class HistoryModel {
  HistoryModel({
    this.history,
  });

  List<History>? history;

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        history:
            List<History>.from(json["History"].map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "History": List<dynamic>.from(history!.map((x) => x.toJson())),
      };
}

class History {
  History({
    this.message,
    this.type,
    this.time,
    this.cost,
    this.id,
  });

  String? message;
  String? type;
  String? time;
  int? cost;
  String? id;

  factory History.fromJson(Map<String, dynamic> json) => History(
        message: json["message"],
        type: json["type"],
        time: json["time"],
        cost: json["cost"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "type": type,
        "time": time,
        "cost": cost,
        "_id": id,
      };
}
