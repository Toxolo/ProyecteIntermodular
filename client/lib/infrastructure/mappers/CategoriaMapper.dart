import 'package:client/domain/entities/Categoria.dart';
import 'package:flutter/material.dart';

class CategoriaMapper {
  final int id;
  final String name;

  CategoriaMapper({required this.id, required this.name});

  static Categoria fromJson(Map<String, dynamic> json) {
    try {
      return Categoria(id: json["id"] ?? "", nom: json["name"] ?? "");
    } catch (error) {
      debugPrint("[Principal Mapper] Error:  $error");
      return Categoria(id: -1, nom: "");
    }
  }
}
