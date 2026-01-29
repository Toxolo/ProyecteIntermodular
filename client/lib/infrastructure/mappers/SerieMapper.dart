import 'package:client/domain/entities/Serie.dart';
import 'package:flutter/material.dart';

class SerieMapper {
  final int id;
  final String name;

  SerieMapper({required this.id, required this.name});

  static Serie fromJson(Map<String, dynamic> json) {
    try {
      return Serie(id: json["id"] ?? "", nom: json["name"] ?? "");
    } catch (error) {
      debugPrint("[Principal Mapper] Error:  $error");
      return Serie(id: -1, nom: "");
    }
  }
}
