import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/database.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //connect to database todo
  db = await DBHelper().database;

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
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ImagePicker image = ImagePicker();
  late List<XFile> images;

  // todo get permission for camera and storage
  getPermission(){

  }

  insertDB(ModelDB insert) async {
    await DBHelper().insert(insert);
    print(await DBHelper().queryAllRows());
  }

  pickImages() async {
    //todo pick and display images
    images = await image.pickMultiImage();
    if (images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        print(images[i].name);
      }
    }
  }

  saveImages() async {
    //todo create a folder and save picked images
    if (images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        images[i].saveTo('/data/user/0/com.example.store/image$i.jpg');
      }
    } else {
      //todo you have not picked any images
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Text('image picker')),
          ElevatedButton(
              onPressed: () {
                saveImages();
              },
              child: const Text('image saver')),
          ElevatedButton(
              onPressed: () {
                //todo make an update function
                insertDB(ModelDB(
                  name: 'name',
                  place: 'place',
                  description: 'description',
                   img1: (images.isNotEmpty)? images[0].name:null,
                   img2: (images.length>1)? images[1].name:null,
                   img3: (images.length>2)? images[2].name:null,
                   img4: (images.length>3)? images[3].name:null,
                   img5: (images.length>4)? images[4].name:null,
                   img6: (images.length>5)? images[5].name:null,
                   img7: (images.length>6)? images[6].name:null,
                   img8: (images.length>7)? images[7].name:null,
                   img9: (images.length>8)? images[8].name:null,
                   img10:(images.length>9)? images[9].name:null,
                ));
              },
              child: const Text('db saver')),
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
                    builder: (context) => const HomePage(),
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
