import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:store/database.dart';
import 'package:store/main.dart';

////////////////////////////////////////////////////////////
class ItemPage extends StatefulWidget {
  const ItemPage({super.key, this.id});

  final int? id;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

///////////////////////////////
class _ItemPageState extends State<ItemPage> {
  ImagePicker image = ImagePicker();
  List<XFile> images = [];
  List<XFile> savedImages = [];
  late PermissionStatus camera;
  late PermissionStatus storage;
  ModelDB row = ModelDB(name: '', place: '', description: '');

  ModelDB model = ModelDB(name: '', place: '', description: '');
  bool create = true;

  // create a directory to save images
  createDirectory() {
    Directory('/storage/emulated/0/store').createSync();
  }

  // get storage permission
  Future<PermissionStatus> getStoragePermission() async {
    await Permission.storage.request();
    storage = await Permission.manageExternalStorage.request();
    return storage;
  }

  // get camera permission
  getCameraPermission() async {
    await Permission.camera.request();
  }

  // insert a new row in database
  insertDB(ModelDB insert) async {
    await DBHelper().insert(insert);
  }

  //todo make an update/replace function

  // get row by id
  getRow() async {
    List rows = await DBHelper().queryFilterRow(widget.id!);

    if (rows.isNotEmpty) {
      row = ModelDB.fromQuery(rows[0]);

      setState(() {
        if (row.img1 != null) {
          images.add(XFile(row.img1!));
          if (row.img2 != null) {
            images.add(XFile(row.img2!));
            if (row.img3 != null) {
              images.add(XFile(row.img3!));
              if (row.img4 != null) {
                images.add(XFile(row.img4!));
                if (row.img5 != null) {
                  images.add(XFile(row.img5!));
                  if (row.img6 != null) {
                    images.add(XFile(row.img6!));
                    if (row.img7 != null) {
                      images.add(XFile(row.img7!));
                      if (row.img8 != null) {
                        images.add(XFile(row.img8!));
                        if (row.img9 != null) {
                          images.add(XFile(row.img9!));
                          if (row.img10 != null) {
                            images.add(XFile(row.img10!));
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      });
    }
  }

  // pick images and set them to images
  pickImages() async {
    var img = await image.pickMultiImage(limit: 10);
    setState(() {
      images = img;
    });
  }

  // saves picked images to device
  saveImages() async {
    //can create directory
    //another project can create
    //problem solved, the problem:
    //problem with DateTime.now().toString().subString(0,18)

    // try saving in another folder
    if (await Permission.storage.isGranted) {
      if (images.isNotEmpty) {
        createDirectory();
        for (int i = 0; i < images.length; i++) {
          var year = DateTime.now().year;
          var month = DateTime.now().month;
          var day = DateTime.now().day;
          var hour = DateTime.now().hour;
          var minute = DateTime.now().minute;
          var second = DateTime.now().second;
          var path =
              '/storage/emulated/0/store/$year-$month-$day-$hour-$minute-$second-${row.name}-$i.jpg';
          await images[i].saveTo(path);
          if (await File(path).exists()) {
            savedImages.add(XFile(path));
          }
        }
        if (savedImages.isNotEmpty) {
          insertDB(ModelDB(
            name: row.name,
            place: row.place,
            description: row.description,
            img1: (savedImages.isNotEmpty) ? savedImages[0].path : null,
            img2: (savedImages.length > 1) ? savedImages[1].path : null,
            img3: (savedImages.length > 2) ? savedImages[2].path : null,
            img4: (savedImages.length > 3) ? savedImages[3].path : null,
            img5: (savedImages.length > 4) ? savedImages[4].path : null,
            img6: (savedImages.length > 5) ? savedImages[5].path : null,
            img7: (savedImages.length > 6) ? savedImages[6].path : null,
            img8: (savedImages.length > 7) ? savedImages[7].path : null,
            img9: (savedImages.length > 8) ? savedImages[8].path : null,
            img10: (savedImages.length > 9) ? savedImages[9].path : null,
          ));
        }
      } else {
        //todo you have not picked any images
      }
    }
  }

  @override
  initState() {
    super.initState();
    getStoragePermission().then((value) async {
      if (value == PermissionStatus.granted) {
        await createDirectory();
      }
      // getCameraPermission();
    });

    if (widget.id != null) {
      getRow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          (images.isNotEmpty)
              ? Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1)),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * .5,
                      maxWidth: MediaQuery.of(context).size.width * .9),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(File(images[index].path)),
                        );
                      }),
                )
              : const SizedBox(),
          TextFormField(
            decoration: const InputDecoration(labelText: 'name'),
            onChanged: (String value) {
              row.name = value;
            },
          ),
          TextFormField(
              decoration: const InputDecoration(labelText: 'place'),
              onChanged: (String value) {
                row.place = value;
              }),
          TextFormField(
              decoration: const InputDecoration(labelText: 'description'),
              onChanged: (String value) {
                row.description = value;
              }),
          ElevatedButton(
              onPressed: () {
                pickImages();
              },
              child: const Text('image picker')),
          ElevatedButton(
              onPressed: () async {
                // for (var i = 0; i <  Permission.values.length; i++) {
                //   if (await Permission.values[i].status == PermissionStatus.granted) {
                //     print('\n\n\n\n${Permission.values[i]} : ${await Permission.values[i].status}\n\n\n\n');
                //   }
                // }
                await saveImages();
              },
              child: const Text('save')),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
