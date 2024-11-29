import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/login_page.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';
import 'package:flutter_smarthome/utils/network_image_helper.dart';
import '../models/user_model.dart';
import '../utils/user_manager.dart';
import './personal_setting.dart';
class PersonalHomeWidget extends StatefulWidget {
  const PersonalHomeWidget({super.key});

  @override
  State<PersonalHomeWidget> createState() => _PersonalHomeWidgetState();
}

class _PersonalHomeWidgetState extends State<PersonalHomeWidget> {
  late bool isLogin; // 是否登录
  UserModel? user; // 用户信息
  //字符串数组
  final List<String> _orderTitles = [
    '待付款',
    '待发货',
    '待收货',
    '待评价',
  ];
  //本地图片资源数组
  final List<String> _orderIcons = [
    'assets/images/icon_order_nopay.png',
    'assets/images/icon_order_ship.png',
    'assets/images/icon_order_arrive.png',
    'assets/images/icon_order_evaluate.png',
  ];

  @override
  void initState() {
    super.initState();
    _updateLoginState();
    // 添加状态监听
    UserManager.instance.notifier.addListener(_updateLoginState);
  }

  @override
  void dispose() {
    // 移除状态监听
    UserManager.instance.notifier.removeListener(_updateLoginState);
    super.dispose();
  }

