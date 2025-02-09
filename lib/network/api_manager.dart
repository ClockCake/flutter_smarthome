import 'package:dio/dio.dart';
import 'package:flutter_smarthome/controllers/login_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart'; 
import 'package:dio/io.dart';
import '../utils/user_manager.dart';
import '../models/user_model.dart';
import '../utils/global.dart';  
import 'dart:io';


class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  late Dio _dio;
  final String _baseUrl = 'http://192.168.10.20:6380';
  //'http://erf.gazo.net.cn:6380';
  //'http://192.168.10.20:6380';
  // 用来标记是否正在刷新
  bool _isRefreshing = false;
  // 存放需要重试的请求队列
  final List<RequestOptions> _penddingRequests = [];


  ApiManager._internal() {
    _initDio();
  }

  // 拦截器
  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      validateStatus: (status) => true,
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _handleRequest,
      onResponse: _handleResponse,
      onError: _handleError,
    ));
  }


  //设置代理，并初始化 Dio 和重新设置拦截器
  void setProxy(String proxyAddress, String proxyPort) {
    print('Setting proxy to $proxyAddress:$proxyPort'); // 调试输出
    try {
      // 重新初始化 Dio
      _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 3000),
          validateStatus: (status) => true,
        ),
      );

      // 设置代理
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.findProxy = (uri) {
          return 'PROXY $proxyAddress:$proxyPort';
        };
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        print('Proxy configured in HttpClient'); // 调试输出
        return client;
      };

      // 重新添加拦截器
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: _handleRequest,
        onResponse: _handleResponse,
        onError: _handleError,
      ));

      print('Proxy has been set successfully'); // 调试输出
    } catch (e) {
      print('Error setting proxy: $e'); // 调试输出
    }
  }

  void _handleRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final UserModel? user = UserManager.instance.user;
    options.headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'TerminalId': 'ce5c98bea83e4d3289f3fc5f25c445a6',
      "Authorization": user?.accessToken ?? '',
    };

    _logRequest(options);
    EasyLoading.show(status: '加载中...');
    handler.next(options);
  }

  void _handleResponse(Response response, ResponseInterceptorHandler handler) { 
      _logResponse(response);
      EasyLoading.dismiss();

      // 处理所有响应
      if (response.data is Map<String, dynamic>) {
        final code = response.data['code'];
        final msg = response.data['msg'];
        if (code == 200) {
          return handler.next(response);
        }
        // 处理401认证错误
        if (code == 401) {
          _handleAuthError(msg);
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: msg ?? '认证失败',
            ),
          );
        }
    
      // 处理500错误
        if (code == 500) {
          showToast(
            msg ?? '服务器错误',
            position: ToastPosition.bottom,
          );
          // return handler.resolve(
          //   Response(
          //     requestOptions: response.requestOptions,
          //     data: null,  // 返回空数据
          //   )
          // );
        }

      }

  
    }

  /// ===== 核心：在 onError 时处理 401 =====
  void _handleError(DioException err, ErrorInterceptorHandler handler) async {
    _logError(err);
    EasyLoading.dismiss();

    // 如果是 401 并且不是在刷新接口本身，就执行刷新流程
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('refresh')) {
      // 判断是否正在刷新
      if (!_isRefreshing) {
        _isRefreshing = true;
        // 把当前的请求加入队列
        _penddingRequests.add(err.requestOptions);

        try {
          // 调用刷新token的方法
          await _refreshToken();

          // 刷新成功以后，依次重试队列中的请求
          for (var request in _penddingRequests) {
            // 重新设置新的 accessToken
            request.headers["Authorization"] = UserManager.instance.user?.accessToken ?? "";
            // 注意：这里要使用 dio 再次发起请求，不要直接 handler.resolve
            final response = await _dio.fetch(request);
            // 这里就相当于把之前的请求成功结果返回给之前的调用处
            handler.resolve(response);
          }
        } catch (e) {
          // 刷新失败：跳转登录
          _handleAuthError("登录已过期，请重新登录");
          handler.next(err); 
        } finally {
          // 清空队列、关闭刷新状态
          _penddingRequests.clear();
          _isRefreshing = false;
        }
      } else {
        // 已经在刷新，先把请求加入队列，不要立刻抛错
        _penddingRequests.add(err.requestOptions);
      }
    } else {
      // 其他错误，正常处理
      String errorMsg = _getErrorMessage(err);
      showToast(errorMsg, position: ToastPosition.bottom);
      handler.next(err);
    }
  }

    /// ===== 刷新 token 的方法 =====
  Future<void> _refreshToken() async {
    // 这里从你项目的 UserManager 里拿到 refreshToken
    final oldRefreshToken = UserManager.instance.user?.refreshToken;
    if (oldRefreshToken == null) {
      throw Exception("无 refreshToken, 无法刷新");
    }
    
    try {
      // 发起刷新接口
      final response = await _dio.post(
        "/api/login/refresh-token",
        options: Options(headers: {
          'Authorization': oldRefreshToken,
        }),
      );

      // 判断是否成功
      if (response.data["code"] == 200) {
        final newAccessToken = response.data["data"]["accessToken"];
        final newRefreshToken = response.data["data"]["refreshToken"];
        // 重新保存到 UserManager
        UserManager.instance.user?.accessToken = newAccessToken;
        UserManager.instance.user?.refreshToken = newRefreshToken;
      } else {
        throw Exception("刷新失败");
      }
    } catch (e) {
      rethrow;
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请稍后重试';
      case DioExceptionType.receiveTimeout:
        return '接收超时，请稍后重试';
      case DioExceptionType.badResponse:
        if (error.response?.data is Map) {
          return error.response?.data['msg'] ?? '请求失败';
        }
        return '服务器响应错误';
      case DioExceptionType.cancel:
        return '请求已取消';
      default:
        return '请求失败，请检查网络';
    }
  }

  void _handleAuthError(String? msg) {
    UserManager.instance.clearUser();
    showToast(
      msg ?? '登录已过期，请重新登录',
      position: ToastPosition.bottom,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      final context = _getGlobalContext();
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    });
  }

  void _logRequest(RequestOptions options) {
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
  }

  void _logResponse(Response response) {
    print('┌────── Response ──────');
    print('│ Status Code: ${response.statusCode}');
    print('│ Data: ${response.data}');
    print('└─────────────────────');
  }

  void _logError(DioException error) {
    print('┌────── Error ──────');
    print('│ Type: ${error.type}');
    print('│ Message: ${error.message}');
    print('│ Error: ${error.error}');
    if (error.response != null) {
      print('│ Response: ${error.response?.data}');
    }
    print('└───────────────────');
  }

  BuildContext? _getGlobalContext() => navigatorKey.currentContext;

  // 请求方法保持不变，但错误处理更统一
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data['data'];
    } catch (e) {
      rethrow;
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
       rethrow;  
    }
  }

  Future<dynamic> postWithList(String path, {List<Map<String, dynamic>>? data}) async {
    try {
      Response response = await _dio.post(
        path,
        data: data,
      );
      return response.data['data'];

    } catch (e) {
       rethrow;  
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
      rethrow;  

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
      rethrow;  

    }
  }

  Future<dynamic> deleteWithParameters(String path, {Map<String, dynamic>? data}) async {
    try {
      Response response = await _dio.delete(
        path,
        queryParameters: data,
      );
      return response.data['data'];

    } catch (e) {
      rethrow;  

    }
  }
  /// DELETE 请求 传参数组
  Future<dynamic> deleteWithList(String path, {List<dynamic>? data}) async {
      try {
        Response response = await _dio.delete(
          path,
          data: data,
        );
        return response.data['data'];
      } catch (e) {
        rethrow;
      }
  }

  Future<dynamic> uploadImage(
    String path,
    String filePath, {
    String? fileName,
    String formName = 'file',
  }) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: fileName ?? filePath.split('/').last,
      );
      
      final formData = FormData.fromMap({formName: file});

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      
      return response.data['data'];
    } catch (e) {
      print('图片上传失败: $e');
      rethrow;  // 改为抛出错误，让拦截器统一处理
    }
  }
}