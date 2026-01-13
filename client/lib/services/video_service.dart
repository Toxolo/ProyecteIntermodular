import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import '../models/video_mapper.dart';

class VideoService {
  static const String baseUrl = 'http://10.0.2.2:8090/Cataleg';

  static Future<List<Video>> getVideos() async {
    final response = await http.get(Uri.parse(baseUrl)); // llamada al endpoint

    if (response.statusCode == 200) { // preparamos la lista de videos
      final List data = json.decode(response.body);
      return data.map((e) => VideoMapper.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar videos'); // mensaje de error en caso de qu no carguen los videos
    }
  }

  static Future<Video> getVideoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return VideoMapper.fromJson(json.decode(response.body)); // devuelve el video por id
    } else {
      throw Exception('Error al cargar video $id');// mensaje de error en caso de qu no cargue el video/id
    }
  }
}
