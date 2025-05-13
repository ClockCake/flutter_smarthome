import 'dart:ffi'; // Note: dart:ffi might not be necessary unless used elsewhere

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart'; // Included in material.dart
import 'package:card_swiper/card_swiper.dart';
// import 'package:flutter_html/flutter_html.dart'; // Not used in the provided snippet
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/activity_detail.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/controllers/article_detail.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/controllers/bidden_list.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/controllers/case_detail.dart'; // Placeholder, ensure correct path
// import 'package:flutter_smarthome/controllers/designer_home.dart'; // Not used
import 'package:flutter_smarthome/controllers/quote_number.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/network/api_manager.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/utils/hex_color.dart'; // Placeholder, ensure correct path
// import 'package:flutter_smarthome/utils/navigation_controller.dart'; // Not used in this snippet
import 'package:flutter_smarthome/utils/network_image_helper.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/utils/network_state_helper.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/utils/video_page.dart'; // Placeholder, ensure correct path
import 'package:flutter_smarthome/view/webview_page.dart'; // Placeholder, ensure correct path
import 'package:gif_view/gif_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../view/auto_scroll_horizontal_list.dart'; // Placeholder, ensure correct path
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Used via NetworkImageHelper

// Assume RenovationType enum exists in quote_number.dart or elsewhere
// enum RenovationType { fullRenovation, renovation, softFurnishing }

class DiscoverRecommendWidget extends StatefulWidget {
  @override
  _DiscoverRecommendWidgetState createState() =>
      _DiscoverRecommendWidgetState();
}

