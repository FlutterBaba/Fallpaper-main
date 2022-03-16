import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:http/http.dart' as http;

class ImageView extends StatefulWidget {
  final String imgPath;

  const ImageView({Key? key, required this.imgPath}) : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  bool isLoading = false;
  Stream<String>? progressString;
  String contentText = "";

  Future<void> myDialogBox(context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                // color: Colors.red,
                height: 200,
                child: contentText == "Loading"
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text("Set Home Screen"),
                            onTap: () async {
                              setState(() {
                                contentText = "Loading";
                              });

                              await dowloadImage(context, () async {
                                var width = MediaQuery.of(context).size.width;
                                var height = MediaQuery.of(context).size.height;
                                await Wallpaper.homeScreen(
                                    options: RequestSizeOptions.RESIZE_FIT,
                                    width: width,
                                    height: height);
                                setState(() {
                                  contentText = "not";
                                });
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text("Set Lock Screen"),
                            onTap: () async {
                              setState(() {
                                contentText = "Loading";
                              });
                              await dowloadImage(context, () async {
                                await Wallpaper.lockScreen();
                                setState(() {
                                  contentText = "not";
                                });
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text("Both"),
                            onTap: () async {
                              setState(() {
                                contentText = "Loading";
                              });
                              await dowloadImage(context, () async {
                                await Wallpaper.bothScreen();
                                setState(() {
                                  contentText = "not";
                                });
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  void shareImage() async {
    final uri = Uri.parse(widget.imgPath);
    final response = await http.get(uri);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);
    await Share.shareFiles([path], text: 'Image Shared');
  }

  Future<void> dowloadImage(BuildContext context, Function()? onDone) async {
    progressString = Wallpaper.imageDownloadProgress(widget.imgPath);

    progressString!.listen((data) {}, onDone: onDone, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              shareImage();
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () async {
              await save();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Download Completed"),
                ),
              );
            },
            icon: const Icon(Icons.download),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: <Widget>[
          Hero(
            tag: widget.imgPath,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: kIsWeb
                  ? Image.network(widget.imgPath, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: widget.imgPath,
                      placeholder: (context, url) => Container(
                        color: const Color(0xfff5f8fd),
                      ),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                    onTap: () async {
                      myDialogBox(context);
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff1C1B1B).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white24, width: 1),
                                borderRadius: BorderRadius.circular(40),
                                gradient: const LinearGradient(
                                    colors: [
                                      Color(0x36FFFFFF),
                                      Color(0x0FFFFFFF)
                                    ],
                                    begin: FractionalOffset.topLeft,
                                    end: FractionalOffset.bottomRight)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Set Wallpaper",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Text(
                                  kIsWeb
                                      ? "Image will open in new tab to download"
                                      : "Image will be saved in gallery",
                                  style: TextStyle(
                                      fontSize: 8, color: Colors.white70),
                                ),
                              ],
                            )),
                      ],
                    )),
                const SizedBox(
                  height: 16,
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  save() async {
    await _askPermission();
    var response = await Dio().get(widget.imgPath,
        options: Options(responseType: ResponseType.bytes));

    await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  }

  _askPermission() async {
    if (Platform.isIOS) {
      await Permission.photos.status;
    } else {
      await Permission.storage.status;
    }
  }
}
