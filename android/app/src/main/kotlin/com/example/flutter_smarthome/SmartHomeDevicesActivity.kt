package com.jiyoujiaju.jijiahui

import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebSettings
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.view.View
import android.widget.Button
import android.content.Intent
import androidx.annotation.RequiresApi

class SmartHomeDevicesActivity : Activity() {
    private lateinit var webView: WebView

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.smart_home_devices_layout)

        Log.d("SmartHomeDevices", "onCreate called")
        initializeViews()
    }

    override fun onResume() {
        super.onResume()
        Log.d("SmartHomeDevices", "onResume called")
        // 在 onResume 中更新必要的状态
        updateWebViewContent()
    }

    private fun initializeViews() {
        Log.d("SmartHomeDevices", "initializeViews started")

        // 初始化 WebView
        webView = findViewById(R.id.header_webview)
        setupWebView()

    }

    private fun setupWebView() {
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            loadWithOverviewMode = true
            useWideViewPort = true
            mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            cacheMode = WebSettings.LOAD_NO_CACHE

            // 如果需要调试 WebView
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//                setWebContentsDebuggingEnabled(true)
            }
        }

        // 设置 WebViewClient
        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                Log.d("SmartHomeDevices", "WebView page loaded: $url")
            }
        }

        // 设置 WebChromeClient 用于处理 JavaScript 警告和错误
        webView.webChromeClient = WebChromeClient()

        // 添加 JavaScript 接口
        webView.addJavascriptInterface(WebAppInterface(), "Android")
    }



    private fun updateWebViewContent() {
        // 加载 URL 或 HTML 内容
        webView.loadUrl("https://xjf7711.github.io/decoration/index.html")
        // 或者加载本地 HTML
        // webView.loadData(htmlContent, "text/html", "UTF-8")
    }

    // JavaScript 接口类，用于 WebView 和原生代码通信
    private inner class WebAppInterface {
        @JavascriptInterface
        fun onWebViewEvent(data: String) {
            Log.d("SmartHomeDevices", "Received event from WebView: $data")
            // 处理来自 WebView 的事件
        }

        @JavascriptInterface
        fun getDeviceInfo(): String {
            // 返回设备信息或其他需要的数据
            return "{\"platform\": \"android\"}"
        }
    }

    // 处理返回按钮
    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }

    // 处理 Activity 销毁
    override fun onDestroy() {
        webView.destroy()
        super.onDestroy()
    }

    // 处理 Activity 暂停
    override fun onPause() {
        webView.onPause()
        super.onPause()
    }
}