package com.jiyoujiaju.jijiahui

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.ProgressBar

class WebViewActivity : Activity() {

    companion object {
        private const val EXTRA_URL = "extra_url"
        private const val EXTRA_TITLE = "extra_title"

        fun start(context: Context, url: String, title: String = "") {
            val intent = Intent(context, WebViewActivity::class.java).apply {
                putExtra(EXTRA_URL, url)
                putExtra(EXTRA_TITLE, title)
            }
            context.startActivity(intent)
        }
    }

    private lateinit var webview: WebView
    private lateinit var progressBar: ProgressBar

    private var url: String = ""
    private var title: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_web_view) // 确保 layout 文件名称正确

        webview = findViewById(R.id.webview)
        progressBar = findViewById(R.id.progress_bar)

        url = intent.getStringExtra(EXTRA_URL) ?: ""
        title = intent.getStringExtra(EXTRA_TITLE) ?: ""
        if (url.isEmpty()) {
            finish()
            return
        }

        initActionBar()
        setupWebView()
        loadUrl()
    }

    private fun initActionBar() {
        actionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            this.title = this@WebViewActivity.title
        }
    }

    private fun setupWebView() {
        webview.settings.javaScriptEnabled = true
        webview.settings.setSupportZoom(true)
        webview.settings.builtInZoomControls = true
        webview.settings.displayZoomControls = false
        webview.settings.domStorageEnabled = true

        webview.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String): Boolean {
                view?.loadUrl(url)
                return true
            }

            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                progressBar.visibility = View.VISIBLE
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                progressBar.visibility = View.GONE
            }
        }

        webview.webChromeClient = object : WebChromeClient() {
            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                progressBar.progress = newProgress
            }
        }
    }

    private fun loadUrl() {
        webview.loadUrl(url)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == android.R.id.home) {
            onBackPressed()
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onBackPressed() {
        if (webview.canGoBack()) {
            webview.goBack()
        } else {
            super.onBackPressed()
        }
    }

    override fun onDestroy() {
        webview.destroy()
        super.onDestroy()
    }
}