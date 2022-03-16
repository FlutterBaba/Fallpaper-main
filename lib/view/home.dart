import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaper_app/widget/color_remover.dart';
import 'dart:convert';

import '../data/data.dart';
import '../models/categorie_model.dart';
import '../models/photos_model.dart';
import 'categorie_screen.dart';
import '../widget/wallpaperwidget.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategorieModel> categories = [];

  int noOfImageToLoad = 30;
  List<PhotosModel> photos = [];
  List<PhotosModel> search = [];

  bool isLoading = false;
  getTrendingWallpaper() async {
    setState(() {
      isLoading = true;
      photos.clear();
    });

    var url = Uri.parse(
        'https://api.pexels.com/v1/curated?per_page=$noOfImageToLoad&page=1');

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

  TextEditingController searchController = TextEditingController();

  ScrollController scrollController = ScrollController();
  getSearchWallpaper() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(
        'https://api.pexels.com/v1/search?query=${searchController.text}&per_page=30&page=1');
    http.Response response =
        await http.get(url, headers: {"Authorization": apiKEY});
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    jsonData["photos"].forEach((element) {
      //print(element);
      setState(() {
        PhotosModel photosModel = PhotosModel();
        photosModel = PhotosModel.fromMap(element);
        search.add(photosModel);
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    //getWallpaper();
    getTrendingWallpaper();
    categories = getCategories();
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        noOfImageToLoad = noOfImageToLoad + 30;
        getTrendingWallpaper();
      }
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
      body: ColorRemover(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff5f8fd),
                  borderRadius: BorderRadius.circular(30),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                // padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: TextField(
                      controller: searchController,
                      onEditingComplete: () {
                        if (searchController.text.isNotEmpty) {
                          getSearchWallpaper();
                          FocusScope.of(context).unfocus();
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isEmpty
                              ? const SizedBox()
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      searchController.clear();
                                      search.clear();
                                      FocusScope.of(context).unfocus();
                                    });
                                  },
                                  icon: const Icon(Icons.close)),
                          hintText: "Search wallpapers",
                          border: InputBorder.none),
                    )),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 80,
                child: ColorRemover(
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: categories.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return CategoriesTile(
                          imgUrls: categories[index].imgUrl!,
                          categorie: categories[index].categorieName!,
                        );
                      }),
                ),
              ),
              searchController.text.isEmpty
                  ? isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Wallpaper(
                          listPhotos: photos,
                        )
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Wallpaper(
                          listPhotos: search,
                        ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Photos provided By ",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURL("https://www.pexels.com/");
                    },
                    child: const Text(
                      "Pexels",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesTile extends StatelessWidget {
  final String imgUrls, categorie;

  const CategoriesTile(
      {Key? key, required this.imgUrls, required this.categorie})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategorieScreen(
                      categorie: categorie,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: kIsWeb
            ? Column(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        categorie,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
              )
            : Stack(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )),
                  Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                      height: 50,
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        categorie,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ))
                ],
              ),
      ),
    );
  }
}
