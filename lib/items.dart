import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:store/database.dart';

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
  ModelDB row = ModelDB(item: '', location: '', description: '');
  bool create = true;
  TextEditingController item = TextEditingController(text: '');
  TextEditingController location = TextEditingController(text: '');
  TextEditingController description = TextEditingController(text: '');

  // create a directory to save images
  createDirectory() {
    Directory('/storage/emulated/0/store').createSync();
  }

  // get storage permission
  Future<PermissionStatus> getStoragePermission() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        await Permission.storage.request();
      } else {
        await Permission.photos.request();
      }
    }
    storage = await Permission.manageExternalStorage.request();
    return storage;
  }

  // todo add camera support
  // getCameraPermission() async {
  //   await Permission.camera.request();
  // }

  // insert a row in database (new/update)
  Future<int> insertDB(ModelDB insert) async {
    var result = await DBHelper().insert(insert);
    int id = result[0]['last_insert_rowid()'];
    return id;
  }

  // get row by id
  getRow(int id) async {
    List rows = await DBHelper().queryFilterRow(id);

    if (rows.isNotEmpty) {
      var newRow = ModelDB.fromQuery(rows[0]);
      setState(() {
        row = newRow;
        item.text = row.item;
        location.text = row.location;
        description.text = row.description;
        images.clear();
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
    } else {}
  }

  // pick images and set them to images
  pickImages() async {
    var img = await image.pickMultiImage(limit: 10);
    if (img.length > 10) {
      toast('You can only save 10 images per item');
    }
    setState(() {
      images = img;
    });
  }

  // saves picked images to device
  saveImages() async {
    if (await Permission.storage.isGranted) {
      if (images.isNotEmpty) {
        createDirectory();
        savedImages.clear();
        for (int i = 0; i < images.length; i++) {
          var year = DateTime.now().year;
          var month = DateTime.now().month;
          var day = DateTime.now().day;
          var hour = DateTime.now().hour;
          var minute = DateTime.now().minute;
          var second = DateTime.now().second;
          var extension = images[i].name.toString().split(".").last;
          var path =
              '/storage/emulated/0/store/$year-$month-$day-$hour-$minute-$second-${row.item}-$i.$extension';
          await images[i].saveTo(path);
          if (await File(path).exists()) {
            savedImages.add(XFile(path));
          }
        }
        if (savedImages.isNotEmpty) {
          await insertDB(ModelDB(
            id: row.id,
            item: row.item,
            location: row.location,
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
          )).then((value) {
            getRow(value);
            toast('Saved successfully');
          });
        }
      } else {
        toast('You have not selected any images');
      }
    }
  }

  toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toUpperCase()),
        width: MediaQuery.of(context).size.width * .95,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  removeRow() async {
    for (int i = 0; i < images.length; i++) {
      List splitPath = images[i].path.split('/');
      splitPath.removeLast();
      if (splitPath.last == 'store') {
        try {
          File(images[i].path).deleteSync();
        } catch (e) {
          //do nothing
        }
      }
    }
    await DBHelper().delete(row.id!).then((int value) {
      if (value > 0) {
        toast('Removed successfully');
        Navigator.of(context).pop();
      } else {
        toast('Failed to remove item');
      }
    });
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
      getRow(widget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          (images.isNotEmpty)
              ?
              //Display media
              Container(
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * .5,
                      maxWidth: MediaQuery.of(context).size.width * .9),
                  child: true
                      ? PhotoViewGallery(
                          pageOptions: <PhotoViewGalleryPageOptions>[
                              for (var i = 0; i < images.length; i++)
                                PhotoViewGalleryPageOptions(
                                    imageProvider:
                                        FileImage(File(images[i].path)))
                            ])
                      : PhotoViewGallery.builder(
                          itemCount: images.length,
                          builder: ((context, index) {})),
                )
              : const SizedBox(),
          TextFormField(
            controller: item,
            decoration: const InputDecoration(labelText: 'ITEM'),
            onChanged: (String value) {
              row.item = value;
            },
          ),
          TextFormField(
              controller: location,
              decoration: const InputDecoration(labelText: 'LOCATION'),
              onChanged: (String value) {
                row.location = value;
              }),
          TextFormField(
              controller: description,
              decoration: const InputDecoration(labelText: 'DESCRIPTION'),
              onChanged: (String value) {
                row.description = value;
              }),
          ElevatedButton(
              onPressed: () {
                pickImages();
              },
              child: const Text('PICK IMAGES')),
          ElevatedButton(
              onPressed: () async {
                await saveImages();
              },
              child: const Text('SAVE')),
          ElevatedButton(
              onPressed: () {
                if (row.id != null) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                              "Are you sure you want to delete this record?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () {
                                  removeRow();
                                  Navigator.pop(context);
                                },
                                child: const Text("Delete"))
                          ],
                        );
                      });
                }
              },
              child: const Text('DELETE')),
          const SizedBox(
            height: 200,
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
