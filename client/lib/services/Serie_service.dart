import 'dart:convert';
import 'package:client/models/serie_mapper.dart';
import 'package:client/models/video_mapper.dart';
import 'package:client/services/video_service.dart';
import 'package:http/http.dart' as http;

class SerieService {
  static const String serieUrl = 'http://10.0.2.2:8090/Serie';

  /// Obté totes les sèries
  static Future<List<Serie>> getCategories() async {
    final response = await http.get(Uri.parse(serieUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((c) => Serie.fromJson(c as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar series');
    }
  }

  /// Obté tots els vídeos d'una sèrie, ordenats per temporada i capítol
  static Future<List<Video>> getVideosBySeries(int seriesId) async {
    final videos = await VideoService.getVideos();
    final filtered = videos.where((v) => v.series == seriesId).toList();

    filtered.sort((a, b) {
      if (a.season != b.season) return a.season.compareTo(b.season);
      return a.chapter.compareTo(b.chapter);
    });

    return filtered;
  }

  /// Obté una sèrie pel seu ID
  static Future<Serie?> getSerieById(int serieId) async {
    final series = await getCategories();

    try {
      return series.firstWhere((s) => s.id == serieId);
    } catch (_) {
      return null;
    }
  }

}
