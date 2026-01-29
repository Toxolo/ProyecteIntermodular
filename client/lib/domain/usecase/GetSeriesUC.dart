import 'package:client/domain/entities/Serie.dart';
import 'package:client/domain/repository/CatalegRepository.dart';

class GetSeriesUC {
  late final CatalegRepository repo;

  GetSeriesUC(this.repo);

  Future<List<Serie>> execute() async {
    return await repo.getSeries();
  }
}
