import 'dart:ffi';

import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:oktoast/oktoast.dart';

class AddressFormWidget extends StatefulWidget {
  final int? type; // 0 是新建 1 是编辑
  final Map<String,dynamic> address;
  const AddressFormWidget({
    required this.type,
    required this.address,
    super.key
  });

  @override
  State<AddressFormWidget> createState() => _AddressFormWidgetState();
}

class _AddressFormWidgetState extends State<AddressFormWidget> {
  bool isSwitched = false;
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String state = ''; //省
  String city = ''; //市
  String district = ''; //区

  @override
  void initState() {
    super.initState();
    if (widget.type == 1) {
      _recipientController.text = widget.address['firstName'] ?? '';
      _phoneController.text = widget.address['phoneNumber'] ?? '';
      state = widget.address['state'] ?? '';
      city = widget.address['city'] ?? '';
      district = widget.address['district'] ?? '';
      _areaController.text = '$state-$city-$district';
      _addressController.text = widget.address['detailedAddress'] ?? '';
      isSwitched = widget.address['isDefault'] == 1;
    }
  }
  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('添加收货地址', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildFormWidget()),
            _buildBottomWidget()
          ],
        ),
      )
    );
  }

 Widget _buildFormWidget() {
   return SingleChildScrollView(
      child: Column(
         children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 12.h),
                  child:Text(
                    '收货人',
                    style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp),
                  )
                ),
                SizedBox(width: 16.w),
                //输入框
                Expanded(
                  child: TextField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      hintText: '请填写',
                      hintStyle: TextStyle(color: HexColor('#999999'),fontSize: 14.sp),
                      border: InputBorder.none,
                    ),
                  )
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 12.h),
                  child:Text(
                    '手机号',
                    style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp),
                  )
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: '请填写',
                      hintStyle: TextStyle(color: HexColor('#999999'),fontSize: 14.sp),
                      border: InputBorder.none,
                    ),
                  )
                )
              ],
            ),
            GestureDetector(
              onTap: () async {
                 getResult().then((value) {
                  if (value == null) {
                    return;
                  }
                  state = value.provinceName!;
                  city = value.cityName!;
                  district = value.areaName!;
                  
                  String address = '${value?.provinceName}-${value?.cityName}-${value?.areaName}';
                  _areaController.text = address; // { changed code }

                });
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 12.h),
                    child:Text(
                      '所在地区',
                      style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp),
                    )
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextField(
                      //输入框不可编辑
                      controller: _areaController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: '请选择',
                        hintStyle: TextStyle(color: HexColor('#999999'),fontSize: 14.sp),
                        border: InputBorder.none,
                      ),
                    )
                  )
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 12.h),
                  child:Text(
                    '详细地址',
                    style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp),
                  )
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: '请填写',
                      hintStyle: TextStyle(color: HexColor('#999999'),fontSize: 14.sp),
                      border: InputBorder.none,
                    ),
                  )
                )
              ],
            ),
            Container(
              width: double.infinity,
              height: 8.h,
              color: HexColor('#F8F8F8'),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 12.h),
                  child:Text(
                    '设置为默认地址',
                    style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp),
                  )
                ),
                Spacer(),
                Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  activeTrackColor: Colors.grey,
                  activeColor: HexColor('#FFB26D'),
                )
              ],
            )
         ],
      ),
   );
 }
    //底部按钮
  Widget _buildBottomWidget(){
    return  GestureDetector(
        onTap: () {
          widget.type == 0 ? commitAddress() : editAddress();
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
          child: Text('保存', style: TextStyle(color: Colors.white)),
        ),
      );
  }

  //选择地区
  Future<Result?> getResult () async {
    
    Result? cityPickerResult = await CityPickers.showCityPicker(
      context: context,
    );
    return cityPickerResult;
  }
  //新建地址
  Future<void> commitAddress() async {
    Map <String,dynamic> item  = {
      'firstName': _recipientController.text,
      'phoneNumber': _phoneController.text,
      'state': state,
      'city':city,
      'district':district,
      'detailedAddress':_addressController.text,
      'isDefault': isSwitched ? 1 : 0
    };
    try{
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/shopping/address/add',
        data: item
      );
      if (response != null) {
        showToast('添加收货地址成功');
        Navigator.pop(context);
      }
    }catch(e){
      showToast('添加地址失败: ${e.toString()}');
    }
  }

  //编辑地址
  Future<void> editAddress() async {
    Map <String,dynamic> item  = {
      'id': widget.address['id'],
      'firstName': _recipientController.text,
      'phoneNumber': _phoneController.text,
      'state': state,
      'city':city,
      'district':district,
      'detailedAddress':_addressController.text,
      'isDefault': isSwitched ? 1 : 0
    };
    try{
      final apiManager = ApiManager();
      final response = await apiManager.put(
        '/api/shopping/address/update',
        data: item
      );
      if (response != null) {
        showToast('编辑收货地址成功');
        Navigator.pop(context);
      }
    }catch(e){
      showToast('编辑地址失败: ${e.toString()}');
    }
  }

}