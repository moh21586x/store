import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/database.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //connect to database
  // db = await DBHelper().database;

  //manage screen size
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 600),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  //start the application
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  ImagePicker image = ImagePicker();

  testDB() async {
    //todo change the values to dynamics
    await DBHelper().insert(ModelDB(
        id: 0,
        name: 'test1',
        place: 'test1',
        description: 'test1',
        img1: 'img1',
        img2: 'img2',
        img3: 'img3',
        img4: 'img4',
        img5: 'img5',
        img6: 'img6',
        img7: 'img7',
        img8: 'img8',
        img9: 'img9',
        img10: 'img10'));
    print(await DBHelper().queryAllRows());
  }

  pickImages() async {
    //todo save picked images and display them
    var images = await image.pickMultiImage();
    if (images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        print(images[i].name);
      }
    }
  }

  saveImages() async {
    //todo save images to device
  }

  @override
  Widget build(BuildContext context) {
    // testDB();
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                pickImages();
              },
              child: Text('image picker')),
          ElevatedButton(
              onPressed: () {
                saveImages();
              },
              child: Text('image saver')),
          ElevatedButton(
              onPressed: () {
                testDB();
              },
              child: Text('db saver')),
        ],
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.blue,
            height: 100,
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 1),
                bottom: BorderSide(width: 1),
              ),
            ),
            child: ListTile(
              selectedColor: Colors.yellow,
              title: const Text('Home'),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  HomePage(),
                  ),
                );
              },
              contentPadding: const EdgeInsets.all(5),
            ),
          ),
        ],
      ),
    );
  }
}
