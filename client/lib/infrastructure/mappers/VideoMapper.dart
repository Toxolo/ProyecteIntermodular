import 'package:client/domain/entities/Video.dart';
import 'package:flutter/material.dart';

class VideoMapper {
  final int id;
  final String title;
  final String description;
  final int duration;
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
    required this.categorias,
    required this.chapter,
    required this.season,
    required this.series,
    required this.puntuacio,
  });

  static Video fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      debugPrint('[VideoMapper] fromJson: null json → empty video');
      return Video(
        id: 0,
        titol: '',
        descripcio: '',
        duracio: 0,
        categories: const [],
        capitol: 0,
        temporada: 0,
        serie: 0,
        puntuacio: 0,
      );
    }

    return Video(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titol: json['title'] as String? ?? '',
      descripcio: json['description'] as String? ?? '',
      duracio: (json['duration'] as num?)?.toInt() ?? 0,
      categories:
          (json['category'] as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>?)?['id'] as int? ?? 0)
              .where((id) => id != 0)
              .toList() ??
          [],
      capitol: (json['chapter'] as num?)?.toInt() ?? 0,
      temporada: (json['season'] as num?)?.toInt() ?? 0,
      serie: (json['series'] as Map<String, dynamic>?)?['id'] as int? ?? 0,
      puntuacio: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
