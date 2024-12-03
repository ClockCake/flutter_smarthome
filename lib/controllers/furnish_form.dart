import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/furnish_record_list.dart';
import 'package:flutter_smarthome/controllers/recommend_designer_list.dart';
import 'package:flutter_smarthome/dialog/simple_bottom_sheet_selector.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/login_redirect.dart';
import 'package:flutter_smarthome/utils/user_manager.dart';
import 'package:oktoast/oktoast.dart';

class FurnishFormWidget extends StatefulWidget {
  const FurnishFormWidget({super.key});

  @override
  State<FurnishFormWidget> createState() => _FurnishFormWidgetState();
}

class _FurnishFormWidgetState extends State<FurnishFormWidget> {

  late bool isLogin; // 是否登录

 //获取的网络数据字典数组
  List<Map<String, dynamic>> _areaList = [];
  // 记录选中的索引
  int? areaselectedIndex;

  List<Map<String, dynamic>> _houseTypeList = [];
  int? houseTypeSelectedIndex;

  List<Map<String, dynamic>> _decorationTypeList = [];
  int? decorationTypeSelectedIndex;

  //姓名
  final nameController = TextEditingController();
  //联系方式
  final phoneController = TextEditingController();
  //x室
  final roomController = TextEditingController();
  //x厅
  final hallController = TextEditingController();
  //x厨
  final kitchenController = TextEditingController();
  //x卫
  final toiletController = TextEditingController();
  //房屋面积
  final areaController = TextEditingController();
  //需求备注
  final remarkController = TextEditingController();

 @override
  void initState() {
    super.initState();
    _updateLoginState();

  }
  void dispose() {
    nameController.dispose(); 
    phoneController.dispose(); 
    super.dispose();
  }

