import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchIcon;
  final bool showCartIcon;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;

  const CustomNavigationBar({
    Key? key,
    required this.title,
    this.showSearchIcon = true,
    this.showCartIcon = true,
    this.onSearchTap,
    this.onCartTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        // 移除了阴影效果
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo or Title
              Image.asset(
                'assets/images/icon_shopping_bar.png', // 替换成您的 logo 资源路径
                height: 24,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              // Search Icon
              if (showSearchIcon)
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black87,
                    size: 24,
                  ),
                  onPressed: onSearchTap,
                ),
              // Cart Icon
              if (showCartIcon)
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black87,
                    size: 24,
                  ),
                  onPressed: onCartTap,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}