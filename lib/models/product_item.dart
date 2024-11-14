import 'package:dio/dio.dart';

class ProductItem {
   String id;
   String imageUrl;
   String title;
   String? shopIcon;
   String shop;
   double price;
   String points;

  ProductItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.shopIcon,
    required this.shop,
    required this.price,
    required this.points,
  });
}