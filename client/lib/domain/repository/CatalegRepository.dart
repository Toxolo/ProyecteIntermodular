import 'package:client/domain/entities/Categoria.dart';
import 'package:client/domain/entities/Serie.dart';
import 'package:client/domain/entities/Video.dart';

abstract class CatalegRepository {
  Future<List<Video>> getVideos();

  Future<List<Categoria>> getCategories();

  Future<List<Serie>> getSeries();
}