    // 更新登录状态
  void _updateLoginState() {
    setState(() {
      isLogin = UserManager.instance.isLoggedIn;
      if (isLogin) {
        _fetchAreaData();
        _fetchHouseType('crm_room_type,crm_decorate_type');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLogin == false ? 
      Center(
        child: GoLoginButton(
          onLoginSuccess: () {
            // 登录成功后刷新页面
            setState(() {
              _updateLoginState();
            });
          },
        ),
      ) :
      SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
            _buildFooter(),
          ],
        ),
      )
    );
  }

  //头部
  Widget _buildHeader() {
    return Container(
      color: HexColor('#FFF7F0'), // 设置背景色
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            SizedBox(width: 16.w,),
            Text('我要装修', style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.bold),),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              width: 108.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child:InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FurnishRecordListWidget()),
                  );
                },
                child:  Row(
                  children: [
                    Icon(Icons.book, color: HexColor('#FFA555'), size: 16.sp,),
                    SizedBox(width: 4.w,),
                    Text('装修记录', style: TextStyle(color: HexColor('#FFA555'), fontSize: 12.sp),),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  //中间表单
  Widget _buildForm(){
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
           Row(
            children: [
              Text('姓名', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: '请输入姓名',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
           ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          Row(
            children: [
              Text('联系方式', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '请输入手机号',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          Row(
            children: [
              Text('所在区域', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: GestureDetector( // 改用 GestureDetector
                  onTap: () {
                    showAreaSelector();
                  },
                  child: Container( 
                    width: double.infinity,
                    height: 48.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            areaselectedIndex != null 
                                ? _areaList[areaselectedIndex!]['name'] // 显示选中的区域名称
                                : '请选择所在区域',
                            style: TextStyle(
                              color: areaselectedIndex != null 
                                  ? Colors.black 
                                  : HexColor('#999999'),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, 
                          color: HexColor('#999999'), 
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          Row(
            children: [
              Text('房屋类型', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: GestureDetector( // 改用 GestureDetector
                  onTap: () {
                    showHouseTypeSelector();
                  },
                  child: Container( 
                    width: double.infinity,
                    height: 48.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            houseTypeSelectedIndex!= null 
                                ? _houseTypeList[houseTypeSelectedIndex!]['label'] 
                                : '请选择房屋类型',
                            style: TextStyle(
                              color: houseTypeSelectedIndex != null 
                                  ? Colors.black 
                                  : HexColor('#999999'),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, 
                          color: HexColor('#999999'), 
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //房屋户型 x 室 x 厅 x 厨 x 卫   其中 x 为输入框
          Row(
            children: [
              Text('房屋户型', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: roomController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('室', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                    SizedBox(width: 16.w,),
                    Expanded(
                      child: TextField(
                        controller: hallController,                  
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('厅', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                    SizedBox(width: 16.w,),
                    Expanded(
                      child: TextField(
                        controller: kitchenController,                  
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('厨', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                    SizedBox(width: 16.w,),
                    Expanded(
                      child: TextField(
                        controller: toiletController,                  
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text('卫', style: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //房屋面积
          Row(
            children: [
              Text('房屋面积', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  controller: areaController,                 
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '请输入房屋面积',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Text('㎡', style: TextStyle(color: Colors.black, fontSize: 14.sp),),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //装修类型
          Row(
            children: [
              Text('装修类型', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                  child: GestureDetector( // 改用 GestureDetector
                    onTap: () {
                      showDecorationTypeSelector();
                    },
                    child: Container( 
                      width: double.infinity,
                      height: 48.h,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              decorationTypeSelectedIndex != null 
                                  ? _decorationTypeList[decorationTypeSelectedIndex!]['label'] 
                                  : '请选择装修类型',
                              style: TextStyle(
                                color: decorationTypeSelectedIndex != null 
                                    ? Colors.black 
                                    : HexColor('#999999'),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, 
                            color: HexColor('#999999'), 
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Divider(height: 1.h, color: HexColor('#E5E5E5'),),
          //需求备注
          Row(
            children: [
              Text('需求备注', style: TextStyle(fontSize: 14.sp),),
              SizedBox(width: 16.w,),
              Expanded(
                child: TextField(
                  controller: remarkController,
                  decoration: InputDecoration(
                    hintText: '请输入需求备注',
                    hintStyle: TextStyle(color: HexColor('#999999'), fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //尾部退出按钮
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: InkWell(
        onTap: () {
           _onSubmit();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const RecommendDesignerListWidget()),
          // );
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: HexColor('#111111'),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text('确认', style: TextStyle(color: Colors.white, fontSize: 15.sp),),
          ),
        ),
      )
    );
  }
  

  //网络请求
  // 获取区域数据
  Future<void> _fetchAreaData() async {
   try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/home/furnish/area',
        queryParameters: {
          'parentId': '3101', // 上海市的id
        },
      );

      if (response != null) {
      // 首先获取 data 字段的数据
       _areaList = List<Map<String, dynamic>>.from(response);
        setState(() {
           
        });

      }
    } catch (e) {
      print(e);
    }
  }

  //获取房屋类型
  Future<void> _fetchHouseType(String path) async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.get(
        '/api/home/dict/$path',
        queryParameters: null,
      );

      if (response != null) {
        _houseTypeList = List<Map<String, dynamic>>.from(response['crm_room_type']);
        _decorationTypeList = List<Map<String, dynamic>>.from(response['crm_decorate_type']);
        setState(() {
           
        });

      }
    } catch (e) {
      print(e);
    }
  }

  //显示区域选择器
  void showAreaSelector() {
    List<Map<String, dynamic>> items = [];
    for (var item in _areaList) {
      items.add({
        'title': item['name'],
        'id': item['id'],
      });
    }
    SimpleBottomSheetSelector.show(
      context,
      items: items,
      initialSelectedIndex: areaselectedIndex,
      onSelected: (index) {
        setState(() {
          areaselectedIndex = index;
        });
        print('选中了：${items[index]['title']}');
      },
   );
  }

  //显示房屋类型选择器
  void showHouseTypeSelector() {
    if (_houseTypeList.isNotEmpty) {
      List<Map<String, dynamic>> items = [];
      for (var item in _houseTypeList) {
        items.add({
          'title': item['label'],
          'id': item['id'],
        });
      }
      SimpleBottomSheetSelector.show(
        context,
        items: items,
        onSelected: (index) {
          setState(() {
            houseTypeSelectedIndex = index;
          });
          print('选中了：${items[index]['title']}');
        },
      );
    }
  }

  //显示装修类型选择器
  // ignore: unused_element
  void showDecorationTypeSelector() {
    if (_decorationTypeList.isNotEmpty) {
      List<Map<String, dynamic>> items = [];
      for (var item in _decorationTypeList) {
        items.add({
          'title': item['label'],
          'id': item['id'],
        });
      }
      SimpleBottomSheetSelector.show(
        context,
        items: items,
        onSelected: (index) {
          setState(() {
            decorationTypeSelectedIndex = index;
          });
          print('选中了：${items[index]['title']}');
        },
      );
    }
  }
  
  // 点击后效验参数
  void _onSubmit() {
    if (nameController.text.isEmpty) {
      showToast('请输入姓名');
      return;
    }
    if (phoneController.text.isEmpty) {
      showToast('请输入手机号');
      return;
    }
    if (areaselectedIndex == null) {
      showToast('请选择所在区域');
      return;
    }
    if (houseTypeSelectedIndex == null) {
      showToast('请选择房屋类型');
      return;
    }
    if (roomController.text.isEmpty) {
      showToast('请输入房屋户型');
      return;
    }
    if (hallController.text.isEmpty) {
      showToast('请输入房屋户型');
      return;
    }
    if (kitchenController.text.isEmpty) {
      showToast('请输入房屋户型');
      return;
    }
    if (toiletController.text.isEmpty) {
      showToast('请输入房屋户型');
      return;
    }
    if (areaController.text.isEmpty) {
      showToast('请输入房屋面积');
      return;
    }
    if (decorationTypeSelectedIndex == null) {
      showToast('请选择装修类型');
      return;
    }
    if (remarkController.text.isEmpty) {
      showToast('请输入需求备注');
      return;
    }
    _submitForm();

  }
  
  //提交表单数据
  Future<void> _submitForm() async {
    try {
      final apiManager = ApiManager();
      final response = await apiManager.post(
        '/api/home/furnish/submit',
        data: {
          'name': nameController.text,
          'phone': phoneController.text,
          'region': _areaList[areaselectedIndex!]['name'],
          'roomType':_houseTypeList[houseTypeSelectedIndex!]['value'],
          'area': areaController.text,
          'decorateType': _decorationTypeList[decorationTypeSelectedIndex!]['value'],
          'bedroomNumber': roomController.text,
          'livingRoomNumber': hallController.text,
          'kitchenRoomNumber': kitchenController.text,
          'toiletRoomNumber': toiletController.text,
          'remark': remarkController.text,
        },
      );
        showToast('提交成功');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecommendDesignerListWidget()),
        );
        _clearForm();
        
    } catch (e) {
      print(e);
    }
  }

  //清空表单数据
  void _clearForm() {
    setState(() {
      nameController.clear();
      phoneController.clear();
      roomController.clear();
      hallController.clear();
      kitchenController.clear();
      toiletController.clear();
      areaController.clear();
      remarkController.clear();
      areaselectedIndex = null;
      houseTypeSelectedIndex = null;
      decorationTypeSelectedIndex = null;
    });
  }
}
  
