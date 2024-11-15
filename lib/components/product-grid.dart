import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/models/product_item.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductItem> products;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductGrid({
    Key? key,
    required this.products,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.shrinkWrap = true,  // 默认设置为 true
    this.physics = const NeverScrollableScrollPhysics(),  // 禁用滚动
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: shrinkWrap,  // 使用 shrinkWrap
      physics: physics,  // 使用传入的 physics
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    // width: double.infinity,
                  ),
                ),
              ),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (product.shopIcon != null && product.shopIcon!.isNotEmpty) // 检查不仅不为 null 而且不为空字符串
                        Container(
                          width: 16,
                          height: 16,
                          child: NetworkImageHelper().getNetworkImage(imageUrl: product.shopIcon!),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.shop,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '¥${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: HexColor('#222222'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '积分 ${product.points}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
      },
    );
  }
}