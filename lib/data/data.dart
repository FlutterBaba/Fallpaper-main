import 'package:flutter/material.dart';

import '../models/categorie_model.dart';

String apiKEY = "563492ad6f91700001000001713867d8fd25452aac69c5a1f5b18c85";

List<CategorieModel> getCategories() {
  List<CategorieModel> categories = [];
  CategorieModel categorieModel = CategorieModel();

  //
  categorieModel.imgUrl = "assets/street art.jpg";
  categorieModel.categorieName = "Street Art";
  categories.add(categorieModel);
  categorieModel = CategorieModel();
  //
  categorieModel.imgUrl = "assets/wild life.jpg";
  categorieModel.categorieName = "Wild Life";
  categories.add(categorieModel);
  categorieModel = CategorieModel();

  //
  categorieModel.imgUrl = "assets/nature.jpg";
  categorieModel.categorieName = "Nature";
  categories.add(categorieModel);
  categorieModel = CategorieModel();

  //
  categorieModel.imgUrl = "assets/city.jpg";
  categorieModel.categorieName = "City";
  categories.add(categorieModel);
  categorieModel = CategorieModel();

  //
  categorieModel.imgUrl = "assets/motivation.jpg";
  categorieModel.categorieName = "Motivation";

  categories.add(categorieModel);
  categorieModel = CategorieModel();

  //
  categorieModel.imgUrl = "assets/bike.jpg";
  categorieModel.categorieName = "Bikes";
  categories.add(categorieModel);
  categorieModel = CategorieModel();

  //
  categorieModel.imgUrl = "assets/car.jpg";
  categorieModel.categorieName = "Cars";
  categories.add(categorieModel);
  categorieModel = CategorieModel();
  return categories;
}

class Appcolor {
  static const kblack = Colors.black;
  static const kwhite = Colors.white;
}
