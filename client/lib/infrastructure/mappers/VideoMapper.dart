import 'package:client/domain/entities/Video.dart';
import 'package:flutter/material.dart';

class VideoMapper {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String thumbnail;
  final List<int> categorias;
  final int chapter;
  final int season;
  final int series;
  final double puntuacio;

  VideoMapper({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnail,
    required this.categorias,
    required this.chapter,
    required this.season,
    required this.series,
    required this.puntuacio,
  });

  static Video fromJson(Map<String, dynamic> json) {
    try {
      return Video(
        id: json['id'] as int,
        titol: json['title'] ?? '',
        descripcio: json['description'] ?? '',
        duracio: json['duration'] ?? 0,
        categories: json['category'] != null
            ? List<int>.from(json['category'].map((e) => e['id'] as int))
            : [],
        capitol: json['chapter'] ?? 0,
        temporada: json['season'] ?? 0,
        serie: json['series'] != null ? json['series']['id'] as int : 0,
        puntuacio: json['rating'] ?? 0,
      );
    } catch (error) {
      debugPrint("[Principal Mapper] Error:  $error");
      return (Video(
        id: 0,

        titol: json['title'] ?? '',
        descripcio: json['description'] ?? '',
        duracio: json['duration'] ?? 0,

        categories: json['category'] != null
            ? List<int>.from(json['category'].map((e) => e['id'] as int))
            : [],

        capitol: json['chapter'] ?? 0,
        temporada: json['season'] ?? 0,

        serie: json['series'] != null ? json['series']['id'] as int : 0,
        puntuacio: json['rating'] ?? 0,
      ));
    }
  }
}
