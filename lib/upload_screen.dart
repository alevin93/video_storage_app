import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:async';
import 'dart:io';
import 'database_helper.dart'; // Import your database helper class
import 'video_model.dart';
import 'encryption_service.dart';
import 'encryption_contract.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();
  List<String> _tags = [];
  String _fileName = 'No file selected';
  File? _file;
  late final IEncryption _encryption;

  Future<void> _saveVideoToDatabase(
      String videoPath, String thumbnailPath) async {
    final video = Video(
      id: DateTime.now().millisecondsSinceEpoch,
      path: videoPath,
      name: _nameController.text,
      thumbnailPath: thumbnailPath,
      tags: _tags,
    );

    final database = await DatabaseHelper.instance.database;
    await database.insert(
      DatabaseHelper.table,
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Create a directory for the videos if it doesn't exist
    final directory = await getExternalStorageDirectory();
    final videosDirectory = Directory('${directory!.path}/../../../../Documents/Private');
    if (!videosDirectory.existsSync()) {
      videosDirectory.createSync();
    }

    print("Video Directory is:  " + videosDirectory.toString());

    // Get the file name from the video path
    final fileName = videoPath.split('/').last;

    // Create a new file in the videos directory
    final videoFile = File('${videosDirectory.path}/$fileName');

    // Copy the video file to the new location
    await File(videoPath).copy(videoFile.path);

    // Clear the fields and navigate back
    _tags.clear();
    _fileName = 'No file selected';
    _file = null;
    _nameController.clear();

    Navigator.pop(context); // Go back to the previous screen
  }

  Future<void> _selectVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _file = File(result.files.single.path!);
      _fileName = _file!.path.split('/').last;
      print(_fileName);
    } else {
      print("No file selected");
    }
    setState(() {
      _nameController.text = _fileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Upload'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            OutlinedButton(
              onPressed: _selectVideo,
              child: Text(_fileName),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Video Name',
              ),
              onTap: () {
                _nameController.clear();
              },
            ),
            SizedBox(height: 15),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags',
              ),
              onSubmitted: (value) {
                _tags.add(value.toLowerCase());
                _tagsController.clear();
                setState(() {});
              },
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue,
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                print('Upload button pressed');
                if (_file != null) {
                  final appDir = await getApplicationDocumentsDirectory();
                  final targetPath =
                      '${appDir.path}/${_file!.path.split('/').last}';
                  await _file!.copy(targetPath);

                  // Generate and save the video thumbnail
                  final thumbnailPath = await generateThumbnail(_file!.path);

                  // Save the video and thumbnail data to the database
                  await _saveVideoToDatabase(targetPath, thumbnailPath);
                }
              },
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> generateThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 300,
      quality: 100,
      timeMs: 20000,
    );

    return thumbnailPath.toString();
  }
}
