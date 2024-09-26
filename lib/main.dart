import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:store/database.dart';
import 'package:store/items.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path_pac;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = await DBHelper().database;

  //start the application
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split(Platform.pathSeparator).last;
  }
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
  List<String?> dbImages = [];
  List<XFile> deviceImages = [];
  String directoryPath = "/storage/emulated/0/store";

  //todo create export function
  exportDB() async {
    String dbPath =
        path_pac.join(await getDatabasesPath(), DBHelper.databaseName);
    XFile database = XFile(dbPath);
    database.saveTo(path_pac.join(directoryPath, DBHelper.databaseName));
    toast("database exported");
  }

  importDB() async {
    String dbPath =
        path_pac.join(await getDatabasesPath(), DBHelper.databaseName);
    XFile database = XFile(path_pac.join(directoryPath, DBHelper.databaseName));
    database.saveTo(dbPath);
    toast("database imported");
    getRows();
  }

  getUnusedImages() async {
    await DBHelper().queryAllImages().then((images) async {
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
        if (folderContent[i].name == DBHelper.databaseName) {
          continue;
        } else {
          deviceImages.add(XFile(folderContent[i].path));
        }
      }
      setState(() {
        deviceImages.removeWhere((element) => dbImages.contains(element.path));
      });
    });
  }

  deleteUnusedImages() {
    for (int i = 0; i < deviceImages.length; i++) {
      File(deviceImages[i].path).deleteSync();
    }

    setState(() {
      deviceImages = [];
      dbImages = [];
    });
    toast("Unused images deleted");
  }

  getRows() async {
    var query = await DBHelper().queryAllRowsDisplay();
    setState(() {
      rows = query.map((row) {
        return ModelDB.fromQuery(row);
      }).toList();
    });
  }

  toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        width: MediaQuery.of(context).size.width * .95,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // todo add search bar instead of a pop up
        actions: [SizedBox(width: MediaQuery.of(context).size.width*.65
          ,
          child: TextFormField(decoration: const InputDecoration(suffixIcon: Icon(Icons.search)),onChanged: (search) async {
            if (search.isNotEmpty) {
              var result =
              await DBHelper().queryFilteredRows(search);
              print(result);

              setState(() {
                rows = result.map((row) {
                  return ModelDB.fromQuery(row);
                }).toList();
              });
            } else {
              getRows();
            }
          },),
        ),
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {
          //     showDialog(
          //         context: context,
          //         builder: (context) {
          //           return AlertDialog(
          //             title: const Text('Search'),
          //             content: TextFormField(
          //               onChanged: (search) async {
          //                 if (search.isNotEmpty) {
          //                   var result =
          //                       await DBHelper().queryFilteredRows(search);
          //                   print(result);
          //
          //                   setState(() {
          //                     rows = result.map((row) {
          //                       return ModelDB.fromQuery(row);
          //                     }).toList();
          //                   });
          //                 } else {
          //                   getRows();
          //                 }
          //               },
          //             ),
          //           );
          //         });
          //   },
          // )
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.file(File(rows[index].img1!)),
                            const SizedBox(
                              width: 40,
                              height: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('item: ${rows[index].item}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('location: ${rows[index].location}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'description: ${rows[index].description}'),
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
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 1),
                bottom: BorderSide(width: 1),
              ),
            ),
            child: ListTile(
              selectedColor: Colors.yellow,
              title: const Text('Export database'),
              leading: const Icon(Icons.import_export),
              onTap: () {
                Navigator.pop(context);
                exportDB();
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
              title: const Text('Import database'),
              leading: const Icon(Icons.important_devices),
              onTap: () {
                Navigator.pop(context);
                importDB();
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
              title: const Text('Get/Delete unused images'),
              leading: const Icon(Icons.insert_drive_file_sharp),
              onTap: () async {
                getUnusedImages();
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          TextButton(
                              onPressed: () {
                                deleteUnusedImages();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text("Delete")),
                          TextButton(
                              onPressed: () {
                                deviceImages = [];
                                dbImages = [];
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text("cancel"))
                        ],
                        title: const Text("Unused images in store folder"),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height * .7,
                          width: MediaQuery.of(context).size.width * .9,
                          child: ListView.builder(
                              itemCount: deviceImages.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Image.file(
                                            File(deviceImages[index].path))),
                                    Text(deviceImages[index].name),
                                  ],
                                );
                              }),
                        ),
                      );
                    });
              },
              contentPadding: const EdgeInsets.all(5),
            ),
          ),
        ],
      ),
    );
  }
}
