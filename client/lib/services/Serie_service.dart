// import 'dart:convert';
// import 'package:client/models/serie_mapper.dart';

// import 'package:http/http.dart' as http;


// class SerieService {
//   // URL para Android Emulator
//   static const String serieUrl = 'http://10.0.2.2:8090/Serie';
//   // static const String categoryUrl = 'http://localhost:8090/Serie';
//   /// Devuelve la lista de categorías desde el backend
//   static Future<List<Serie>> getCategories() async {
//     final response = await http.get(Uri.parse(serieUrl));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data
//           .map((c) => Serie.fromJson(c as Map<String, dynamic>))
//           .toList();
//     } else {
//       throw Exception('Error al cargar series');
//     }
//   }
// }

