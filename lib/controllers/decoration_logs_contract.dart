import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smarthome/controllers/decoration_logs_contract_detail.dart';
import 'package:flutter_smarthome/network/api_manager.dart';
import 'package:flutter_smarthome/utils/empty_state.dart';
import 'package:flutter_smarthome/utils/hex_color.dart';

class ContractListWidget extends StatefulWidget {
  final String customerProjectId;
  const ContractListWidget({super.key,required this.customerProjectId});

  @override
  State<ContractListWidget> createState() => _ContractListWidgetState();
}

class _ContractListWidgetState extends State<ContractListWidget> {
  List<Map<String, dynamic>> contractLists = []; // 合同信息
  @override
  void initState() {
    super.initState();
    _getContractListData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F8F8'),
      body: SingleChildScrollView(
        child: contractLists.length > 0 ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text('合同信息', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),
            ),
            SizedBox(height: 16.h,),
            ListView.builder(
              itemCount: contractLists.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final contract = contractLists[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GestureDetector(
                    onTap: () {
                      //跳转到合同详情页面
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DecorationLogsContractDetailWiget(contractId: contract['contractId'])));
                    },
                    child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16.h,),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text('${contract['contractTypeDisPlay']}' , style: TextStyle(fontSize: 14.sp, color: Colors.black),),
                                ),
                                SizedBox(height: 8.h,),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text('设计方案：${contract['packageName']}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                                ),
                                SizedBox(height: 8.h,),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text('合同编号：${contract['contractNo']}', style: TextStyle(fontSize: 12.sp, color: HexColor('#999999')),),
                                ),
                                SizedBox(height: 16.h,),
                              ],
                            ),
                      ),
                    ),
                  )
                );
              },
            )
          ],
        ) : Column(
          children: [
            SizedBox(height: 1/4 * MediaQuery.of(context).size.height,),
            EmptyStateWidget(onRefresh: _getContractListData,),
          ],
      ))
    );
  }


  
  void _getContractListData() async {
    final apiManager = ApiManager();
    final result = await apiManager.get(
      '/api/furnish/logs/contract/list',
      queryParameters: {
        'customerProjectId': widget.customerProjectId,
      },
    );
    if(result.length > 0 && mounted){
      setState(() {
        contractLists = List<Map<String, dynamic>>.from(result);
      });
    }
  }
}