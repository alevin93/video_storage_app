import 'dart:convert';

class Video {
  final int id;
  final String path;
  final String name;
  final String thumbnailPath;
  final List<String> tags;

  Video({
    required this.id,
    required this.path,
    required this.name,
    required this.thumbnailPath,
    required this.tags,
  });

  // Convert a Video object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'thumbnailPath': thumbnailPath,
      'tags': jsonEncode(tags),
    };
  }

  // Create a Video object from a Map.
  static Video fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'],
      path: map['path'],
      name: map['name'],
      thumbnailPath: map['thumbnailPath'],
      tags: List<String>.from(jsonDecode(map['tags'])),
    );
  }
}