class _DiscoverRecommendWidgetState extends State<DiscoverRecommendWidget> with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  int pageNum = 1;
  final int pageSize = 10;

  // Banner数据
  List <Map<String,dynamic>> imageList = [];
  final List<String> titleList = ['整装', '翻新', '软装',"局改","翻新"]; // Consider if last two are duplicates
  final List<String> localImages = [
    'assets/images/icon_home_renew.png',
    'assets/images/icon_home_renew.png', // Same as first?
    'assets/images/icon_home_soft.png',
    'assets/images/icon_quote_local.png',
    'assets/images/icon_quote_fix.png'
  ]; // Ensure these assets exist

  List <Map<String,dynamic>> currentBiddenList = []; // 当前招标列表
  List <Map<String,dynamic>> sucessBiddenList = []; // 招标成功列表
  int monthlyNumber = 0; // 本月招标数量
  String constructionCount = "0"; //在建工地数量
  List <Map<String,dynamic>> recommendList = []; // 推荐列表数据

  @override
  bool get wantKeepAlive => true;  // 保持页面状态

  @override
  void initState() {
    super.initState();
    // NavigationController.hideNavigationBar(); // Consider if this is needed globally or per-page
    _initNetworkListener();
    // Trigger initial data load via the refresher after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Check if the widget is still mounted before requesting refresh
       if(mounted) {
           _refreshController.requestRefresh();
       }
    });
  }

  void _initNetworkListener() {
    NetworkStateHelper.initNetworkListener(() {
      if (mounted) {
        // Network recovery, trigger refresh if list is empty or needed
         if (recommendList.isEmpty) {
             _refreshController.requestRefresh();
         }
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    NetworkStateHelper.dispose(); // Ensure NetworkStateHelper handles listener removal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // It's important to call super.build when using AutomaticKeepAliveClientMixin
    super.build(context);
    return Scaffold(
      // appBar: AppBar(title: Text("发现")), // Optional: Add AppBar if needed
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(), // Or ClassicHeader(), etc.
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              // Use a standard loading indicator
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败！点击重试！"); // Consider adding a retry onTap here
            } else if (mode == LoadStatus.canLoading) {
              body = Text("松手加载更多");
            } else if (mode == LoadStatus.noMore) { // Handle noMore state
               body = Text("没有更多数据了");
            }
            else {
              // Default to an empty container if mode is null or unexpected
              body = SizedBox.shrink();
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading, // Keep this assignment
        child: ListView( // Use ListView to allow scrolling of all content
          children: [
            SizedBox(height: 20.h),
            _buildBanner(),
            SizedBox(height: 24.h),
            _buildRecommendationSection(),
            // Conditionally build tender section only if needed
            if (monthlyNumber != 0 || currentBiddenList.isNotEmpty || sucessBiddenList.isNotEmpty)
              _buildTenderSection(),
            GestureDetector(
              onTap: () {
                // Ensure MyWebView exists and handles the URL correctly
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyWebView(url: "http://erf.gazo.net.cn:8087/webExtension/#/map",title: "在建工地",)));
              },
              child: _buildOnlineSiteSection(),
            ),
            // "Recommended Cases" Title
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.w, top: 24.h, bottom: 16.h), // Adjusted padding
              child: Text(
                '推荐案例',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            // The list of recommended cases/articles generated by _buildCaseList
            _buildCaseList(recommendList),
             // Add some padding at the bottom of the list
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // 构建轮播图
  Widget _buildBanner() {
    // Show a placeholder or loading indicator while imageList is empty
    if (imageList.isEmpty) {
      return Container(
         height: 250.h,
         alignment: Alignment.center,
        //  child: CupertinoActivityIndicator(), // Or other placeholder
         margin: EdgeInsets.symmetric(horizontal: (1 - 0.8) / 2 * MediaQuery.of(context).size.width), // Match viewportFraction padding
         decoration: BoxDecoration(
           color: Colors.grey[200], // Placeholder color
           borderRadius: BorderRadius.circular(12.0),
         ),
       );
    }
    return SizedBox(
      height: 250.h,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final item = imageList[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0), // 设置圆角
            // Use the helper for cached images and error/placeholder handling
            child: NetworkImageHelper().getCachedNetworkImage(
              imageUrl: item['imgUrl'] ?? "", // Handle null URL
              fit: BoxFit.cover,
            ),
          );
        },
        autoplay: true,
        itemCount: imageList.length,
        viewportFraction: 0.8, // Fraction of viewport each item occupies
        scale: 0.9, // Scale factor for adjacent items
        // pagination: SwiperPagination(), // Optional: Add pagination dots
        // control: SwiperControl(),    // Optional: Add next/prev arrows
        onTap: (index){
          // Ensure item and resourceId are not null before navigating
          final item = imageList[index];
          final resourceId = item['resourceId']?.toString();
          if (resourceId == null) return; // Don't navigate if ID is missing

          switch (item['resourceType']?.toString()) {
            case '0': //视频
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPage(videoId: resourceId)));
              break;
            case '1': //资讯
              Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailWidget(title: "", articleId: resourceId))); // Pass title if available
              break;
            case '2': //活动
               Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetailWidget(title: "", activityId: resourceId))); // Pass title if available
              break;
            default:
              print("Banner item tapped with unknown type: ${item['resourceType']}");
          }
        },
      ),
    );
  }

  // 装修计算器区域
  Widget _buildRecommendationSection() {
    return Container(
      // Use EdgeInsets.symmetric for horizontal padding
      margin: EdgeInsets.symmetric(horizontal: 16.w), // Use margin for spacing
      // height: 176.h, // Height might not be needed if content determines it
      decoration: BoxDecoration(
        color: Colors.white, // Set background for the whole section if needed
        borderRadius: BorderRadius.circular(8.r), // Optional: Add rounding
        boxShadow: [ // Optional: Add subtle shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column( // Use Column instead of Stack if overlap isn't strictly needed
        children: [
          // 装修计算器
          GestureDetector(
            onTap: () {
              // Ensure QuoteNumberPage and RenovationType exist
               Navigator.of(context).push(
                 MaterialPageRoute(
                   builder: (_) => QuoteNumberPage(
                     renovationType: RenovationType.fullRenovation
                   )
                 )
               );
            },
            child: Container(
              // color: HexColor('#F8F8F8'), // Color for this part
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row( // Use Row for layout
                children: [
                  Expanded( // Allow text column to take available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row( // Keep title and arrow together
                           children: [
                             Text('装修计算器',
                                 style: TextStyle(
                                     fontSize: 16.sp,
                                     fontWeight: FontWeight.bold)),
                             SizedBox(width: 10.w),
                             Icon(Icons.arrow_forward_ios,
                                 size: 14.sp, color: Colors.grey), // Smaller arrow
                           ],
                        ),
                        SizedBox(height: 4.h),
                        Text( // Example text, replace with dynamic data if available
                          '王女士・13室1厅1厨1卫・120m²・22w', // Use '㎡' if possible
                          style: TextStyle(
                              fontSize: 12.sp, color: HexColor('#999999')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Calculator GIF
                  GifView.asset(
                    'assets/images/calculator.gif', // Ensure asset exists
                    height: 60.r, // Use responsive units
                    width: 60.r,
                    frameRate: 30, // Default is 15 FPS
                  ),
                ],
              ),
            ),
          ),
 
          // 功能按钮行
          Container(
            // color: Colors.white, // Background is likely white from parent
            padding: EdgeInsets.symmetric(vertical: 12.h), // Padding around buttons
            child: Row(
              // Use map and spread operator for cleaner generation
              children: List.generate(titleList.length, (i) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Map index to RenovationType or action
                      RenovationType? type;
                      switch (i) {
                        case 0: type = RenovationType.fullRenovation; break;
                        case 1: type = RenovationType.renovation; break;
                        case 2: type = RenovationType.softFurnishing; break;
                        // Add cases for 3 and 4 if they map to QuoteNumberPage
                        case 3: // Placeholder for "局改"
                        case 4: // Placeholder for "翻新" (duplicate?)
                          showToast('该功能暂未开放'); // Keep toast for unimplemented features
                          return; // Exit onTap
                        default:
                          return; // Exit if index is out of bounds
                      }
                      // Navigate if a type was determined
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => QuoteNumberPage(renovationType: type!))
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          localImages[i],
                          width: 40.r, // Use responsive units
                          height: 40.r,
                          // Optional: Add error builder for images
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 40.r),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          titleList[i],
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }


  // 构建招标区域
  Widget _buildTenderSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        margin: EdgeInsets.only(top: 24.h), // Spacing from section above
        // height: 180.h, // Let content determine height or set minHeight
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: HexColor('#F8F8F8'), // Background for the tender section
        ),
        child: Column(
          children: [
            _buildTenderTitle(),
            // Only build scroll list if there's data
            if (currentBiddenList.isNotEmpty)
               _buildAutoScrollList(),
            // Only build marquee if there's data
            if (sucessBiddenList.isNotEmpty)
               _buildInfiniteMarquee(),
             // Add padding at the bottom if needed
             SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  // 构建招标标题
  Widget _buildTenderTitle() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h), // Adjusted padding
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4.r), // Slightly smaller radius
            ),
            child: Text(
              '招标',
              style: TextStyle(fontSize: 11.sp, color: Colors.white),
            ),
          ),
          Spacer(), // Pushes the count to the right
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12.sp, color: Colors.black), // Default style
              children: [
                TextSpan(text: '本月招标 '),
                TextSpan(
                  text: '$monthlyNumber', // Ensure monthlyNumber is updated
                  style: TextStyle(
                    color: HexColor('#FFA555'), // Use theme color if available
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' 家'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建自动滚动列表 (当前招标)
  Widget _buildAutoScrollList() {
    // Ensure currentBiddenList is not empty before building
    if (currentBiddenList.isEmpty) return SizedBox.shrink();

    return AutoScrollHorizontalList(
      itemCount: currentBiddenList.length,
      scrollSpeed: 100.0, // Adjust speed as needed
      scrollInterval: 100, // Adjust interval
      height: 70.h, // Adjusted height
      itemWidth: 150.w, // Width of each item
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      backgroundColor: HexColor('#F8F8F8'), // Match parent background
      itemBuilder: (context, index) {
        final item = currentBiddenList[index];
        // Extract data safely with null checks
        final region = item['region'] ?? '';
        final name = item['name'] ?? '';
        final decorateType = item['decorateType'] ?? '装修'; // Default value

        return GestureDetector(
          onTap: () {
             // Ensure BiddenListWidget exists
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BiddenListWidget()),
            );
          },
          child: Container(
            margin: EdgeInsets.only(right: 8.w), // Add spacing between items
            padding: EdgeInsets.all(10.h), // Internal padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment: CrossAxisAlignment.start, // Align text start
              children: [
                Text(
                  '${region}${name} 发起', // Combine strings
                  style: TextStyle(color: HexColor('#222222'), fontSize: 11.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h), // Spacing between lines
                Text(
                  '$decorateType招标',
                  style: TextStyle(color: HexColor('#999999'), fontSize: 11.sp),
                   maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 构建无限滚动通知 (招标成功)
  Widget _buildInfiniteMarquee() {
     // Ensure sucessBiddenList is not empty
     if (sucessBiddenList.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0), // Margins
      height: 30.h, // Fixed height for the marquee container
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: Colors.white,
      ),
      child: InfiniteMarquee(
            // Use a reasonable duration for smooth scrolling
            frequency: const Duration(milliseconds: 50),
            scrollDirection: Axis.vertical, // Vertical scroll
            // itemCount: sucessBiddenList.length, // Set itemCount
            itemBuilder: (BuildContext context, int index) {
              // Use modulo with the list length to access items correctly in an infinite loop
              final item = sucessBiddenList[index % sucessBiddenList.length];
              // Safe data extraction
              final city = item['city'] ?? '';
              final region = item['region'] ?? '';
              final name = item['name'] ?? '';
              final text = '$city$region${name} 招标成功'; // Construct text

              return GestureDetector(
                onTap: () {
                   // Ensure BiddenListWidget exists
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BiddenListWidget()),
                    );
                },
                child: Container(
                    height: 30.h, // Match container height
                    alignment: Alignment.centerLeft, // Align content
                    padding: EdgeInsets.symmetric(horizontal: 12.w), // Horizontal padding
                    // No margin needed inside here
                    // No decoration needed here (parent has it)
                    child: Row(
                      children: [
                        Image.asset('assets/images/icon_home_trumpet.png', // Ensure asset exists
                            width: 12.r, height: 12.r),
                        SizedBox(width: 8.w),
                        Expanded( // Allow text to take space and potentially wrap/ellipsis
                           child: Text(
                             text,
                             style: TextStyle(fontSize: 12.sp, color: HexColor('#666666')),
                             overflow: TextOverflow.ellipsis, // Handle long text
                             maxLines: 1,
                           ),
                        ),
                        // Removed the duplicate "招标成功" text here as it's in the main text
                        // If needed specifically:
                        // Text(
                        //   '招标成功',
                        //   style: TextStyle(fontSize: 12.sp, color: HexColor('#FFA555')),
                        // ),
                        // Spacer(), // Removed spacer if not needed
                        Icon(Icons.arrow_forward_ios, size: 12.sp, color: HexColor('#CCCCCC')), // Lighter arrow
                      ],
                    ),
                  ),
              );
            },
          ),
    );
  }


  // 构建在线工地区域
  Widget _buildOnlineSiteSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0), // Padding around the section
      child: Container( // Use Container for decoration and clipping
        height: 80.h,
        clipBehavior: Clip.antiAlias, // Clip the image to rounded corners
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          // The map image will be the background
        ),
        child: Stack( // Stack to overlay content on the map image
          children: [
            // Background map image
            Positioned.fill(
              child: Image.asset(
                'assets/images/icon_home_map.png', // Ensure asset exists
                fit: BoxFit.cover, // Cover the container area
                // Optional: Add error handling for the image
                 errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
              ),
            ),
             // Add a semi-transparent overlay for better text readability (optional)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                   gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.6, 1.0]
                   )
                ),
              ),
            ),
            // Content Row
            Padding( // Add padding for the content inside the stack
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
                children: [
                  Image.asset( // Use Image.asset directly
                      'assets/images/icon_home_house.png', // Ensure asset exists
                      width: 30.r, // Adjust size
                      height: 30.r,
                      color: Colors.white, // Make icon white for better contrast
                  ),
                  SizedBox(width: 16.w),
                  // Column for the text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('在线工地',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)), // White text
                      SizedBox(height: 4.h),
                      Text('已有 ${constructionCount} 个工地正在施工', // Ensure constructionCount is updated
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9))), // Slightly transparent white
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   // 构建推荐列表 (包含案例和资讯)
  Widget _buildCaseList(List<Map<String,dynamic>> listData) {
     // If the list is empty after loading, show a message or placeholder
     if (listData.isEmpty && !_refreshController.isRefresh && !_refreshController.isLoading) {
        return Container(
            padding: EdgeInsets.symmetric(vertical: 50.h),
            alignment: Alignment.center,
            child: Text("暂无推荐内容", style: TextStyle(color: Colors.grey)),
        );
     }

    // Use ListView.builder for performance with potentially long lists
    // Since this is inside another ListView, configure it correctly
    return ListView.builder(
      shrinkWrap: true, // Important inside another scrollable
      physics: NeverScrollableScrollPhysics(), // Disable its own scrolling
      itemCount: listData.length,
      itemBuilder: (context, index) {
        final item = listData[index];
        // Safely parse resourceType, default to an unknown type (e.g., -1) if null/invalid
        final resourceType = int.tryParse(item['resourceType']?.toString() ?? '-1') ?? -1;

        Widget cell;
        switch (resourceType) {
          case 4: // 资讯 (Article)
            final articleData = item['gazoHuiArticle'];
            // Check if article data is valid Map before building cell
            if (articleData is Map<String, dynamic>) {
               cell = GestureDetector(
                onTap: () {
                  // Safe navigation with ID check
                  final articleId = articleData['id']?.toString();
                  if (articleId != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailWidget(title: articleData['resourceTitle'] ?? '', articleId: articleId)));
                  }
                },
                child: _buildArticleCell(articleData),
              );
            } else {
               cell = const SizedBox.shrink(); // Skip if data is invalid
            }
            break;
          case 1: // 案例 (Case)
            final caseData = item['gazoHuiDesignerCase'];
             // Check if case data is valid Map before building cell
            if (caseData is Map<String, dynamic>) {
              cell = GestureDetector(
                onTap: () {
                   // Safe navigation with ID check
                   final caseId = caseData['id']?.toString();
                   if (caseId != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CaseDetailWidget(title: caseData['caseTitle'] ?? '', caseId: caseId)));
                   }
                },
                child: _buildCaseCell(caseData),
              );
            } else {
               cell = const SizedBox.shrink(); // Skip if data is invalid
            }
            break;
          default:
            // Log unknown type for debugging, return empty space
            print("Unknown resource type in recommend list: $resourceType at index $index");
            cell = const SizedBox.shrink();
        }
        // Add padding/divider between items if needed
        return Column(
          children: [
            cell,
            // Optional: Add divider between items, but not after the last one
            if (index < listData.length - 1)
              Divider(height: 1.h, thickness: 1.h, color: HexColor('#F0F0F0'), indent: 16.w, endIndent: 16.w),
          ],
        );
     },
    );
  }

  // 构建资讯 Cell
  Widget _buildArticleCell(Map<String,dynamic> item) {
     // Safe data extraction
     final title = item['resourceTitle'] ?? '资讯标题';
     final imageUrl = item['mainPic'] ?? '';
     final intro = item['resourceIntro'] ?? '';

     return Container(
       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
       color: Colors.white, // Ensure background color if needed
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Title
           Text(
             title,
             style: TextStyle(fontSize: 15.sp, color: HexColor('#222222'),fontWeight: FontWeight.bold),
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
           ),
           SizedBox(height: 8.h),
           // Image
           if (imageUrl.isNotEmpty) // Only show image container if URL exists
             Container(
               width: double.infinity,
               height: 150.h, // Adjust height as needed
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(6.r),
                 child: NetworkImageHelper().getCachedNetworkImage(
                     imageUrl: imageUrl,
                     fit: BoxFit.cover
                 ),
               ),
             ),
           SizedBox(height: 8.h),
           // Intro Text
           if(intro.isNotEmpty) // Only show intro if it exists
              Text(
                 intro,
                 style: TextStyle(fontSize: 13.sp,color: HexColor('#666666')),
                 maxLines: 3, // Limit lines for intro
                 overflow: TextOverflow.ellipsis,
              ),
           // Removed Divider from here, handled in _buildCaseList builder
         ],
       ),
     );
  }

 // 构建案例 Cell
  Widget _buildCaseCell(Map<String,dynamic> item) {
     // Safe data extraction
     final title = item['caseTitle'] ?? '案例标题';
     final intro = item['caseIntro'] ?? '';
     // Ensure 'caseMainPic' is a List and handle null/empty case
     final pics = (item['caseMainPic'] is List) ? List<String>.from(item['caseMainPic'].map((e) => e.toString())) : <String>[];

    return Container(
       padding: EdgeInsets.only(top: 16.h, bottom: 16.h), // Vertical padding
       color: Colors.white,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Header Row (Tag + Title)
           Padding(
             padding: EdgeInsets.symmetric(horizontal: 16.w),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 // Tag
                 Container(
                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                   decoration: BoxDecoration(
                     color: Colors.black,
                     borderRadius: BorderRadius.circular(10.r), // Match tender tag radius
                   ),
                   child: Text(
                     '案例',
                     style: TextStyle(fontSize: 11.sp, color: Colors.white),
                   ),
                 ),
                 SizedBox(width: 8.w),
                 // Title (Expanded to take available space)
                 Expanded(
                   child: Text(
                     title,
                     style: TextStyle(fontSize: 15.sp, color: HexColor('#222222'), fontWeight: FontWeight.bold),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             ),
           ),
           SizedBox(height: 6.h),
           // Intro Text
           if(intro.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  intro,
                  style: TextStyle(fontSize: 13.sp, color: HexColor('#666666')),
                   maxLines: 2, // Limit lines
                   overflow: TextOverflow.ellipsis,
                ),
              ),
           SizedBox(height: 12.h),
           // Horizontal Image List (only if pics exist)
           if (pics.isNotEmpty)
             SizedBox(
               height: 100.h, // Height of the horizontal list
               child: ListView.builder(
                 scrollDirection: Axis.horizontal,
                 itemCount: pics.length,
                 // Add padding to the ListView itself for start/end spacing
                 padding: EdgeInsets.symmetric(horizontal: 16.w),
                 itemBuilder: (context, index) {
                   return Container(
                     // Add right margin for spacing between images
                     margin: EdgeInsets.only(right: index == pics.length - 1 ? 0 : 8.w),
                     width: 120.w, // Width of each image item
                     child: ClipRRect(
                       borderRadius: BorderRadius.circular(6.r),
                       child: NetworkImageHelper().getCachedNetworkImage(
                         imageUrl: pics[index], // Already checked for list type
                         fit: BoxFit.cover,
                       ),
                     ),
                   );
                 },
               ),
             ),
           // Removed Divider and bottom SizedBox, handled in _buildCaseList builder
         ],
       ),
     );
  }

  // --- 数据获取方法 ---

  Future<void> getBannerData() async {
    try {
      final response = await ApiManager().get('/api/home/banner', queryParameters: {"status": "1"});
      // Check mounted before setState
      if (mounted && response != null) {
        // Ensure response is a list before casting
        if (response is List) {
            setState(() {
              imageList = List<Map<String, dynamic>>.from(response.map((e) => e as Map<String, dynamic>));
            });
        } else {
             print('获取轮播图数据失败：Expected List but got ${response.runtimeType}');
             imageList = []; // Clear list on invalid response
        }
      }
    } catch (e) {
      print('获取轮播图数据失败：$e');
      if(mounted) {
        setState(() { imageList = []; }); // Clear list on error
      }
    }
  }

  Future<void> getBiddenData() async {
    try {
      final response = await ApiManager().get('/api/home/tender');
       // Check mounted before setState
      if (mounted && response != null && response is Map<String, dynamic>) {
        setState(() {
          // Safely extract lists and int, provide defaults
          currentBiddenList = (response['latest'] is List)
              ? List<Map<String, dynamic>>.from(response['latest'].map((e) => e as Map<String, dynamic>))
              : [];
          sucessBiddenList = (response['succData'] is List)
              ? List<Map<String, dynamic>>.from(response['succData'].map((e) => e as Map<String, dynamic>))
              : [];
          monthlyNumber = response['monthlyNumber'] as int? ?? 0;
        });
      } else {
           print('获取招标数据失败：Invalid response format');
           if(mounted) { // Reset on invalid format
               setState(() {
                   currentBiddenList = [];
                   sucessBiddenList = [];
                   monthlyNumber = 0;
               });
           }
      }
    } catch (e) {
      print('获取招标数据失败：$e');
      if(mounted) { // Reset on error
          setState(() {
              currentBiddenList = [];
              sucessBiddenList = [];
              monthlyNumber = 0;
          });
      }
    }
  }

  Future<void> getOnlineSiteData() async {
    try {
      final response = await ApiManager().get('/api/construction/count');
       // Check mounted before setState
      if (mounted && response != null && response is Map<String, dynamic>) {
        setState(() {
          // Safely extract count, convert to String, provide default
          constructionCount = response['count']?.toString() ?? "0";
        });
      } else {
          print('获取在线工地数据失败：Invalid response format');
           if(mounted) { setState(() { constructionCount = "0"; }); } // Reset on invalid format
      }
    } catch (e) {
      print('获取在线工地数据失败：$e');
      if(mounted) { setState(() { constructionCount = "0"; }); } // Reset on error
    }
  }


  // ****** 修改后的 getRecommendData ******
  // Handles both initial/refresh load and load more
  Future<void> getRecommendData({bool isRefresh = false}) async {
    try {
      // If refreshing, reset page number
      if (isRefresh) {
         pageNum = 1;
      }

      final response = await ApiManager().get('/api/home/recommend/case',
        queryParameters: {
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );

      // ---- Basic validation of response structure ----
      if (response == null || response is! Map || response['rows'] == null || response['pageTotal'] == null || response['rows'] is! List) {
        print('获取推荐数据失败：Invalid API response structure or type');
        throw Exception('Invalid API response structure'); // Throw exception to be caught below
      }

      // ---- Process valid response ----
      final List<Map<String, dynamic>> newItems = List<Map<String, dynamic>>.from(response['rows'].map((e) => e as Map<String, dynamic>));
      final int pageTotal = response['pageTotal'] as int? ?? 0; // Safely get pageTotal

      // ---- Check mounted before updating state ----
      if (mounted) {
        setState(() {
          if (isRefresh) {
            recommendList.clear(); // Clear existing list data on refresh
          }
          recommendList.addAll(newItems); // Add new items to the list
        });

         // ---- Update RefreshController state AFTER setState ----
        if (isRefresh) {
           _refreshController.refreshCompleted();
           // IMPORTANT: Reset load status after successful refresh,
           // allowing "load more" to function again if new data was added.
           // Also handles the case where total pages might have changed.
           _refreshController.resetNoData();
        }

        // Check if this was the last page or if no items were fetched
        if (newItems.isEmpty || pageNum >= pageTotal) {
           _refreshController.loadNoData(); // Signify no more data available
        } else {
           _refreshController.loadComplete(); // Signify loading is complete for this page
        }
      }

    } catch (e) {
      print('获取推荐数据失败：$e');
      // ---- Handle errors and update controller state ----
       if (mounted) { // Check mounted before controller interaction
           if (isRefresh) {
              _refreshController.refreshFailed();
           } else {
              _refreshController.loadFailed();
               // Decrement pageNum if load failed so a retry attempt loads the same page again
               // Only decrement if it's not the first page that failed.
              if(pageNum > 1) {
                  pageNum--;
              }
           }
       }
    }
  }

  // ****** 修改后的 _onRefresh ******
  void _onRefresh() async {
    // Reset load state *before* fetching new data. Critical for allowing
    // loadMore to work again after reaching the end and then refreshing.
    _refreshController.resetNoData();

    // Fetch all data concurrently for refresh efficiency
    try {
       // isRefresh: true is passed to getRecommendData now
       await Future.wait([
        getBannerData(),
        getBiddenData(),
        getOnlineSiteData(),
        getRecommendData(isRefresh: true), // Fetch first page of recommendations
      ]);
      // State (refreshCompleted/Failed) is handled within getRecommendData
    } catch (e) {
        // If Future.wait itself fails (e.g., one of the futures throws an unhandled error)
        print('Combined refresh failed: $e');
        if(mounted) {
             _refreshController.refreshFailed(); // Indicate overall refresh failure
        }
    }
  }

  // ****** 修改后的 _onLoading ******
  void _onLoading() async {
    // 1. Increment page number
    pageNum++;
    // 2. Fetch data for the new page number
    //    Let getRecommendData handle the RefreshController state (loadComplete/loadNoData/loadFailed)
    await getRecommendData();

    // NO RefreshController state logic needed here anymore.
  }

}


