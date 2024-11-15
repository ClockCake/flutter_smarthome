import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/models/product_item.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class ScrollableProductList extends StatelessWidget {
  final List<ProductItem> products;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;

  const ScrollableProductList({
    Key? key,
    required this.products,
    this.itemWidth = 160,
    this.itemHeight = 240,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: List.generate(
          products.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              right: index == products.length - 1 ? 0 : spacing,
            ),
            child: _ProductCard(
              product: products[index],
              width: itemWidth,
              height: itemHeight,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductItem product;
  final double width;
  final double height;

  const _ProductCard({
    Key? key,
    required this.product,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        // 移除卡片的圆角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), // 只给图片容器添加圆角
              color: Colors.grey[200], // 添加背景色作为图片加载前的占位
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12), // 裁剪图片为圆角
              child: Image.network(
                product.imageUrl,
                width: width,
                height: width,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 商品信息
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.shopIcon?.isNotEmpty == true) // 检查不仅不为 null 而且不为空字符串
                      Container(
                        width: 14.w,
                        height: 14.w,
                        margin: EdgeInsets.only(right: 4),
                        child: NetworkImageHelper().getCachedNetworkImage(
                          imageUrl: product.shopIcon!,
                        ),
                      ),
                      Expanded( // 添加 Expanded 让文字可以自适应宽度
                        child: Text(
                          product.shop,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis, // 文字过长时显示省略号
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '¥${product.price}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#222222')
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '积分 ${product.points}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}