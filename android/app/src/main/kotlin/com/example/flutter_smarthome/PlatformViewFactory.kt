package com.jiyoujiaju.jijiahui

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.LayoutInflater
import android.widget.FrameLayout
import android.widget.TextView
import android.view.Gravity
import android.view.ViewGroup
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

// ViewFactory 类
class NativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d("NativeViewFactory", "Creating view with id: $viewId, args: $args")
        val creationParams = args as? Map<String?, Any?>
        return NativeView(context, viewId, creationParams)
    }
}

class NativeView(
    private val context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?
) : PlatformView {
    private val smartHomeView: SmartHomeView

    init {
        Log.d("NativeView", "Initializing NativeView with params: $creationParams")

        // 创建 SmartHomeView
        smartHomeView = SmartHomeView(context).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
    }

    override fun getView(): View = smartHomeView

    override fun dispose() {
        Log.d("NativeView", "dispose called")
        smartHomeView.cleanup()
    }
}


// Plugin 主类
class FlutterSmartHomePlugin : FlutterPlugin, ActivityAware {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("FlutterSmartHomePlugin", "onAttachedToEngine")
        binding.platformViewRegistry.registerViewFactory(
            "native_android_smartlife",
            NativeViewFactory()
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("FlutterSmartHomePlugin", "onDetachedFromEngine")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        // 可以在这里获取 Activity 引用
    }

    override fun onDetachedFromActivity() {
        // 清理 Activity 相关资源
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}