import 'dart:io';

import 'package:flutter/material.dart';
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

  getRows() async {
    var query = await DBHelper().queryAllRows();
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
