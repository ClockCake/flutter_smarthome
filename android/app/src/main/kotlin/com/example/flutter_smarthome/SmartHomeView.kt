package com.jiyoujiaju.jijiahui

import android.content.Context
import android.os.Build
import android.util.AttributeSet
import android.view.LayoutInflater
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebSettings
import android.webkit.WebChromeClient
import android.widget.LinearLayout
import android.util.Log
import android.widget.ImageView
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class SmartHomeView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    private lateinit var webView: WebView

    init {
        initView()
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.smart_home_devices_layout, this, true)

        // 初始化 WebView
        webView = findViewById(R.id.header_webview)
        setupWebView()

        // 给 vr_icon 添加点击事件，点击后跳转到 WebViewActivity
        findViewById<ImageView>(R.id.vr_icon).setOnClickListener {
            WebViewActivity.start(context, "https://360vryun.cn/t/c84121f49047024e", "VR")
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun setupWebView() {
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            loadWithOverviewMode = true
            useWideViewPort = true
            mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            cacheMode = WebSettings.LOAD_NO_CACHE
        }

        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                Log.d("SmartHomeView", "WebView page loaded: $url")
            }
        }

        webView.webChromeClient = WebChromeClient()

        // 加载网页
        webView.loadUrl("https://360vryun.cn/t/c84121f49047024e")
    }

    // 提供公共方法处理业务逻辑
    fun refreshContent() {
        webView.reload()
    }

    fun handleBack(): Boolean {
        return if (webView.canGoBack()) {
            webView.goBack()
            true
        } else {
            false
        }
    }

    // 清理资源
    fun cleanup() {
        webView.destroy()
    }
}