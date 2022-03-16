import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/widget/color_remover.dart';
import '../data/data.dart';
import '../models/photos_model.dart';
import '../widget/wallpaperwidget.dart';

class CategorieScreen extends StatefulWidget {
  final String? categorie;

  const CategorieScreen({Key? key, this.categorie}) : super(key: key);

  @override
  _CategorieScreenState createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen> {
  List<PhotosModel> photos = [];
  bool isLoading = false;
  getCategorieWallpaper() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(
        'https://api.pexels.com/v1/search?query=${widget.categorie}&per_page=30&page=1');

    await http.get(url, headers: {"Authorization": apiKEY}).then((value) {
      //print(value.body);

      Map<String, dynamic> jsonData = jsonDecode(value.body);
      jsonData["photos"].forEach((element) {
        //print(element);
        PhotosModel photosModel = PhotosModel();
        photosModel = PhotosModel.fromMap(element);
        photos.add(photosModel);
        //print(photosModel.toString()+ "  "+ photosModel.src.portrait);
      });
      setState(() {});
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getCategorieWallpaper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Appcolor.kblack),
        title: const Text(
          "Fallpaper",
          style: TextStyle(color: Appcolor.kblack),
        ),
        backgroundColor: Appcolor.kwhite,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ColorRemover(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wallpaper(
                  listPhotos: photos,
                ),
              ),
            ),
    );
  }
}
