// import 'package:client/models/video_mapper.dart';

// class Serie {
//   final int id;
//   final String name;
//   final String thumbnail; // thumbnail del primer capítol
//   final List<int> categorias; // categories del primer capítol

//   Serie({
//     required this.id,
//     required this.name,
//     required this.thumbnail,
//     required this.categorias,
//   });

//   @override
//   String toString() => 'Serie(id: $id, name: $name, thumbnail: $thumbnail, categorias: $categorias)';

//   /// Crea una sèrie a partir d'una llista de vídeos
//   factory Serie.fromVideos(List<Video> videos) {
//     final firstChapter = videos.firstWhere(
//       (v) => v.chapter == 1,
//       orElse: () => videos.first,
//     );

//     return Serie(
//       id: firstChapter.series,
//       name: 'Sèrie ${firstChapter.series}',
//       thumbnail: firstChapter.thumbnail,
//       categorias: firstChapter.categorias,
//     );
//   }

//   /// Crea una sèrie a partir del JSON del backend (només info bàsica)
//   factory Serie.fromJson(Map<String, dynamic> json) {
//     return Serie(
//       id: json['id'] as int,
//       name: json['name'] ?? 'Sèrie sense nom',
//       thumbnail: json['thumbnail'] ?? '',
//       categorias: [], // sense categories aquí, les agafarem del primer vídeo
//     );
//   }
// }
