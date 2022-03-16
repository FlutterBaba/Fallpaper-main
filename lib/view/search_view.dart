import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/data.dart';
import '../models/photos_model.dart';
import '../widget/wallpaperwidget.dart';

class SearchView extends StatefulWidget {
  final String search;

  const SearchView({Key? key, required this.search}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<PhotosModel> photos = [];
  TextEditingController searchController = TextEditingController();

  getSearchWallpaper(String searchQuery) async {
    var url = Uri.parse(
        'https://api.pexels.com/v1/search?query=$searchQuery&per_page=30&page=1');

    await http.get(url, headers: {"Authorization": apiKEY}).then((value) {

      Map<String, dynamic> jsonData = jsonDecode(value.body);
      jsonData["photos"].forEach((element) {
        PhotosModel photosModel = PhotosModel();
        photosModel = PhotosModel.fromMap(element);
        photos.add(photosModel);
      });

      setState(() {});
    });
  }

  @override
  void initState() {
    getSearchWallpaper(widget.search);
    searchController.text = widget.search;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fallpaper",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xfff5f8fd),
                borderRadius: BorderRadius.circular(30),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                        hintText: "search wallpapers",
                        border: InputBorder.none),
                  )),
                  InkWell(
                      onTap: () {
                        getSearchWallpaper(searchController.text);
                      },
                      child: const Icon(Icons.search))
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Wallpaper(
              listPhotos: photos,
            ),
          ],
        ),
      ),
    );
  }
}
