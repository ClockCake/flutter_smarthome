import 'package:dio/dio.dart';
import 'package:flutter_smarthome/controllers/login_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import '../utils/user_manager.dart';
import '../models/user_model.dart';
import '../utils/global.dart';  

/// ApiManager 是一个单例类，用于管理网络请求
class ApiManager {
  // 单例模式
  static final ApiManager _instance = ApiManager._internal();

  factory ApiManager() {
    return _instance;
  }

  ApiManager._internal() {
    // 初始化 Dio
    UserModel? user = UserManager.instance.user;

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl, // 基础请求地址
        connectTimeout: Duration(milliseconds: 5000), // 连接超时时间（毫秒）
        receiveTimeout: Duration(milliseconds: 3000), // 响应超时时间（毫秒）
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 在每次请求时动态获取最新的 token
        final UserModel? user = UserManager.instance.user;
        options.headers = {
          'Content-Type': 'application/json; charset=UTF-8',
          'TerminalId': 'ce5c98bea83e4d3289f3fc5f25c445a6',
          "Authorization": user?.accessToken ?? '',
        };

        // 打印请求信息
        print('┌────── Request ──────');
        print('│ URL: ${options.baseUrl}${options.path}');
        print('│ Method: ${options.method}');
        print('│ Headers: ${options.headers}');
        if (options.queryParameters.isNotEmpty) {
          print('│ Query Parameters: ${options.queryParameters}');
        }
        if (options.data != null) {
          print('│ Body: ${options.data}');
        }
        print('└────────────────────');

        // 请求前显示加载框
        EasyLoading.show(status: '加载中...');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 打印响应信息
        print('┌────── Response ──────');
        print('│ Status Code: ${response.statusCode}');
        print('│ Data: ${response.data}');
        print('└─────────────────────');

        // 请求完成后隐藏加载框
        EasyLoading.dismiss();

        // 检查响应体中的 code 字段
        if (response.data is Map<String, dynamic>) {
          final code = response.data['code'];
          // token 过期重新登录的逻辑
          if (code == 401) {
            // 清除本地用户数据
            UserManager.instance.clearUser();
            
            showToast(
              response.data['msg'] ?? '登录已过期，请重新登录',
              position: ToastPosition.bottom,
            );

            // 延迟执行跳转，确保 toast 消息能够显示
            Future.delayed(Duration(milliseconds: 1500), () {
              // 获取全局 context
              final context = _getGlobalContext();
              if (context != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            });

            // 返回错误给业务层
            final error = DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: '登录已过期',
            );
            return handler.reject(error);
          }

          //成功返回数据
          if (code == 200) {
            return handler.next(response);
          } else {
            // 获取错误信息，假设错误信息在 msg 字段中
            final errorMsg = response.data['msg'] ?? '请求失败: code=$code';
            showToast(
              errorMsg,
              position: ToastPosition.bottom,
            );
            // 创建一个自定义错误
            final error = DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: errorMsg,
            );
            return handler.reject(error);
          }
        }
        // 如果响应体不是预期的格式，返回错误
        showToast(
          '响应格式错误',
          position: ToastPosition.bottom,
        );
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        // 打印错误信息
        print('┌────── Error ──────');
        print('│ Type: ${error.type}');
        print('│ Message: ${error.message}');
        print('│ Error: ${error.error}');
        if (error.response != null) {
          print('│ Response: ${error.response?.data}');
        }
        print('└───────────────────');

        // 请求错误时隐藏加载框并显示错误提示
        EasyLoading.dismiss();
        String errorMsg = '';
        if (error.type == DioExceptionType.connectionTimeout) {
          errorMsg = '连接超时，请稍后重试';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          errorMsg = '接收超时，请稍后重试';
        } else if (error.type == DioExceptionType.badResponse) {
          // 如果是业务逻辑错误，错误信息已经在 onResponse 中处理
          errorMsg = error.error?.toString() ?? '服务器异常';
        } else {
          errorMsg = '请求失败，请检查网络';
        }
        showToast(
          errorMsg,
          position: ToastPosition.bottom,
        );
        return handler.next(error);
      },
    ));
  }

  late Dio _dio;
  final String _baseUrl = 'http://erf.gazo.net.cn:6380'; // 替换为你的API基础地址

  /// GET 请求
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      // 只返回数据部分，假设数据在 data 字段中
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  /// POST 请求
  /// [path] 请求路径
  /// [data] 请求体
  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    try {
      Response response = await _dio.post(
        path,
        data: data,
      );
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  /// PUT 请求
  Future<dynamic> put(String path, {Map<String, dynamic>? data}) async {
    try {
      Response response = await _dio.put(
        path,
        data: data,
      );
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  /// DELETE 请求
  Future<dynamic> delete(String path, {Map<String, dynamic>? data}) async {
    try {
      Response response = await _dio.delete(
        path,
        data: data,
      );
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  /// 上传单个图片
  /// [path] 请求路径
  /// [filePath] 图片文件的本地路径
  /// [fileName] 上传的文件名称，可选
  /// [formName] 表单中的字段名称，默认为 'file'
  Future<dynamic> uploadImage(
    String path, 
    String filePath, {
    String? fileName,
    String formName = 'file',
  }) async {
    try {
      // 创建 MultipartFile
      final file = await MultipartFile.fromFile(
        filePath,
        filename: fileName ?? filePath.split('/').last,
      );
      
      // 创建 FormData
      final formData = FormData.fromMap({
        formName: file,
      });

      // 发送请求
      Response response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      return response.data['data'];
    } catch (e) {
      print('图片上传失败: $e');
      return null;
    }
  }
    // 获取全局 context 的方法
  BuildContext? _getGlobalContext() {
    return navigatorKey.currentContext;  
  }
}