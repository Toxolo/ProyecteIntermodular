import 'package:client/domain/entities/Categoria.dart';
import 'package:client/domain/entities/Serie.dart';
import 'package:client/domain/entities/Video.dart';
import 'package:client/domain/repository/CatalegRepository.dart';
import 'package:client/infrastructure/data_sources/api/ApiService.dart';
import 'package:client/infrastructure/mappers/CategoriaMapper.dart';
import 'package:client/infrastructure/mappers/SerieMapper.dart';
import 'package:client/infrastructure/mappers/VideoMapper.dart';

class CatalegRepositoryImpl implements CatalegRepository {
  final ApiService apiService;

  CatalegRepositoryImpl({required this.apiService});

  @override
  Future<List<Categoria>> getCategories() async {
    return (await apiService.getCategories()).map((cat) {
      return CategoriaMapper.fromJson(cat);
    }).toList();
  }

  @override
  Future<List<Serie>> getSeries() async {
    return (await apiService.getSeries()).map((ser) {
      return SerieMapper.fromJson(ser);
    }).toList();
  }

  @override
  Future<List<Video>> getVideos() async {
    return (await apiService.getVideos()).map((vid) {
      return VideoMapper.fromJson(vid);
    }).toList();
  }
}
