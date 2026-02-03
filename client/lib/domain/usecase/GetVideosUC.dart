import 'package:client/domain/entities/Video.dart';
import 'package:client/domain/repository/CatalegRepository.dart';

class GetVideosUC {
  late final CatalegRepository repo;

  GetVideosUC(this.repo);

  Future<List<Video>> execute() async {
    return await repo.getVideos();
  }
}
