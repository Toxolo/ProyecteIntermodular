// import 'package:flutter/material.dart';
// import 'package:client/data/local/app_database.dart';
// import '../../models/video_mapper.dart';
// import '../../models/serie_mapper.dart';
// import '../../services/video_service.dart';
// import '../pages/video_de_serie_page.dart';

// class SeriesSection extends StatelessWidget {
//   final AppDatabase db;

//   const SeriesSection({super.key, required this.db});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Video>>(
//       future: VideoService.getVideos(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.white),
//           );
//         }

//         final videos = snapshot.data!;
//         final Map<int, List<Video>> seriesMap = {};
//         for (var v in videos) {
//           seriesMap.putIfAbsent(v.series, () => []).add(v);
//         }

//         final seriesList = seriesMap.entries
//             .map((e) => Serie.fromVideos(e.value))
//             .toList();

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: seriesList.length,
//           itemBuilder: (context, index) {
//             final s = seriesList[index];
//             return InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => VideosDeSeriePage(
//                       db: db,
//                       series: s.id,
//                       videos: seriesMap[s.id]!,
//                     ),
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.grey[900],
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 120,
//                         height: 70,
//                         child: s.thumbnail.isNotEmpty
//                             ? Image.network(
//                                 'http://10.0.2.2:3000/static/${s.thumbnail}/thumbnail.jpg',
//                                 fit: BoxFit.cover,
//                               )
//                             : Container(
//                                 color: Colors.white12,
//                                 child: const Icon(Icons.videocam, color: Colors.white),
//                               ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           s.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
