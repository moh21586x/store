import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/database.dart';
import 'package:store/items.dart';
import 'package:window_manager/window_manager.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

////////////////////////////////////////////////////////////
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
///////////////////////

class _HomePageState extends State<HomePage> {
  List<ModelDB> rows = [];

  deleteUnusedFiles() async {
    await DBHelper().queryAllImages().then((images) async {
      List<String?> dbImages = [];
      List<XFile> deviceImages = [];
      List<FileSystemEntity> folderContent =
          Directory("/storage/emulated/0/store").listSync();
      List<String> imgNo = [
        "img1",
        "img2",
        "img3",
        "img4",
        "img5",
        "img6",
        "img7",
        "img8",
        "img9",
        "img10"
      ];
      for (int i = 0; i < images.length; i++) {
        for (int img = 0; img < images[i].length; img++) {
          if (images[i][imgNo[img]] != null) {
            dbImages.add(images[i][imgNo[img]]);
          }
        }
      }
      for (int i = 0; i < folderContent.length; i++) {
        deviceImages.add(XFile(folderContent[i].path));
      }
      for (int i = 0; i < deviceImages.length; i++) {
        if (dbImages.contains(deviceImages[i].path)) {
        } else {
          File(deviceImages[i].path).deleteSync();
          print(deviceImages[i].path);
        }
      }
    });
  }

  getRows() async {
    var query = await DBHelper().queryAllRowsDisplay();
    setState(() {
      rows = query.map((row) {
        return ModelDB.fromQuery(row);
      }).toList();
    });
  }

  @override
  initState() {
    super.initState();
    Permission.storage.request().then((value) async {
      await Permission.manageExternalStorage.request();
      if (value == PermissionStatus.granted) {
        await Directory('/storage/emulated/0/store').create();
      }
      // await Permission.camera.request();
    });

    getRows();
    deleteUnusedFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // todo add search bar
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Search'),
                      content: TextFormField(
                        onChanged: (search) async {
                          if (search.isNotEmpty) {
                            var result =
                                await DBHelper().queryFilteredRows(search);
                            setState(() {
                              rows = result.map((row) {
                                return ModelDB.fromQuery(row);
                              }).toList();
                            });
                          } else {
                            getRows();
                          }
                        },
                      ),
                    );
                  });
            },
          )
        ],
        title: const Text('Home'),
      ),
      drawer: sideMenu(context),
      body: SafeArea(
        child: (rows.isNotEmpty)
            ? ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemPage(
                                id: rows[index].id,
                              ),
                            ),
                          ).then((value) => setState(() {
                                getRows();
                              }));
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: Image.file(File(rows[index].img1!)),
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('name: ${rows[index].name}'),
                                    Text('place: ${rows[index].place}'),
                                    Text(
                                        'description: ${rows[index].description}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : const SizedBox(),
      ),
    );
  }

  Drawer sideMenu(BuildContext context) {
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
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 1),
                bottom: BorderSide(width: 1),
              ),
            ),
            child: ListTile(
              selectedColor: Colors.yellow,
              title: const Text('Create'),
              leading: const Icon(Icons.create),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ItemPage(),
                  ),
                ).then((value) => setState(() {
                      getRows();
                    }));
              },
              contentPadding: const EdgeInsets.all(5),
            ),
          ),
        ],
      ),
    );
  }
}

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
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
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 1),
                bottom: BorderSide(width: 1),
              ),
            ),
            child: ListTile(
              selectedColor: Colors.yellow,
              title: const Text('Create'),
              leading: const Icon(Icons.create),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ItemPage(),
                  ),
                ).then((value) => setState(() {}));
              },
              contentPadding: const EdgeInsets.all(5),
            ),
          ),
        ],
      ),
    );
  }
}
