// 文件: lib/utils/network_image_helper.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageHelper {
  // 单例模式
  static final NetworkImageHelper _instance = NetworkImageHelper._internal();
  factory NetworkImageHelper() => _instance;
  NetworkImageHelper._internal();

  // 自定义 HttpClient
  HttpClient get _customHttpClient {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  // 获取带证书豁免的 CachedNetworkImage
  Widget getCachedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      // httpClient: _customHttpClient,
      placeholder: placeholder ?? _defaultPlaceholder,
      errorWidget: errorWidget ?? _defaultErrorWidget,
    );
  }

  // 获取带证书豁免的 Image.network
  Widget getNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      headers: const {
        "Access-Control-Allow-Origin": "*",
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _defaultPlaceholder(context, imageUrl);
      },
      errorBuilder: (context, error, stackTrace) {
        return _defaultErrorWidget(context, imageUrl, error);
      },
    );
  }

  // 默认占位组件
  Widget _defaultPlaceholder(BuildContext context, String url) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // 默认错误组件
  Widget _defaultErrorWidget(BuildContext context, String url, dynamic error) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }
}