  // 更新登录状态
  void _updateLoginState() {
    setState(() {
      user = UserManager.instance.user;
      isLogin = UserManager.instance.isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;  // 获取状态栏高度

    return Scaffold(
      body: SingleChildScrollView(
         child: Column(
           children: [
              _buildHeader(topPadding + 250.h),
              SizedBox(height: 16.h),
              _buildOrder(),
              _buildServiceCell(),
           ],
         ),
      ),
    );
  }


  // 构建头部
  Widget _buildHeader(double topPadding){
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/icon_personal_bg.png'), // 使用本地资源图片
          fit: BoxFit.cover, // 控制图片的填充方式
        ),
      ),
      width: double.infinity,
      height: topPadding,
      child: Column(
        children: [
          SizedBox(height: topPadding - 250.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Image.asset('assets/images/icon_personal_setting.png',width: 24.w,height: 24.h),
                onPressed: () {
                  if (!isLogin) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    ).then((_) {
                      // 登录页面返回后更新状态
                      _updateLoginState();
                    });
                    return;
                  }else{
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PersonalSettingWidget()),
                    );     
                  }

                },
              ),
              
            ],
          ),
          // SizedBox(height: 48.h),
          Row(
            children: [
              SizedBox(width:16.w),
              ClipOval(
                child: Container(
                  width: 48.w,  // 确保宽高一致
                  height: 48.w, // 使用相同的单位(w)
                  child: isLogin 
                    ? NetworkImageHelper().getNetworkImage(
                      imageUrl: user?.avatar ?? '',
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                        'assets/images/icon_default_avatar.png',
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            SizedBox(width: 16.w),
            //Text 点击事件
            InkWell(
              child: Text(
                isLogin ? (user?.nickname ?? '用户名') : '登录/注册',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                if (!isLogin) {
                  Navigator.push(
                    context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  ).then((_) {
                    // 登录页面返回后更新状态
                    _updateLoginState();
                  });
                } else {
                  //暂无此业务逻辑
                }
              },
            ),
           ],
          ),
          SizedBox(height: 16.h),
          _buildFavoriteAndLike(),  // 收藏和点赞
          const Spacer(),
          _buildIntegralMall(),  // 积分商城
        ],
      )
    );
  }


  //收藏/点赞
  Widget _buildFavoriteAndLike(){
    return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                print('Tapped A');
                // 处理 A 区域的点击事件
              },
              child: Container(
                height: 50.h, // 设置合适的点击区域高度
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                  children: [
                    Text(
                      '0',  // 第一行文本
                      style: TextStyle(
                        fontSize: 17.sp,  // 较大字号
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),  // 两行文本之间的间距
                    Text(
                      '收藏',  // 第二行文本
                      style: TextStyle(
                        fontSize: 12.sp,  // 较小字号
                        color: HexColor('#999999')
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24.h,
            color: Colors.grey[300],
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                print('Tapped B');
                // 处理 B 区域的点击事件
              },
              child: Container(
                height: 50.h,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                  children: [
                    Text(
                      '0',  // 第一行文本
                      style: TextStyle(
                        fontSize: 17.sp,  // 较大字号
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),  // 两行文本之间的间距
                    Text(
                      '收藏',  // 第二行文本
                      style: TextStyle(
                        fontSize: 12.sp,  // 较小字号
                        color: Colors.grey,  // 灰色
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }


    //积分商城
    Widget _buildIntegralMall(){
      return Container(
        margin: EdgeInsets.only(top: 16.h,left: 16.w,right: 16.w),
        // padding: EdgeInsets.symmetric(horizontal: 16.w),
        width: double.infinity,
        height: 54.h,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/icon_score_bg.png'), // 使用本地资源图片
            fit: BoxFit.cover, // 控制图片的填充方式
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 20.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '积分',
                  style: TextStyle(
                    color: HexColor('#FFE6CF'),
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(),
            InkWell(
              onTap: () {
                print('Tapped 积分商城');
                // 处理积分商城点击事件
              },
              child: Container(
                width: 60.w,
                height: 28.h,
                alignment: Alignment.center,
                //颜色渐变
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      HexColor('#FFE6CF'),
                      HexColor('#FFD0A5'),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    '签到',
                    style: TextStyle(
                      color: HexColor('#433A34'),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              )
            ),
            SizedBox(width: 20.w),
          ],
        ),
      );
    }
   
   //我的订单
    Widget _buildOrder(){
      return Container(
        margin: EdgeInsets.only(top: 16.h),
        width: double.infinity,
        height: 100.h,
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 16.w),
                Text(
                  '我的订单',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    print('Tapped 查看全部');
                    // 处理查看全部点击事件
                  },
                  child: Row(
                    children: [
                      Text(
                        '查看全部',
                        style: TextStyle(
                          color: HexColor('#999999'),
                          fontSize: 12.sp,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: HexColor('#999999'),
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
              ],
            ),
            Expanded(
              child: Row(
                children: _orderTitles.asMap().keys.map((index) {
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        print('Tapped ${_orderTitles[index]}');
                        // 处理订单点击事件
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _orderIcons[index],
                            width: 24.w,
                            height: 24.h,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _orderTitles[index],
                            style: TextStyle(
                              color: HexColor('#333333'),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildServiceCell() {
      return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Padding(
            padding: EdgeInsets.fromLTRB(16.w,16.h, 0, 0),
            child: Text(
              '我的服务',
              style: TextStyle(color: HexColor('#222222'),fontSize: 15.sp,fontWeight: FontWeight.bold),
            ),
           ),
           SizedBox(height: 16.h),
           Row(
            children: [
              //加载本地图片
              Container(
                width: 24.w,
                height: 24.h,
                margin: EdgeInsets.only(left: 16.w,top: 12.h,bottom: 12.h),
                child: Image.asset('assets/images/icon_my_contract.png'),
              ),
              SizedBox(width: 8.w),
              Text('我的合同',style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp)),
              Spacer(),
              Icon(Icons.arrow_forward_ios,color: HexColor('#999999'),size: 16.sp),
              SizedBox(width: 16.w),

            ],
           ),
            Divider(height: 1.h,color: HexColor('#E5E5E5')),
           Row(
            children: [
              //加载本地图片
              Container(
                width: 24.w,
                height: 24.h,
                margin: EdgeInsets.only(left: 16.w,top: 12.h,bottom: 12.h),
                child: Image.asset('assets/images/icon_my_reserve.png'),
              ),
              SizedBox(width: 8.w),
              Text('我的预约',style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp)),
              Spacer(),
              Icon(Icons.arrow_forward_ios,color: HexColor('#999999'),size: 16.sp),
              SizedBox(width: 16.w),

            ],
           ),
            Divider(height: 1.h,color: HexColor('#E5E5E5')),
            Row(
              children: [
                //加载本地图片
                Container(
                  width: 24.w,
                  height: 24.h,
                  margin: EdgeInsets.only(left: 16.w,top: 12.h,bottom: 12.h),
                  child: Image.asset('assets/images/icon_my_comment.png'),
                ),
                SizedBox(width: 8.w),
                Text('我的评论',style: TextStyle(color: HexColor('#222222'),fontSize: 14.sp)),
                Spacer(),
                Icon(Icons.arrow_forward_ios,color: HexColor('#999999'),size: 16.sp),
                SizedBox(width: 16.w),
              ],
            )
         ],
      );
    }
  
}