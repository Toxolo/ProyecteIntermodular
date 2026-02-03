import 'package:client/domain/entities/Categoria.dart';
import 'package:client/domain/repository/CatalegRepository.dart';

class GetCategoriesUC {
  late final CatalegRepository repo;

  GetCategoriesUC(this.repo);

  Future<List<Categoria>> execute() async {
    return await repo.getCategories();
  }
}
