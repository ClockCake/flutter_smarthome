import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/address_form.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:oktoast/oktoast.dart';

class AddressListWidget extends StatefulWidget {
  final Function(Map<String,dynamic>)? onAddressSelected; // 新增回调
  const AddressListWidget({super.key,  this.onAddressSelected});

  @override
  State<AddressListWidget> createState() => _AddressListWidgetState();
}

class _AddressListWidgetState extends State<AddressListWidget> {
  List<Map<String,dynamic>> _addressList = []; //收货地址列表

  @override
  void initState() {
    super.initState();
    _getListData();
  }

  @override
  void dispose() {
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: HexColor('#F8F8F8'),
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text('收货地址', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddressFormWidget(type: 0, address: Map()),
              ),
            ).then((result) {
              _getListData();
            });
          },
        ),
      ],
    ),
    body: SafeArea(
      child: _addressList.isEmpty 
        ? EmptyStateWidget(
            onRefresh: _getListData,
            emptyText: '暂无数据',
            buttonText: '点击刷新',
          ) 
        : ListView.builder(
            itemCount: _addressList.length,
            itemBuilder: (BuildContext context, int index) {
              final item = _addressList[index];
              return GestureDetector(
                onTap: () {
                 if(widget.onAddressSelected != null) {
                    widget.onAddressSelected!(item);
                    Navigator.pop(context);
                  }
                },
                child: _buildListCell(item),
              );
            },
          ),
    ),
  );
}

  Widget _buildListCell(Map<String,dynamic> item) {
      return Dismissible(
        key: Key(item['id'].toString()),
        direction: DismissDirection.endToStart,
       confirmDismiss: (direction) async {
         return await showDialog(
           context: context,
           builder: (context) {
             return AlertDialog(
               title: Text('确认删除'),
               content: Text('您确定要删除这个地址吗？'),
               actions: [
               TextButton(
                   onPressed: () => Navigator.of(context).pop(false),
                   child: Text('取消'),
                 ),
                 TextButton(
                   onPressed: () => Navigator.of(context).pop(true),
                   child: Text('确认'),
                 ),
               ],
             );
          },
         );
       },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          setState(() {
            _addressList.removeWhere((element) => element['id'] == item['id']);
            deleteData(item['id']);
          });
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0.h),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 12.h,),
                    Row(
                      children: [
                          SizedBox(width: 16.w,),
                          Text(item['firstName'] ?? "", style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.bold)),
                          SizedBox(width: 8.w,),
                          Text(item['phoneNumber'] ?? "", style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8.h,),
                    Row(
                      children: [
                        SizedBox(width: 16.w,),
                        if(item['isDefault'] == "1") ...[
                          Container(
                            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
                            decoration: BoxDecoration(
                              color: HexColor('#FFF7F0'),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            child: Text('默认', style: TextStyle(color: HexColor('#FFA555'),fontSize: 10.sp)),
                          ),
                          SizedBox(width: 8.w,),
                        ],
                        Text(item['detailedAddress'] ?? "", style: TextStyle(fontSize: 12.sp,color: HexColor('#999999'))),
                      ],
                    ),
                    SizedBox(height: 12.h,),
                  ],
                ),
                Positioned(
                  bottom: 25.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressFormWidget(type: 1, address: item),
                        ),
                      ).then((result) {
                        _getListData();
                      });
                    },
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/icon_address_edit.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                
              ]
            ),
          ),
        ),
      );
  }

  //底部按钮
  Widget _buildBottomWidget(){
    return  GestureDetector(
        onTap: () {

        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.black,

          ),
          margin: EdgeInsets.fromLTRB(20.w, 0, 20.w,20.h),
          width: double.infinity,
          height: 44.h,
          alignment: Alignment.center,
          child: Text('添加收货地址', style: TextStyle(color: Colors.white)),
        ),
      );
  }

 //获取数据
  Future <void> _getListData() async {
     try{
       final apiManager = ApiManager();
       final response = await apiManager.get(
        '/api/shopping/address/list',
        queryParameters: null,
        );
        if (mounted && response != null)
        {
          setState(() {
            _addressList = List<Map<String, dynamic>>.from(response);

          });
        }
       
     }catch(e){
       print(e);
     }
  }

  //删除收货地址
  Future<void>deleteData(String addressId) async{
    try{
      final apiManager = ApiManager();
      final response = await apiManager.deleteWithList(
      '/api/shopping/address/remove',
      data: [addressId],
      );
      if(response != null){
        showToast( '删除成功');
      }     
    }
    catch(e){
      print(e);
    }
  }
}