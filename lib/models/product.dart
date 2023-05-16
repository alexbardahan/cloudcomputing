import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double reducedPrice;
  final String category;
  final String subCategory;
  final String imageSmall;
  final String imageBig;
  final String bigElement;
  final String video;
  final String grossWeight;
  final String allergens;
  final String nutVal;
  final String status;
  final String delivery;
  final String best;

  const Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.category,
    @required this.subCategory,
    @required this.imageSmall,
    @required this.imageBig,
    @required this.bigElement,
    @required this.video,
    @required this.delivery,
    @required this.status,
    @required this.best,
    this.reducedPrice,
    this.grossWeight,
    this.allergens,
    this.nutVal,
  });
}
