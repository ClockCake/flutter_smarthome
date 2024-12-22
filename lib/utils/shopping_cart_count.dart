import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';


class ShoppingCartItem extends StatefulWidget {
  final int initialQuantity;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onQuantityChanged;

  ShoppingCartItem({
    Key? key,
    this.initialQuantity = 1,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _ShoppingCartItemState createState() => _ShoppingCartItemState();
}

class _ShoppingCartItemState extends State<ShoppingCartItem> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    // 确保初始数量在最小和最大值之间
    _quantity = widget.initialQuantity.clamp(widget.minQuantity, widget.maxQuantity);
  }

  void _increment() {
    if (_quantity < widget.maxQuantity) {
      setState(() {
        _quantity++;
      });
      widget.onQuantityChanged(_quantity);
    } else {
      showToast("已达到最大数量 ${widget.maxQuantity}");
    }
  }

  void _decrement() {
    if (_quantity > widget.minQuantity) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    } else {
      showToast("已达到最小数量 ${widget.minQuantity}");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canDecrement = _quantity > widget.minQuantity;
    bool canIncrement = _quantity < widget.maxQuantity;

return Row(
  mainAxisSize: MainAxisSize.min,
  children: [
      // 减号按钮
      GestureDetector(
        onTap: canDecrement ? _decrement : () {
          showToast("已达到最小数量 ${widget.minQuantity}");
        },
        child: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Icon(Icons.remove, size: 16.sp),
        ),
      ),
      SizedBox(width: 8.w),
      // 显示当前数量
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          '$_quantity',
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
      SizedBox(width: 8.w),
      // 加号按钮
      GestureDetector(
        onTap: canIncrement ? _increment : () {
          showToast("已达到最大数量 ${widget.maxQuantity}");
        },
        child: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Icon(Icons.add, size: 16.sp),
        ),
      ),
    ],
  );
 }
}