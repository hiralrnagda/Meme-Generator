import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey globalKey = new GlobalKey();
  String headerText = "";
  String footerText = "";
  File _image;
  File _imageFile;
  Random rng = new Random();
  bool imageSelected = false;

  Future getImage() async {
    var image;
    try {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    } catch (platformException) {
      print("not allowing " + platformException);
    }
    setState(() {
      if (image != null) {
        imageSelected = true;
      } else {}
      _image = image;
    });
    new Directory('meme').create(recursive: true);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Image.asset(
                "assets/smile.png",
                height: 80,
              ),
              SizedBox(
                height: 12,
              ),
              Image.asset(
                "assets/memegenrator.png",
                height: 70,
              ),
              SizedBox(
                height: 12,
              ),
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: [
                    _image != null
                        ? Image.file(
                            _image,
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            fit: BoxFit.fitHeight,
                          )
                        : Container(),
                    Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              headerText.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Spacer(),
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                footerText.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              imageSelected
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (val) {
                              setState(() {
                                headerText = val;
                              });
                            },
                            decoration:
                                InputDecoration(hintText: "Header Text"),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          TextField(
                            onChanged: (val) {
                              setState(() {
                                footerText = val;
                              });
                            },
                            decoration:
                                InputDecoration(hintText: "Footer Text"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          RaisedButton(
                            color: Colors.lightBlue.shade300,
                            onPressed: () {
                                  takeScreenShot();
                                },
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      child: Center(
                        child: Text(
                          "Select image to get started",
                          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,backgroundColor: Colors.lime.shade100),),
                        ),),
                _imageFile != null ? Center(child: Image.file(_imageFile)) : Container(),
                  
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo),
        onPressed: () {
          getImage();
        },
      ),
    );
  }


  takeScreenShot() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    //print(directory);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    File imgFile = new File('$directory/screenshot${rng.nextInt(200)}.png');
    setState(() {
      _imageFile = imgFile;
    });
    _savefile(_imageFile);
    //saveFileLocal();
    imgFile.writeAsBytes(pngBytes);
  }

  _savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    //print(result);
  }

  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.photos]);
  }
}
