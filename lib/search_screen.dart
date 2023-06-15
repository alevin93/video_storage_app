import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'video_card.dart';
import 'video_model.dart';
import 'database_helper.dart';
import 'video_player_screen.dart';
import 'package:easy_debounce/easy_debounce.dart';

//TO DO:
// stop the search from refreshing after every character

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Video>> _searchResults;

  DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _searchResults = _searchVideos('');
  }

  Future<List<Video>> _searchVideos(String query) async {
    // Modify this method based on how you perform the search in your database
    // Replace the database search logic with your own implementation

    List<Map<String, dynamic>> videoList = await dbHelper.queryAllRows();

    //convert videoList into something the next part of the function wants
    final List<Video> allVideos = videoList.map((videoMap) {
      return Video(
        id: videoMap['id'],
        path: videoMap['path'],
        name: videoMap['name'],
        thumbnailPath: videoMap['thumbnailPath'],
        tags: videoMap['tags'].split(','),
      );
    }).toList();

    // Filter videos based on the query
    final List<Video> searchResults = allVideos
        .where((video) =>
            video.name.toLowerCase().contains(query.toLowerCase()) ||
            video.tags
                .any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
        .toList();

    return searchResults;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchResults = _searchVideos(query);
            });
          },
          decoration: InputDecoration(
            hintText: 'Search...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          ),
        ),
      ),
      body: FutureBuilder<List<Video>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final videos = snapshot.data!;
            return StaggeredGridView.countBuilder(
              crossAxisCount: 2,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(videoUrl: video.path),
                      ),
                    );
                  },
                  child: VideoCard(video: video),
                );
              },
              staggeredTileBuilder: (index) => StaggeredTile.fit(1),
            );
          } else {
            return Center(child: Text('No videos found'));
          }
        },
      ),
    );
  }
}
