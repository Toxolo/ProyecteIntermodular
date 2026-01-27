import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_mapper.dart';

class VideoService {
  static const String baseUrl = 'http://10.0.2.2:8090/Cataleg';
  // static const String baseUrl = 'http://localhost:8090/Category';

  static Future<List<Video>> getVideos() async {
    final response = await http.get(Uri.parse(baseUrl)); // llamada al endpoint

    if (response.statusCode == 200) { // preparamos la lista de videos
      final List data = json.decode(response.body);
      return data.map((e) => Video.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar videos'); // mensaje de error en caso de qu no carguen los videos
    }
  }

  static Future<Video> getVideoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Video.fromJson(json.decode(response.body)); // devuelve el video por id
    } else {
      throw Exception('Error al cargar video $id');// mensaje de error en caso de qu no cargue el video/id
    }
  }
  
  

}
