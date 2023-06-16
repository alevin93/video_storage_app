import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'video_card.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'video_model.dart';
import 'upload_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'video_player_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Video>> _getVideosFromDatabase() async {
    final database = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps =
        await database.query(DatabaseHelper.table);
    return List.generate(maps.length, (index) {
      return Video.fromMap(maps[index]);
    });
  }

  void _deleteVideo(int videoId) async {
    // Perform delete operation here
    await _databaseHelper.delete(videoId);
    setState(() {}); // Refresh the UI after deletion
  }

  void _showDeleteConfirmation(BuildContext context, Video video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Video'),
          content: Text('Are you sure you want to delete this video?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVideo(video.id);
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SpankBank'),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadScreen()),
                  )
                      .then((_) => setState(() {}))
                      .then((_) => Navigator.pop(this.context));
                },
                child: Text(
                  'Upload',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Center(
                child: Text(
                  'Search',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            ),
            ListTile(
              title: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Video>>(
        future: _getVideosFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final videos = snapshot.data!;
            return OrientationBuilder(
              builder: (context, orientation) {
                final crossAxisCount =
                    orientation == Orientation.portrait ? 2 : 3;
                return StaggeredGridView.countBuilder(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: crossAxisCount,
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
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Center(
                                        child: Text('Delete',
                                            style: TextStyle(fontSize: 18))),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _showDeleteConfirmation(context, video);
                                    },
                                  ),
                                  ListTile(
                                    title: Center(
                                        child: Text('Show File Path',
                                            style: TextStyle(fontSize: 18))),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _showFilePath(context, video);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: VideoCard(video: video),
                    );
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                );
              },
            );
          } else {
            return Center(child: Text('No videos found'));
          }
        },
      ),
    );
  }
}

void _showFilePath(BuildContext context, Video video) {
  print("File Path is:  " + video.path);
}
