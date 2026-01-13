import 'video.dart';

extension VideoMapper on Video {
  static Video fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      rating: (json['rating'] as num).toDouble(),
      thumbnail: json['thumbnail'],
      seriesName: json['series']['name'],
      studyName: json['study']['name'],
    );
    }
}