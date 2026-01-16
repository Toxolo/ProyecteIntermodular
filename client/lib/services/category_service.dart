import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoryService {
  // URL para Android Emulator
  static const String categoryUrl = 'http://10.0.2.2:8090/Category';

  /// Devuelve la lista de categorías desde el backend
  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse(categoryUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((c) => Category.fromJson(c as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }
}

